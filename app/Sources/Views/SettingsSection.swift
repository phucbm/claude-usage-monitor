import SwiftUI
import AppKit

struct SettingsSection: View {
    @ObservedObject var accountsManager: AccountsManager
    @AppStorage("appearanceMode") private var appearanceMode = "auto"

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("GENERAL")

            settingRow(
                title: "Appearance",
                subtitle: "Override system light/dark preference"
            ) {
                appearancePicker
            }

            Rectangle().fill(T.ink.opacity(0.08)).frame(height: T.border)

            settingRow(
                title: "Open at Login",
                subtitle: "Launch automatically when you log in"
            ) {
                Toggle("", isOn: Binding(
                    get: { accountsManager.openAtLogin },
                    set: { v in accountsManager.openAtLogin = v; accountsManager.saveSettings() }
                ))
                .toggleStyle(.switch)
                .labelsHidden()
                .scaleEffect(0.75)
                .frame(height: 20)
            }

            Rectangle().fill(T.ink.opacity(0.08)).frame(height: T.border)

            settingRow(
                title: "Keyboard Shortcut (⌘U)",
                subtitle: "Toggle popup from anywhere. Disable if it conflicts with other apps."
            ) {
                Toggle("", isOn: Binding(
                    get: { accountsManager.shortcutEnabled },
                    set: { v in
                        accountsManager.shortcutEnabled = v
                        accountsManager.saveSettings()
                        (NSApplication.shared.delegate as? AppDelegate)?.setShortcutEnabled(v)
                    }
                ))
                .toggleStyle(.switch)
                .labelsHidden()
                .scaleEffect(0.75)
                .frame(height: 20)
            }

            if accountsManager.shortcutEnabled && !accountsManager.isAccessibilityEnabled {
                VStack(alignment: .leading, spacing: 6) {
                    Button("GRANT ACCESSIBILITY PERMISSION") {
                        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
                    }
                    .buttonStyle(.plain)
                    .font(T.mono(10, weight: .bold))
                    .foregroundColor(T.paper)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(T.primary)

                    Text("Accessibility permission may be needed for the shortcut to work in all apps.")
                        .font(T.mono(12))
                        .foregroundColor(T.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(12)
            }

            Spacer().frame(height: 16)

            sectionHeader("ABOUT")

            settingRow(title: "Author", subtitle: "github.com/phucbm") {
                Link("@phucbm", destination: URL(string: "https://github.com/phucbm")!)
                    .font(T.mono(12, weight: .bold))
                    .foregroundColor(T.primary)
            }

            Rectangle().fill(T.ink.opacity(0.08)).frame(height: T.border)

            settingRow(title: "Open Source", subtitle: "MIT License — contributions welcome") {
                Button(action: {
                    NSWorkspace.shared.open(URL(string: "https://github.com/phucbm/claude-usage-monitor")!)
                }) {
                    HStack(spacing: 5) {
                        Text("★")
                            .font(.system(size: 12))
                        Text("STAR ON GITHUB")
                            .font(T.mono(10, weight: .bold))
                    }
                    .foregroundColor(T.paper)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(T.ink)
                }
                .buttonStyle(.plain)
            }
        }
        .overlay(Rectangle().stroke(T.ink.opacity(0.18), lineWidth: T.border))
        .onAppear { applyAppearance(appearanceMode) }
        .onChange(of: appearanceMode) { applyAppearance($0) }
    }

    // MARK: - Appearance picker

    private var appearancePicker: some View {
        HStack(spacing: 0) {
            ForEach(["AUTO", "LIGHT", "DARK"], id: \.self) { mode in
                Button(action: { appearanceMode = mode.lowercased() }) {
                    Text(mode)
                        .font(T.mono(10, weight: .bold))
                        .foregroundColor(appearanceMode == mode.lowercased() ? T.paper : T.ink)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(appearanceMode == mode.lowercased() ? T.ink : Color.clear)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .overlay(Rectangle().stroke(T.ink.opacity(0.3), lineWidth: T.border))
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(T.mono(12, weight: .bold))
            .foregroundColor(T.muted)
            .tracking(2)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(T.ink.opacity(0.04))
            .overlay(alignment: .bottom) {
                Rectangle().fill(T.ink.opacity(0.08)).frame(height: T.border)
            }
    }

    private func settingRow<C: View>(title: String, subtitle: String, @ViewBuilder control: () -> C) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(T.mono(13, weight: .medium))
                    .foregroundColor(T.ink)
                Text(subtitle)
                    .font(T.mono(12))
                    .foregroundColor(T.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            control()
        }
        .padding(12)
    }

    private func applyAppearance(_ mode: String) {
        switch mode {
        case "light": NSApp.appearance = NSAppearance(named: .aqua)
        case "dark":  NSApp.appearance = NSAppearance(named: .darkAqua)
        default:      NSApp.appearance = nil
        }
    }
}
