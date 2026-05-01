import Foundation
import AppKit
import UserNotifications

class AccountsManager: ObservableObject {
    @Published var accounts: [Account] = []
    @Published var activeAccountId: String?
    @Published var isLoading: Bool = false
    @Published var openAtLogin: Bool = false
    @Published var shortcutEnabled: Bool = true
    @Published var showResetTime: Bool = true
    @Published var isAccessibilityEnabled: Bool = false
    @Published var animationSeed: UUID = UUID()

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
        showResetTime = UserDefaults.standard.object(forKey: "show_reset_time") == nil
            ? true
            : UserDefaults.standard.bool(forKey: "show_reset_time")
    }

    func saveSettings() {
        UserDefaults.standard.set(openAtLogin, forKey: "open_at_login")
        UserDefaults.standard.set(shortcutEnabled, forKey: "shortcut_enabled")
        UserDefaults.standard.set(showResetTime, forKey: "show_reset_time")
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

        guard let orgId = extractOrgId(from: cookie) else {
            accounts[index].errorMessage = "Could not get org ID"
            return
        }

        isLoading = true
        accounts[index].errorMessage = nil

        WebFetcher.shared.fetch(orgId: orgId, cookieString: cookie) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                guard let idx = self.accounts.firstIndex(where: { $0.id == accountId }) else { return }
                switch result {
                case .success(let data):
                    self.accounts[idx].billingStatus = .ok
                    self.parseUsageData(data, accountIndex: idx)
                case .failure(let error):
                    let code = (error as NSError).code
                    self.accounts[idx].billingStatus = Self.billingStatus(for: code)
                    self.accounts[idx].errorMessage = "HTTP \(code)"
                }
                self.delegate?.refreshMenuBar()
            }
        }
    }

    private func extractOrgId(from cookie: String) -> String? {
        for part in cookie.components(separatedBy: ";") {
            let t = part.trimmingCharacters(in: .whitespaces)
            if t.hasPrefix("lastActiveOrg=") {
                return t.replacingOccurrences(of: "lastActiveOrg=", with: "")
            }
        }
        return nil
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
