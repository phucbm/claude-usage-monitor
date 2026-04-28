import SwiftUI

struct AddAccountForm: View {
    @Binding var label: String
    @Binding var cookie: String
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("NEW ACCOUNT")
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

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text("LABEL")
                        .font(T.mono(12, weight: .bold))
                        .foregroundColor(T.muted)
                        .tracking(1)
                        .frame(width: 52, alignment: .trailing)
                    TextField("e.g. Work, Personal", text: $label)
                        .textFieldStyle(.plain)
                        .font(T.mono(12))
                        .padding(6)
                        .overlay(Rectangle().stroke(T.ink.opacity(0.25), lineWidth: T.border))
                }

                Text("SESSION COOKIE")
                    .font(T.mono(12, weight: .bold))
                    .foregroundColor(T.muted)
                    .tracking(1)

                VStack(alignment: .leading, spacing: 3) {
                    Text("1. Go to Settings > Usage on claude.ai")
                    Text("2. Press Cmd+Option+I → Network tab")
                    Text("3. Refresh page, click the 'usage' request")
                    Text("4. Copy 'Cookie' value from Request Headers")
                }
                .font(T.mono(12))
                .foregroundColor(T.muted)

                PasteableTextField(text: $cookie, placeholder: "Paste full cookie string here...")
                    .frame(height: 60)
                    .overlay(Rectangle().stroke(T.ink.opacity(0.25), lineWidth: T.border))

                HStack(spacing: 8) {
                    Button(action: onSave) {
                        Text("SAVE ACCOUNT")
                            .font(T.mono(12, weight: .bold))
                            .foregroundColor(T.paper)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(cookie.isEmpty ? T.ink.opacity(0.3) : T.primary)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(cookie.isEmpty)

                    Button(action: onCancel) {
                        Text("CANCEL")
                            .font(T.mono(12))
                            .foregroundColor(T.muted)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .overlay(Rectangle().stroke(T.ink.opacity(0.2), lineWidth: T.border))
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(12)
        }
        .overlay(Rectangle().stroke(T.ink.opacity(0.18), lineWidth: T.border))
    }
}
