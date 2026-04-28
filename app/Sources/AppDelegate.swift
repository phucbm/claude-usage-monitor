import SwiftUI
import AppKit
import Carbon
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var accountsManager: AccountsManager!
    var eventMonitor: Any?
    var hotKeyRef: EventHotKeyRef?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.action = #selector(handleClick)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.target = self
            button.appearsDisabled = false
            button.isEnabled = true
        }

        accountsManager = AccountsManager(delegate: self)

        popover = NSPopover()
        popover.contentSize = NSSize(width: 420, height: 520)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: UsageView(accountsManager: accountsManager)
        )

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }

        refreshMenuBar()
        accountsManager.fetchAllAccounts()

        Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
            self.accountsManager.fetchAllAccounts()
        }

        setupKeyboardShortcut()
    }

    // MARK: - Menu Bar Badges

    func refreshMenuBar() {
        guard let button = statusItem.button else { return }
        let visible = accountsManager.accounts.filter { $0.showInMenuBar }

        if visible.isEmpty {
            button.image = nil
            button.attributedTitle = NSAttributedString(
                string: "⬡",
                attributes: [.foregroundColor: NSColor.secondaryLabelColor]
            )
            return
        }

        button.image = createBadgesImage(for: visible)
        button.title = ""
        button.imagePosition = .imageOnly
    }

    private func createBadgesImage(for accounts: [Account]) -> NSImage {
        let font = NSFont.systemFont(ofSize: 11, weight: .semibold)
        let orange = NSColor(red: 1.0, green: 0.48, blue: 0.0, alpha: 1.0)
        let bg = NSColor(red: 1.0, green: 0.48, blue: 0.0, alpha: 0.13)
        let hPad: CGFloat = 5
        let height: CGFloat = 16
        let spacing: CGFloat = 4
        let radius: CGFloat = 4

        let attrs: [NSAttributedString.Key: Any] = [.font: font]

        // Measure each badge
        let texts: [String] = accounts.map { account in
            let letter = String(account.label.prefix(1)).uppercased()
            let pct = account.hasFetchedData ? "\(Int(account.sessionPercentage * 100))%" : "--"
            return "\(letter) \(pct)"
        }
        let widths = texts.map { ($0 as NSString).size(withAttributes: attrs).width + hPad * 2 }
        let totalWidth = widths.reduce(0, +) + CGFloat(max(0, accounts.count - 1)) * spacing

        let image = NSImage(size: NSSize(width: totalWidth, height: height), flipped: false) { _ in
            var x: CGFloat = 0
            for (i, text) in texts.enumerated() {
                let w = widths[i]
                let badgeRect = NSRect(x: x, y: 0, width: w, height: height)

                // Background
                let path = NSBezierPath(roundedRect: badgeRect, xRadius: radius, yRadius: radius)
                bg.setFill()
                path.fill()

                // Text
                let textAttrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: orange]
                let textSize = (text as NSString).size(withAttributes: textAttrs)
                let tx = x + (w - textSize.width) / 2
                let ty = (height - textSize.height) / 2
                (text as NSString).draw(at: NSPoint(x: tx, y: ty), withAttributes: textAttrs)

                x += w + spacing
            }
            return true
        }
        image.isTemplate = false
        return image
    }

    // MARK: - Keyboard Shortcut

    func setupKeyboardShortcut() {
        checkAccessibilityPermissions()
        if accountsManager.shortcutEnabled { registerGlobalHotKey() }
    }

    func setShortcutEnabled(_ enabled: Bool) {
        enabled ? registerGlobalHotKey() : unregisterGlobalHotKey()
    }

    func checkAccessibilityPermissions() {
        guard !AXIsProcessTrusted() else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let alert = NSAlert()
            alert.messageText = "Accessibility Permission Required"
            alert.informativeText = "Claude Usage Monitor needs Accessibility permission to use the Cmd+U keyboard shortcut.\n\nPlease enable it in:\nSystem Settings → Privacy & Security → Accessibility"
            alert.alertStyle = .informational
            alert.addButton(withTitle: "Open System Settings")
            alert.addButton(withTitle: "Skip for Now")
            if alert.runModal() == .alertFirstButtonReturn {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
            }
        }
    }

    func registerGlobalHotKey() {
        if hotKeyRef != nil { return }
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = 0x436C5542
        hotKeyID.id = 1
        var eventType = EventTypeSpec()
        eventType.eventClass = OSType(kEventClassKeyboard)
        eventType.eventKind = OSType(kEventHotKeyPressed)
        var handler: EventHandlerRef?
        let callback: EventHandlerUPP = { (_, _, userData) -> OSStatus in
            let d = Unmanaged<AppDelegate>.fromOpaque(userData!).takeUnretainedValue()
            DispatchQueue.main.async { d.togglePopover() }
            return noErr
        }
        let ptr = Unmanaged.passUnretained(self).toOpaque()
        InstallEventHandler(GetApplicationEventTarget(), callback, 1, &eventType, ptr, &handler)
        RegisterEventHotKey(32, UInt32(cmdKey), hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
    }

    func unregisterGlobalHotKey() {
        if let hk = hotKeyRef { UnregisterEventHotKey(hk); hotKeyRef = nil }
    }

    func applicationWillTerminate(_ notification: Notification) { unregisterGlobalHotKey() }

    // MARK: - Popover

    @objc func quitApp() { NSApplication.shared.terminate(nil) }

    @objc func togglePopover() { popover.isShown ? closePopover() : openPopover() }

    @objc func handleClick() {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseUp {
            let menu = NSMenu()
            let item = NSMenuItem(title: "Toggle Usage (⌘U)", action: #selector(togglePopover), keyEquivalent: "u")
            item.keyEquivalentModifierMask = .command
            menu.addItem(item)
            menu.addItem(.separator())
            menu.addItem(NSMenuItem(title: "Quit Claude Usage Monitor", action: #selector(quitApp), keyEquivalent: "q"))
            statusItem.menu = menu
            statusItem.button?.performClick(nil)
            statusItem.menu = nil
        } else {
            togglePopover()
        }
    }

    func openPopover() {
        guard let button = statusItem.button else { return }
        DispatchQueue.main.async { self.accountsManager.updatePercentagesForAll() }
        NSApp.activate(ignoringOtherApps: true)
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            if self?.popover.isShown == true { self?.closePopover() }
        }
    }

    func closePopover() {
        popover.performClose(nil)
        if let m = eventMonitor { NSEvent.removeMonitor(m); eventMonitor = nil }
    }
}

// MARK: - Entry Point

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
