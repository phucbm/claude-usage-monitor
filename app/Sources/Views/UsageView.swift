import SwiftUI

struct UsageView: View {
    @ObservedObject var accountsManager: AccountsManager
    @State private var selectedTab = 0
    @State private var showingAddAccount = false
    @State private var newLabel = ""
    @State private var newCookie = ""

    var body: some View {
        VStack(spacing: 0) {
            tabBar

            Rectangle().fill(T.ink.opacity(0.18)).frame(height: T.border)

            ScrollView(.vertical, showsIndicators: false) {
                if selectedTab == 0 {
                    accountsTab
                } else {
                    SettingsSection(accountsManager: accountsManager)
                        .padding(16)
                }
            }
            .frame(width: 440)

            Rectangle().fill(T.ink.opacity(0.18)).frame(height: T.border)

            Link("github.com/phucbm/claude-usage-monitor",
                 destination: URL(string: "https://github.com/phucbm/claude-usage-monitor")!)
                .font(T.mono(9, weight: .bold))
                .foregroundColor(T.muted)
                .padding(.vertical, 8)
        }
        .background(T.paper)
        .frame(width: 440)
        .onAppear { accountsManager.updatePercentagesForAll() }
    }

    // MARK: - Tab bar

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabButton("ACCOUNTS", tag: 0)
            Rectangle().fill(T.ink.opacity(0.18)).frame(width: T.border)
            tabButton("SETTINGS", tag: 1)
        }
        .frame(height: 38)
    }

    private func tabButton(_ title: String, tag: Int) -> some View {
        Button(action: { selectedTab = tag }) {
            Text(title)
                .font(T.mono(12, weight: selectedTab == tag ? .bold : .medium))
                .foregroundColor(selectedTab == tag ? T.ink : T.muted)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(selectedTab == tag ? T.ink.opacity(0.06) : Color.clear)
                .contentShape(Rectangle())
                .overlay(alignment: .bottom) {
                    if selectedTab == tag {
                        Rectangle().fill(T.primary).frame(height: 2)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Accounts tab

    @ViewBuilder
    private var accountsTab: some View {
        VStack(alignment: .leading, spacing: 10) {
            if accountsManager.accounts.isEmpty {
                OnboardingView(accountsManager: accountsManager)
            } else {
                HStack(spacing: 8) {
                    Text("ACCOUNTS")
                        .font(T.mono(10, weight: .bold))
                        .foregroundColor(T.muted)
                        .tracking(1.5)
                    Spacer()
                    if accountsManager.isLoading {
                        Text("LOADING...").font(T.mono(10)).foregroundColor(T.muted)
                    } else {
                        if let time = latestUpdate {
                            Text(formatTime(time))
                                .font(T.mono(10))
                                .foregroundColor(T.muted)
                        }
                        labelledButton(icon: "arrow.clockwise", label: "REFRESH") {
                            accountsManager.fetchAllAccounts()
                        }
                        labelledButton(icon: "plus", label: "ADD ACCOUNT") {
                            showingAddAccount = true
                        }
                    }
                }

                if showingAddAccount {
                    AddAccountForm(label: $newLabel, cookie: $newCookie) {
                        guard !newCookie.isEmpty else { return }
                        accountsManager.addAccount(label: newLabel, cookie: newCookie)
                        newLabel = ""; newCookie = ""; showingAddAccount = false
                    } onCancel: {
                        newLabel = ""; newCookie = ""; showingAddAccount = false
                    }
                }

                ForEach(accountsManager.accounts) { account in
                    AccountCard(
                        account: account,
                        isActive: accountsManager.activeAccountId == account.id,
                        onSetActive: { accountsManager.setActiveAccount(id: account.id) },
                        onDelete: { accountsManager.deleteAccount(id: account.id) },
                        onRename: { accountsManager.renameAccount(id: account.id, label: $0) },
                        onToggleMenuBar: { accountsManager.toggleMenuBar(id: account.id, show: $0) }
                    )
                }
            }
        }
        .padding(16)
    }

    // MARK: - Helpers

    private var latestUpdate: Date? {
        accountsManager.accounts.compactMap(\.lastUpdated).max()
    }

    private func formatTime(_ date: Date) -> String {
        let f = DateFormatter(); f.timeStyle = .short; return f.string(from: date)
    }

    private func labelledButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.caption2)
                Text(label).font(T.mono(10, weight: .bold))
            }
            .foregroundColor(T.ink)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .frame(minWidth: 44)
            .overlay(Rectangle().stroke(T.ink.opacity(0.2), lineWidth: T.border))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
