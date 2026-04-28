import SwiftUI
import AppKit

struct SettingsSection: View {
    @ObservedObject var accountsManager: AccountsManager

    var body: some View {
        GroupBox("General") {
            VStack(alignment: .leading, spacing: 12) {
                Toggle(isOn: Binding(
                    get: { accountsManager.openAtLogin },
                    set: { v in accountsManager.openAtLogin = v; accountsManager.saveSettings() }
                )) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Open at Login").font(.footnote)
                        Text("Launch automatically when you log in").font(.caption2).foregroundColor(.secondary)
                    }
                }.toggleStyle(.checkbox)

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Toggle(isOn: Binding(
                        get: { accountsManager.notificationsEnabled },
                        set: { v in accountsManager.notificationsEnabled = v; accountsManager.saveSettings() }
                    )) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Enable Notifications").font(.footnote)
                            Text("Alerts at 25%, 50%, 75%, and 90% session usage")
                                .font(.caption2).foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }.toggleStyle(.checkbox)
                    Button("Test Notification") { accountsManager.sendTestNotification() }
                        .buttonStyle(.bordered).controlSize(.small)
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
                            Text("Keyboard Shortcut (⌘U)").font(.footnote)
                            Text("Toggle popup from anywhere. Disable if it conflicts with other apps.")
                                .font(.caption2).foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }.toggleStyle(.switch)

                    if accountsManager.shortcutEnabled && !accountsManager.isAccessibilityEnabled {
                        Button("Grant Accessibility Permission") {
                            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
                        }.buttonStyle(.borderedProminent).controlSize(.small)
                        Text("Accessibility permission may be needed for the shortcut to work in all apps.")
                            .font(.caption2).foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
}
