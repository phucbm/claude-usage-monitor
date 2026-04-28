import SwiftUI

struct UsageView: View {
    @ObservedObject var accountsManager: AccountsManager
    @State private var selectedTab = 0
    @State private var showingAddAccount = false
    @State private var newLabel = ""
    @State private var newCookie = ""

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                Text("Accounts").tag(0)
                Text("Settings").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            Divider()

            ScrollView(.vertical, showsIndicators: false) {
                if selectedTab == 0 {
                    accountsTab
                } else {
                    SettingsSection(accountsManager: accountsManager)
                        .padding(16)
                }
            }
            .frame(width: 420)
        }
        .background(.ultraThinMaterial)
        .frame(width: 420)
        .onAppear { accountsManager.updatePercentagesForAll() }
    }

    @ViewBuilder
    private var accountsTab: some View {
        VStack(alignment: .leading, spacing: 10) {
            if accountsManager.accounts.isEmpty {
                OnboardingView(accountsManager: accountsManager)
            } else {
                HStack {
                    Text("Accounts")
                        .font(.headline)
                    Spacer()
                    if accountsManager.isLoading {
                        ProgressView().scaleEffect(0.7).frame(width: 16, height: 16)
                    } else {
                        Button(action: { accountsManager.fetchAllAccounts() }) {
                            Image(systemName: "arrow.clockwise")
                        }
                        .buttonStyle(.borderless)
                        .help("Refresh all")
                        Button(action: { showingAddAccount = true }) {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(.borderless)
                        .help("Add account")
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
                        onRefresh: { accountsManager.fetchUsage(for: account.id) },
                        onRename: { accountsManager.renameAccount(id: account.id, label: $0) },
                        onToggleMenuBar: { accountsManager.toggleMenuBar(id: account.id, show: $0) }
                    )
                }
            }
        }
        .padding(16)
    }
}
