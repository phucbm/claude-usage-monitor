import SwiftUI
import AppKit
import Carbon

private let kPanelOriginKey = "FloatingPanelOrigin"
private let kPanelWidth: CGFloat = 420
private let kPanelHeight: CGFloat = 520
private let kPanelMargin: CGFloat = 20
private let kCornerRadius: CGFloat = 0

// MARK: - FloatingPanel

class FloatingPanel: NSPanel {
    weak var appDelegate: AppDelegate?

    override var canBecomeKey: Bool { true }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // Escape
            appDelegate?.closePanel()
            return
        }
        super.keyDown(with: event)
    }
}

// MARK: - AppDelegate

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var statusItem: NSStatusItem!
    var panel: FloatingPanel!
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
        setupPanel()

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
        let font = NSFont(name: "JetBrains Mono", size: 10) ?? NSFont.monospacedDigitSystemFont(ofSize: 10, weight: .bold)
        let orange = NSColor(red: 0xEA/255, green: 0x60/255, blue: 0x49/255, alpha: 1.0)
        let bg = NSColor(red: 0xEA/255, green: 0x60/255, blue: 0x49/255, alpha: 0.13)
        let hPad: CGFloat = 5
        let height: CGFloat = 16
        let spacing: CGFloat = 4
        let radius: CGFloat = 0

        let attrs: [NSAttributedString.Key: Any] = [.font: font]

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

                let path = NSBezierPath(roundedRect: badgeRect, xRadius: radius, yRadius: radius)
                bg.setFill()
                path.fill()

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

    // MARK: - Panel Setup

    private func defaultPanelFrame() -> NSRect {
        guard let screen = NSScreen.main else {
            return NSRect(x: 100, y: 100, width: kPanelWidth, height: kPanelHeight)
        }
        let vis = screen.visibleFrame
        let x = vis.maxX - kPanelWidth - kPanelMargin
        let y = vis.maxY - kPanelHeight - kPanelMargin
        return NSRect(x: x, y: y, width: kPanelWidth, height: kPanelHeight)
    }

    private func restoredPanelFrame() -> NSRect {
        if let data = UserDefaults.standard.data(forKey: kPanelOriginKey),
           let point = try? JSONDecoder().decode(CGPoint.self, from: data) {
            return NSRect(origin: point, size: NSSize(width: kPanelWidth, height: kPanelHeight))
        }
        return defaultPanelFrame()
    }

    private func savePanelPosition() {
        if let data = try? JSONEncoder().encode(panel.frame.origin) {
            UserDefaults.standard.set(data, forKey: kPanelOriginKey)
        }
    }

    private func setupPanel() {
        let frame = restoredPanelFrame()

        panel = FloatingPanel(
            contentRect: frame,
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )
        panel.appDelegate = self
        panel.delegate = self
        panel.level = .floating
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.isMovableByWindowBackground = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        let hostingController = NSHostingController(
            rootView: UsageView(accountsManager: accountsManager)
        )
        hostingController.view.frame = NSRect(origin: .zero, size: frame.size)
        hostingController.view.autoresizingMask = [.width, .height]

        panel.contentView = hostingController.view
    }

    // MARK: - NSWindowDelegate

    func windowDidMove(_ notification: Notification) {
        savePanelPosition()
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
            DispatchQueue.main.async { d.togglePanel() }
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

    // MARK: - Panel

    @objc func quitApp() { NSApplication.shared.terminate(nil) }

    @objc func togglePanel() { panel.isVisible ? closePanel() : openPanel() }

    @objc func handleClick() {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseUp {
            let menu = NSMenu()
            let item = NSMenuItem(title: "Toggle Usage (⌘U)", action: #selector(togglePanel), keyEquivalent: "u")
            item.keyEquivalentModifierMask = .command
            menu.addItem(item)
            menu.addItem(.separator())
            menu.addItem(NSMenuItem(title: "Quit Claude Usage Monitor", action: #selector(quitApp), keyEquivalent: "q"))
            statusItem.menu = menu
            statusItem.button?.performClick(nil)
            statusItem.menu = nil
        } else {
            togglePanel()
        }
    }

    func openPanel() {
        DispatchQueue.main.async { self.accountsManager.updatePercentagesForAll() }
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            guard let self = self, self.panel.isVisible else { return }
            self.closePanel()
        }
    }

    func closePanel() {
        panel.orderOut(nil)
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
