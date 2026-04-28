import SwiftUI
import AppKit
import WebKit
import Carbon

// MARK: - Account Model

struct Account: Codable, Identifiable {
    var id: String
    var label: String
    var cookie: String

    // Transient usage data (not persisted)
    var sessionUsage: Int = 0
    var sessionLimit: Int = 100
    var weeklyUsage: Int = 0
    var weeklyLimit: Int = 100
    var weeklySonnetUsage: Int = 0
    var weeklySonnetLimit: Int = 100
    var sessionPercentage: Double = 0.0
    var weeklyPercentage: Double = 0.0
    var weeklySonnetPercentage: Double = 0.0
    var sessionResetsAt: Date?
    var weeklyResetsAt: Date?
    var weeklySonnetResetsAt: Date?
    var hasWeeklySonnet: Bool = false
    var errorMessage: String?
    var hasFetchedData: Bool = false
    var lastUpdated: Date?

    enum CodingKeys: String, CodingKey {
        case id, label, cookie
    }

    init(label: String, cookie: String) {
        self.id = UUID().uuidString
        self.label = label.isEmpty ? "Account" : label
        self.cookie = cookie
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        label = try container.decode(String.self, forKey: .label)
        cookie = try container.decode(String.self, forKey: .cookie)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(label, forKey: .label)
        try container.encode(cookie, forKey: .cookie)
    }

    mutating func updatePercentages() {
        sessionPercentage = Double(sessionUsage) / Double(max(sessionLimit, 1))
        weeklyPercentage = Double(weeklyUsage) / Double(max(weeklyLimit, 1))
        weeklySonnetPercentage = Double(weeklySonnetUsage) / Double(max(weeklySonnetLimit, 1))
    }
}

// MARK: - AppDelegate

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var accountsManager: AccountsManager!
    var eventMonitor: Any?
    var hotKeyRef: EventHotKeyRef?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            updateStatusIcon(percentage: 0)
            button.action = #selector(handleClick)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.target = self
            button.appearsDisabled = false
            button.isEnabled = true
        }

        accountsManager = AccountsManager(statusItem: statusItem, delegate: self)

        popover = NSPopover()
        popover.contentSize = NSSize(width: 360, height: 480)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: UsageView(accountsManager: accountsManager)
        )

        accountsManager.fetchAllAccounts()

        Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
            self.accountsManager.fetchAllAccounts()
        }

        setupKeyboardShortcut()
    }

    func setupKeyboardShortcut() {
        checkAccessibilityPermissions()
        if accountsManager.shortcutEnabled {
            registerGlobalHotKey()
        }
    }

    func setShortcutEnabled(_ enabled: Bool) {
        if enabled {
            registerGlobalHotKey()
        } else {
            unregisterGlobalHotKey()
        }
    }

    func checkAccessibilityPermissions() {
        let trusted = AXIsProcessTrusted()
        if !trusted {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let alert = NSAlert()
                alert.messageText = "Accessibility Permission Required"
                alert.informativeText = "Claude Usage Monitor needs Accessibility permission to use the Cmd+U keyboard shortcut.\n\nPlease enable it in:\nSystem Settings → Privacy & Security → Accessibility"
                alert.alertStyle = .informational
                alert.addButton(withTitle: "Open System Settings")
                alert.addButton(withTitle: "Skip for Now")
                let response = alert.runModal()
                if response == .alertFirstButtonReturn {
                    NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
                }
            }
        }
    }

    func registerGlobalHotKey() {
        if hotKeyRef != nil { return }

        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = 0x436C5542
        hotKeyID.id = 1

        let keyCode: UInt32 = 32
        let modifiers: UInt32 = UInt32(cmdKey)

        var eventType = EventTypeSpec()
        eventType.eventClass = OSType(kEventClassKeyboard)
        eventType.eventKind = OSType(kEventHotKeyPressed)

        var handler: EventHandlerRef?
        let callback: EventHandlerUPP = { (_, _, userData) -> OSStatus in
            let appDelegate = Unmanaged<AppDelegate>.fromOpaque(userData!).takeUnretainedValue()
            DispatchQueue.main.async { appDelegate.togglePopover() }
            return noErr
        }

        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        InstallEventHandler(GetApplicationEventTarget(), callback, 1, &eventType, selfPtr, &handler)
        let status = RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)

        if status == noErr {
            NSLog("✅ Registered Cmd+U hotkey")
        } else {
            NSLog("❌ Failed to register hotkey: \(status)")
        }
    }

    func unregisterGlobalHotKey() {
        if let hotKey = hotKeyRef {
            UnregisterEventHotKey(hotKey)
            hotKeyRef = nil
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        unregisterGlobalHotKey()
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    @objc func togglePopover() {
        if popover.isShown {
            closePopover()
        } else {
            openPopover()
        }
    }

    @objc func handleClick() {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseUp {
            let menu = NSMenu()
            let toggleItem = NSMenuItem(title: "Toggle Usage (⌘U)", action: #selector(togglePopover), keyEquivalent: "u")
            toggleItem.keyEquivalentModifierMask = .command
            menu.addItem(toggleItem)
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "Quit Claude Usage Monitor", action: #selector(quitApp), keyEquivalent: "q"))
            statusItem.menu = menu
            statusItem.button?.performClick(nil)
            statusItem.menu = nil
        } else {
            togglePopover()
        }
    }

    func openPopover() {
        if let button = statusItem.button {
            DispatchQueue.main.async {
                self.accountsManager.updatePercentagesForAll()
            }
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
                if self?.popover.isShown == true {
                    self?.closePopover()
                }
            }
        }
    }

    func closePopover() {
        popover.performClose(nil)
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }

    func updateStatusIcon(percentage: Int) {
        guard let button = statusItem.button else { return }

        let color: NSColor
        if percentage < 70 {
            color = NSColor(red: 0.13, green: 0.77, blue: 0.37, alpha: 1.0)
        } else if percentage < 90 {
            color = NSColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        } else {
            color = NSColor(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0)
        }

        button.image = createSparkIcon(color: color)
        button.title = " \(percentage)%"
    }

    func createSparkIcon(color: NSColor) -> NSImage {
        let size = NSSize(width: 16, height: 16)
        let image = NSImage(size: size)
        image.lockFocus()
        let path = NSBezierPath()
        path.move(to: NSPoint(x: 8, y: 1))
        path.line(to: NSPoint(x: 9, y: 6))
        path.line(to: NSPoint(x: 13, y: 3))
        path.line(to: NSPoint(x: 10, y: 7))
        path.line(to: NSPoint(x: 15, y: 8))
        path.line(to: NSPoint(x: 10, y: 9))
        path.line(to: NSPoint(x: 13, y: 13))
        path.line(to: NSPoint(x: 9, y: 10))
        path.line(to: NSPoint(x: 8, y: 15))
        path.line(to: NSPoint(x: 7, y: 10))
        path.line(to: NSPoint(x: 3, y: 13))
        path.line(to: NSPoint(x: 6, y: 9))
        path.line(to: NSPoint(x: 1, y: 8))
        path.line(to: NSPoint(x: 6, y: 7))
        path.line(to: NSPoint(x: 3, y: 3))
        path.line(to: NSPoint(x: 7, y: 6))
        path.close()
        color.setFill()
        path.fill()
        image.unlockFocus()
        image.isTemplate = false
        return image
    }
}

// MARK: - Main Entry Point

@main
struct Main {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        app.run()
    }
}

// MARK: - AccountsManager

class AccountsManager: ObservableObject {
    @Published var accounts: [Account] = []
    @Published var activeAccountId: String?
    @Published var isLoading: Bool = false
    @Published var notificationsEnabled: Bool = true
    @Published var openAtLogin: Bool = false
    @Published var shortcutEnabled: Bool = true
    @Published var isAccessibilityEnabled: Bool = false

    private var statusItem: NSStatusItem?
    private weak var delegate: AppDelegate?
    private var lastNotifiedThresholds: [String: Int] = [:]

    var activeAccount: Account? {
        if let id = activeAccountId, let found = accounts.first(where: { $0.id == id }) {
            return found
        }
        return accounts.first
    }

    init(statusItem: NSStatusItem?, delegate: AppDelegate? = nil) {
        self.statusItem = statusItem
        self.delegate = delegate
        loadAccounts()
        loadSettings()
        isAccessibilityEnabled = AXIsProcessTrusted()
    }

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

    func addAccount(label: String, cookie: String) {
        let account = Account(label: label, cookie: cookie)
        accounts.append(account)
        if accounts.count == 1 {
            activeAccountId = account.id
        }
        saveAccounts()
        fetchUsage(for: account.id)
    }

    func deleteAccount(id: String) {
        accounts.removeAll { $0.id == id }
        if activeAccountId == id {
            activeAccountId = accounts.first?.id
        }
        saveAccounts()
        updateStatusBar()
    }

    func setActiveAccount(id: String) {
        activeAccountId = id
        saveAccounts()
        updateStatusBar()
    }

    func loadSettings() {
        if !UserDefaults.standard.bool(forKey: "has_set_notifications") {
            notificationsEnabled = true
            UserDefaults.standard.set(true, forKey: "has_set_notifications")
        } else {
            notificationsEnabled = UserDefaults.standard.bool(forKey: "notifications_enabled")
        }
        openAtLogin = UserDefaults.standard.bool(forKey: "open_at_login")
        if UserDefaults.standard.object(forKey: "shortcut_enabled") == nil {
            shortcutEnabled = true
        } else {
            shortcutEnabled = UserDefaults.standard.bool(forKey: "shortcut_enabled")
        }
    }

    func saveSettings() {
        UserDefaults.standard.set(notificationsEnabled, forKey: "notifications_enabled")
        UserDefaults.standard.set(openAtLogin, forKey: "open_at_login")
        UserDefaults.standard.set(shortcutEnabled, forKey: "shortcut_enabled")
        UserDefaults.standard.synchronize()
    }

    func fetchAllAccounts() {
        for account in accounts {
            fetchUsage(for: account.id)
        }
    }

    func fetchUsage(for accountId: String) {
        guard let index = accounts.firstIndex(where: { $0.id == accountId }) else { return }
        let cookie = accounts[index].cookie
        guard !cookie.isEmpty else {
            accounts[index].errorMessage = "Cookie not set"
            return
        }

        isLoading = true
        accounts[index].errorMessage = nil

        fetchOrganizationId(cookie: cookie) { [weak self] orgId in
            guard let self = self else { return }
            guard let orgId = orgId else {
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

    func fetchOrganizationId(cookie: String, completion: @escaping (String?) -> Void) {
        for part in cookie.components(separatedBy: ";") {
            let trimmed = part.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("lastActiveOrg=") {
                completion(trimmed.replacingOccurrences(of: "lastActiveOrg=", with: ""))
                return
            }
        }

        guard let url = URL(string: "https://claude.ai/api/bootstrap") else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(cookie, forHTTPHeaderField: "Cookie")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let account = json["account"] as? [String: Any],
                  let orgId = account["lastActiveOrgId"] as? String else {
                completion(nil)
                return
            }
            completion(orgId)
        }.resume()
    }

    func fetchUsageWithOrgId(_ orgId: String, cookie: String, accountId: String) {
        let urlString = "https://claude.ai/api/organizations/\(orgId)/usage"
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                if let idx = self.accounts.firstIndex(where: { $0.id == accountId }) {
                    self.accounts[idx].errorMessage = "Invalid URL"
                }
                self.isLoading = false
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(cookie, forHTTPHeaderField: "Cookie")
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("https://claude.ai", forHTTPHeaderField: "Origin")
        request.setValue("https://claude.ai", forHTTPHeaderField: "Referer")
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
        request.setValue("claude.ai", forHTTPHeaderField: "authority")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                guard let idx = self.accounts.firstIndex(where: { $0.id == accountId }) else { return }

                if error != nil {
                    self.accounts[idx].errorMessage = "Network error"
                    self.updateStatusBar()
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.accounts[idx].errorMessage = "Invalid response"
                    self.updateStatusBar()
                    return
                }
                if httpResponse.statusCode == 200, let data = data {
                    self.parseUsageData(data, accountIndex: idx)
                } else {
                    self.accounts[idx].errorMessage = "HTTP \(httpResponse.statusCode)"
                }
                self.updateStatusBar()
            }
        }.resume()
    }

    func parseUsageData(_ data: Data, accountIndex: Int) {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            accounts[accountIndex].errorMessage = "Invalid JSON"
            return
        }

        let iso8601 = ISO8601DateFormatter()
        iso8601.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let fiveHour = json["five_hour"] as? [String: Any] {
            if let util = fiveHour["utilization"] as? Double {
                accounts[accountIndex].sessionUsage = Int(util)
            }
            if let s = fiveHour["resets_at"] as? String, let d = iso8601.date(from: s) {
                accounts[accountIndex].sessionResetsAt = d
            }
        }

        if let sevenDay = json["seven_day"] as? [String: Any] {
            if let util = sevenDay["utilization"] as? Double {
                accounts[accountIndex].weeklyUsage = Int(util)
            }
            if let s = sevenDay["resets_at"] as? String, let d = iso8601.date(from: s) {
                accounts[accountIndex].weeklyResetsAt = d
            }
        }

        if let sonnet = json["seven_day_sonnet"] as? [String: Any] {
            accounts[accountIndex].hasWeeklySonnet = true
            if let util = sonnet["utilization"] as? Double {
                accounts[accountIndex].weeklySonnetUsage = Int(util)
            }
            if let s = sonnet["resets_at"] as? String, let d = iso8601.date(from: s) {
                accounts[accountIndex].weeklySonnetResetsAt = d
            }
        } else {
            accounts[accountIndex].hasWeeklySonnet = false
        }

        accounts[accountIndex].lastUpdated = Date()
        accounts[accountIndex].errorMessage = nil
        accounts[accountIndex].hasFetchedData = true
        accounts[accountIndex].updatePercentages()

        if accounts[accountIndex].id == activeAccountId {
            checkNotificationThresholds(
                percentage: accounts[accountIndex].sessionUsage,
                accountId: accounts[accountIndex].id
            )
        }
    }

    func updateStatusBar() {
        let percentage: Int
        if let active = activeAccount, active.hasFetchedData {
            percentage = active.sessionUsage
        } else {
            percentage = 0
        }
        delegate?.updateStatusIcon(percentage: percentage)
    }

    func updatePercentagesForAll() {
        for i in accounts.indices {
            accounts[i].updatePercentages()
        }
    }

    func checkNotificationThresholds(percentage: Int, accountId: String) {
        guard notificationsEnabled else { return }
        let lastNotified = lastNotifiedThresholds[accountId] ?? 0
        let thresholds = [25, 50, 75, 90]
        for threshold in thresholds where percentage >= threshold && lastNotified < threshold {
            sendNotification(percentage: percentage, threshold: threshold)
            lastNotifiedThresholds[accountId] = threshold
        }
        if percentage < lastNotified {
            lastNotifiedThresholds[accountId] = thresholds.filter { $0 <= percentage }.last ?? 0
        }
    }

    func sendNotification(percentage: Int, threshold: Int) {
        let n = NSUserNotification()
        n.title = "Claude Usage Alert"
        n.informativeText = "You've reached \(percentage)% of your 5-hour session limit"
        n.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(n)
    }

    func sendTestNotification() {
        let n = NSUserNotification()
        n.title = "Claude Usage Alert"
        n.informativeText = "Test notification - You've reached 75% of your 5-hour session limit"
        n.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(n)
    }
}

// MARK: - PasteableTextField (multi-line, supports Cmd+V)

class PasteableNSTextView: NSTextView {
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if event.modifierFlags.contains(.command) {
            switch event.charactersIgnoringModifiers {
            case "v": paste(nil); return true
            case "c": copy(nil); return true
            case "x": cut(nil); return true
            case "a": selectAll(nil); return true
            default: break
            }
        }
        return super.performKeyEquivalent(with: event)
    }
}

struct PasteableTextField: NSViewRepresentable {
    @Binding var text: String
    var placeholder: String

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let textView = PasteableNSTextView()
        textView.isEditable = true
        textView.isSelectable = true
        textView.font = NSFont.systemFont(ofSize: 11)
        textView.textColor = .labelColor
        textView.backgroundColor = .textBackgroundColor
        textView.drawsBackground = true
        textView.isRichText = false
        textView.delegate = context.coordinator
        textView.textContainerInset = NSSize(width: 4, height: 4)
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isGrammarCheckingEnabled = false
        textView.allowsUndo = true
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable = true
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .bezelBorder
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? PasteableNSTextView else { return }
        if textView.string != text {
            textView.string = text
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: PasteableTextField
        init(_ parent: PasteableTextField) { self.parent = parent }
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
        }
    }
}

// MARK: - Usage Bar

struct UsageBar: View {
    let label: String
    let percentage: Double
    let resetsAt: Date?
    let includeDate: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(label)
                    .font(.caption)
                Spacer()
                if let date = resetsAt {
                    Text(formatResetTime(date))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            ProgressView(value: min(percentage, 1.0))
                .tint(colorFor(percentage))
            Text("\(Int(percentage * 100))% used")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }

    func colorFor(_ p: Double) -> Color {
        if p < 0.7 { return .green }
        if p < 0.9 { return .orange }
        return .red
    }

    func formatResetTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        if includeDate {
            formatter.dateFormat = "d MMM yyyy 'at' h:mm a"
            return "on \(formatter.string(from: date))"
        } else {
            formatter.timeStyle = .short
            formatter.dateStyle = .none
            return "at \(formatter.string(from: date))"
        }
    }
}

// MARK: - Account Card

struct AccountCard: View {
    let account: Account
    let isActive: Bool
    let onSetActive: () -> Void
    let onDelete: () -> Void
    let onRefresh: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header row
            HStack(spacing: 6) {
                Circle()
                    .fill(isActive ? Color.green : Color.secondary.opacity(0.4))
                    .frame(width: 7, height: 7)
                Text(account.label)
                    .font(.subheadline)
                    .fontWeight(isActive ? .semibold : .regular)
                Spacer()
                if !isActive {
                    Button("Set Active") { onSetActive() }
                        .buttonStyle(.borderless)
                        .font(.caption)
                        .foregroundColor(.accentColor)
                }
                Button(action: onRefresh) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
                .foregroundColor(.secondary)
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
                .foregroundColor(.secondary)
            }

            // Error or usage data
            if let error = account.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.orange)
            } else if account.hasFetchedData {
                UsageBar(
                    label: "Session (5h)",
                    percentage: account.sessionPercentage,
                    resetsAt: account.sessionResetsAt,
                    includeDate: false
                )
                UsageBar(
                    label: "Weekly (7d)",
                    percentage: account.weeklyPercentage,
                    resetsAt: account.weeklyResetsAt,
                    includeDate: true
                )
                if account.hasWeeklySonnet {
                    UsageBar(
                        label: "Weekly Sonnet",
                        percentage: account.weeklySonnetPercentage,
                        resetsAt: account.weeklySonnetResetsAt,
                        includeDate: true
                    )
                }
                if let updated = account.lastUpdated {
                    Text("Updated \(formatTime(updated))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("Fetching...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(10)
        .background(Color.secondary.opacity(isActive ? 0.15 : 0.07))
        .cornerRadius(8)
    }

    func formatTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: date)
    }
}

// MARK: - Add Account Form

struct AddAccountForm: View {
    @Binding var label: String
    @Binding var cookie: String
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("New Account")
                .font(.caption)
                .fontWeight(.semibold)

            HStack(alignment: .center, spacing: 8) {
                Text("Label:")
                    .font(.caption)
                TextField("e.g. Work, Personal", text: $label)
                    .font(.caption)
                    .textFieldStyle(.roundedBorder)
            }

            Text("Session Cookie:")
                .font(.caption)

            VStack(alignment: .leading, spacing: 3) {
                Text("1. Go to Settings > Usage on claude.ai")
                Text("2. Press Cmd+Option+I → Network tab")
                Text("3. Refresh page, click the 'usage' request")
                Text("4. Copy 'Cookie' value from Request Headers")
            }
            .font(.caption2)
            .foregroundColor(.secondary)

            PasteableTextField(text: $cookie, placeholder: "Paste full cookie string here...")
                .frame(height: 60)
                .cornerRadius(4)

            HStack(spacing: 8) {
                Button("Save Account") { onSave() }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .disabled(cookie.isEmpty)
                Button("Cancel") { onCancel() }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            }
        }
        .padding(10)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Onboarding View

struct OnboardingView: View {
    @ObservedObject var accountsManager: AccountsManager
    @State private var label: String = ""
    @State private var cookie: String = ""
    @State private var showingForm: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Welcome to Claude Usage Monitor!")
                .font(.subheadline)
                .fontWeight(.semibold)

            Text("Track your Claude.ai session and weekly usage directly from the menu bar. Add your first account to get started.")
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if !showingForm {
                Button("Add Your First Account") {
                    showingForm = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            } else {
                AddAccountForm(label: $label, cookie: $cookie) {
                    guard !cookie.isEmpty else { return }
                    accountsManager.addAccount(label: label, cookie: cookie)
                    label = ""
                    cookie = ""
                    showingForm = false
                } onCancel: {
                    label = ""
                    cookie = ""
                    showingForm = false
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.secondary.opacity(0.07))
        .cornerRadius(8)
    }
}

// MARK: - Settings Section

struct SettingsSection: View {
    @ObservedObject var accountsManager: AccountsManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: Binding(
                get: { accountsManager.openAtLogin },
                set: { v in accountsManager.openAtLogin = v; accountsManager.saveSettings() }
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Open at Login")
                        .font(.caption)
                    Text("Launch automatically when you log in")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .toggleStyle(.checkbox)

            VStack(alignment: .leading, spacing: 8) {
                Toggle(isOn: Binding(
                    get: { accountsManager.notificationsEnabled },
                    set: { v in accountsManager.notificationsEnabled = v; accountsManager.saveSettings() }
                )) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Enable Notifications")
                            .font(.caption)
                        Text("Alerts at 25%, 50%, 75%, and 90% session usage")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .toggleStyle(.checkbox)

                Button("Test Notification") { accountsManager.sendTestNotification() }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Toggle(isOn: Binding(
                    get: { accountsManager.shortcutEnabled },
                    set: { v in
                        accountsManager.shortcutEnabled = v
                        accountsManager.saveSettings()
                        (NSApplication.shared.delegate as? AppDelegate)?.setShortcutEnabled(v)
                    }
                )) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Keyboard Shortcut (⌘U)")
                            .font(.caption)
                        Text("Toggle popup from anywhere. Disable if it conflicts with other apps.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .toggleStyle(.switch)

                if accountsManager.shortcutEnabled && !accountsManager.isAccessibilityEnabled {
                    Button("Grant Accessibility Permission") {
                        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)

                    Text("Accessibility permission may be needed for the shortcut to work in all apps.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(10)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Main Usage View

struct UsageView: View {
    @ObservedObject var accountsManager: AccountsManager
    @State private var showingAddAccount: Bool = false
    @State private var showingSettings: Bool = false
    @State private var newLabel: String = ""
    @State private var newCookie: String = ""

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Text("Claude Usage Monitor")
                        .font(.headline)
                    Spacer()
                    if accountsManager.isLoading {
                        ProgressView()
                            .scaleEffect(0.6)
                            .frame(width: 16, height: 16)
                    } else if !accountsManager.accounts.isEmpty {
                        Button(action: { accountsManager.fetchAllAccounts() }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.subheadline)
                        }
                        .buttonStyle(.borderless)
                        .help("Refresh all accounts")
                    }
                }

                // Content
                if accountsManager.accounts.isEmpty {
                    OnboardingView(accountsManager: accountsManager)
                } else {
                    // Account cards
                    ForEach(accountsManager.accounts) { account in
                        AccountCard(
                            account: account,
                            isActive: accountsManager.activeAccountId == account.id,
                            onSetActive: { accountsManager.setActiveAccount(id: account.id) },
                            onDelete: { accountsManager.deleteAccount(id: account.id) },
                            onRefresh: { accountsManager.fetchUsage(for: account.id) }
                        )
                    }

                    // Add account
                    if showingAddAccount {
                        AddAccountForm(label: $newLabel, cookie: $newCookie) {
                            guard !newCookie.isEmpty else { return }
                            accountsManager.addAccount(label: newLabel, cookie: newCookie)
                            newLabel = ""
                            newCookie = ""
                            showingAddAccount = false
                        } onCancel: {
                            newLabel = ""
                            newCookie = ""
                            showingAddAccount = false
                        }
                    } else {
                        Button("+ Add Account") { showingAddAccount = true }
                            .buttonStyle(.borderless)
                            .font(.caption)
                    }
                }

                Divider()

                // Settings toggle
                Button(showingSettings ? "Hide Settings" : "Settings") {
                    showingSettings.toggle()
                }
                .buttonStyle(.borderless)
                .font(.caption)

                if showingSettings {
                    SettingsSection(accountsManager: accountsManager)
                }
            }
            .padding()
            .frame(width: 360)
        }
        .frame(width: 360)
        .onAppear {
            accountsManager.updatePercentagesForAll()
        }
    }
}
