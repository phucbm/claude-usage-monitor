import SwiftUI

struct OnboardingView: View {
    @ObservedObject var accountsManager: AccountsManager
    @State private var label = ""
    @State private var cookie = ""
    @State private var showingForm = false

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Text("Track your Claude.ai session and weekly usage directly from the menu bar. Add your first account to get started.")
                    .font(.footnote).foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                if !showingForm {
                    Button("Add Your First Account") { showingForm = true }
                        .buttonStyle(.borderedProminent).controlSize(.regular)
                } else {
                    AddAccountForm(label: $label, cookie: $cookie) {
                        guard !cookie.isEmpty else { return }
                        accountsManager.addAccount(label: label, cookie: cookie)
                        label = ""; cookie = ""; showingForm = false
                    } onCancel: {
                        label = ""; cookie = ""; showingForm = false
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } label: {
            Text("Welcome to Claude Usage Monitor!")
                .font(.callout).fontWeight(.semibold)
        }
    }
}
