import Foundation
import AppKit
import UserNotifications

class AccountsManager: ObservableObject {
    @Published var accounts: [Account] = []
    @Published var activeAccountId: String?
    @Published var isLoading: Bool = false
    @Published var openAtLogin: Bool = false
    @Published var shortcutEnabled: Bool = true
    @Published var isAccessibilityEnabled: Bool = false

    private weak var delegate: AppDelegate?

    var activeAccount: Account? {
        if let id = activeAccountId, let found = accounts.first(where: { $0.id == id }) { return found }
        return accounts.first
    }

    init(delegate: AppDelegate? = nil) {
        self.delegate = delegate
        loadAccounts()
        loadSettings()
        isAccessibilityEnabled = AXIsProcessTrusted()
    }

    // MARK: - Persistence

    func loadAccounts() {
        if let data = UserDefaults.standard.data(forKey: "accounts_v2"),
           let decoded = try? JSONDecoder().decode([Account].self, from: data) {
            accounts = decoded
        }
        if let savedId = UserDefaults.standard.string(forKey: "active_account_id"),
           accounts.contains(where: { $0.id == savedId }) {
            activeAccountId = savedId
        } else {
            activeAccountId = accounts.first?.id
        }
    }

    func saveAccounts() {
        if let data = try? JSONEncoder().encode(accounts) {
            UserDefaults.standard.set(data, forKey: "accounts_v2")
        }
        UserDefaults.standard.set(activeAccountId, forKey: "active_account_id")
        UserDefaults.standard.synchronize()
    }

    func loadSettings() {
        openAtLogin = UserDefaults.standard.bool(forKey: "open_at_login")
        shortcutEnabled = UserDefaults.standard.object(forKey: "shortcut_enabled") == nil
            ? true
            : UserDefaults.standard.bool(forKey: "shortcut_enabled")
    }

    func saveSettings() {
        UserDefaults.standard.set(openAtLogin, forKey: "open_at_login")
        UserDefaults.standard.set(shortcutEnabled, forKey: "shortcut_enabled")
        UserDefaults.standard.synchronize()
    }

    // MARK: - Account Management

    func addAccount(label: String, cookie: String) {
        let account = Account(label: label, cookie: cookie)
        accounts.append(account)
        if accounts.count == 1 { activeAccountId = account.id }
        saveAccounts()
        fetchUsage(for: account.id)
    }

    func deleteAccount(id: String) {
        accounts.removeAll { $0.id == id }
        if activeAccountId == id { activeAccountId = accounts.first?.id }
        saveAccounts()
        delegate?.refreshMenuBar()
    }

    func setActiveAccount(id: String) {
        activeAccountId = id
        saveAccounts()
        delegate?.refreshMenuBar()
    }

    func renameAccount(id: String, label: String) {
        guard !label.isEmpty, let idx = accounts.firstIndex(where: { $0.id == id }) else { return }
        accounts[idx].label = label
        saveAccounts()
        delegate?.refreshMenuBar()
    }

    func toggleMenuBar(id: String, show: Bool) {
        guard let idx = accounts.firstIndex(where: { $0.id == id }) else { return }
        accounts[idx].showInMenuBar = show
        saveAccounts()
        delegate?.refreshMenuBar()
    }

    // MARK: - Fetching

    func fetchAllAccounts() {
        for account in accounts { fetchUsage(for: account.id) }
    }

    func fetchUsage(for accountId: String) {
        guard let index = accounts.firstIndex(where: { $0.id == accountId }) else { return }
        let cookie = accounts[index].cookie
        guard !cookie.isEmpty else { accounts[index].errorMessage = "Cookie not set"; return }

        isLoading = true
        accounts[index].errorMessage = nil

        fetchOrganizationId(cookie: cookie) { [weak self] orgId in
            guard let self else { return }
            guard let orgId else {
                DispatchQueue.main.async {
                    if let idx = self.accounts.firstIndex(where: { $0.id == accountId }) {
                        self.accounts[idx].errorMessage = "Could not get org ID"
                    }
                    self.isLoading = false
                }
                return
            }
            self.fetchUsageWithOrgId(orgId, cookie: cookie, accountId: accountId)
        }
    }

    private func fetchOrganizationId(cookie: String, completion: @escaping (String?) -> Void) {
        for part in cookie.components(separatedBy: ";") {
            let t = part.trimmingCharacters(in: .whitespaces)
            if t.hasPrefix("lastActiveOrg=") {
                completion(t.replacingOccurrences(of: "lastActiveOrg=", with: ""))
                return
            }
        }
        guard let url = URL(string: "https://claude.ai/api/bootstrap") else { completion(nil); return }
        var req = URLRequest(url: url)
        req.setValue(cookie, forHTTPHeaderField: "Cookie")
        URLSession.shared.dataTask(with: req) { data, _, _ in
            guard let data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let acc = json["account"] as? [String: Any],
                  let orgId = acc["lastActiveOrgId"] as? String else { completion(nil); return }
            completion(orgId)
        }.resume()
    }

    private func fetchUsageWithOrgId(_ orgId: String, cookie: String, accountId: String) {
        guard let url = URL(string: "https://claude.ai/api/organizations/\(orgId)/usage") else {
            DispatchQueue.main.async {
                if let idx = self.accounts.firstIndex(where: { $0.id == accountId }) {
                    self.accounts[idx].errorMessage = "Invalid URL"
                }
                self.isLoading = false
            }
            return
        }
        var req = URLRequest(url: url)
        req.setValue(cookie, forHTTPHeaderField: "Cookie")
        req.setValue("*/*", forHTTPHeaderField: "Accept")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("https://claude.ai", forHTTPHeaderField: "Origin")
        req.setValue("https://claude.ai", forHTTPHeaderField: "Referer")
        req.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
        req.setValue("claude.ai", forHTTPHeaderField: "authority")

        URLSession.shared.dataTask(with: req) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                guard let idx = self.accounts.firstIndex(where: { $0.id == accountId }) else { return }
                if error != nil { self.accounts[idx].errorMessage = "Network error"; self.delegate?.refreshMenuBar(); return }
                guard let http = response as? HTTPURLResponse else { self.accounts[idx].errorMessage = "Invalid response"; return }
                if http.statusCode == 200, let data {
                    self.accounts[idx].billingStatus = .ok
                    self.parseUsageData(data, accountIndex: idx)
                } else {
                    self.accounts[idx].billingStatus = Self.billingStatus(for: http.statusCode)
                    self.accounts[idx].errorMessage = self.accounts[idx].billingStatus == .ok
                        ? "HTTP \(http.statusCode)" : nil
                }
                self.delegate?.refreshMenuBar()
            }
        }.resume()
    }

    private func parseUsageData(_ data: Data, accountIndex: Int) {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            accounts[accountIndex].errorMessage = "Invalid JSON"; return
        }
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let fh = json["five_hour"] as? [String: Any] {
            if let u = fh["utilization"] as? Double { accounts[accountIndex].sessionUsage = Int(u) }
            if let s = fh["resets_at"] as? String, let d = iso.date(from: s) { accounts[accountIndex].sessionResetsAt = d }
        }
        if let sd = json["seven_day"] as? [String: Any] {
            if let u = sd["utilization"] as? Double { accounts[accountIndex].weeklyUsage = Int(u) }
            if let s = sd["resets_at"] as? String, let d = iso.date(from: s) { accounts[accountIndex].weeklyResetsAt = d }
        }
        if let sn = json["seven_day_sonnet"] as? [String: Any] {
            accounts[accountIndex].hasWeeklySonnet = true
            if let u = sn["utilization"] as? Double { accounts[accountIndex].weeklySonnetUsage = Int(u) }
            if let s = sn["resets_at"] as? String, let d = iso.date(from: s) { accounts[accountIndex].weeklySonnetResetsAt = d }
        } else {
            accounts[accountIndex].hasWeeklySonnet = false
        }

        accounts[accountIndex].lastUpdated = Date()
        accounts[accountIndex].errorMessage = nil
        accounts[accountIndex].hasFetchedData = true
        accounts[accountIndex].updatePercentages()

    }

    func updatePercentagesForAll() {
        for i in accounts.indices { accounts[i].updatePercentages() }
    }

    private static func billingStatus(for statusCode: Int) -> BillingStatus {
        switch statusCode {
        case 401: return .sessionExpired
        case 402: return .paymentRequired
        case 403: return .forbidden
        case 429: return .rateLimited
        default:  return .ok
        }
    }

}
