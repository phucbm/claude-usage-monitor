import SwiftUI

struct OnboardingView: View {
    @ObservedObject var accountsManager: AccountsManager
    @State private var label = ""
    @State private var cookie = ""
    @State private var showingForm = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("WELCOME")
                .font(T.mono(9, weight: .bold))
                .foregroundColor(T.muted)
                .tracking(2)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(T.ink.opacity(0.04))
                .overlay(alignment: .bottom) {
                    Rectangle().fill(T.ink.opacity(0.08)).frame(height: T.border)
                }

            VStack(alignment: .leading, spacing: 12) {
                Text("Track your Claude.ai session and weekly usage directly from the menu bar. Add your first account to get started.")
                    .font(T.mono(11))
                    .foregroundColor(T.muted)
                    .fixedSize(horizontal: false, vertical: true)

                if !showingForm {
                    Button("+ ADD YOUR FIRST ACCOUNT") { showingForm = true }
                        .buttonStyle(.plain)
                        .font(T.mono(10, weight: .bold))
                        .foregroundColor(T.paper)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(T.primary)
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
            .padding(12)
        }
        .overlay(Rectangle().stroke(T.ink.opacity(0.18), lineWidth: T.border))
    }
}
