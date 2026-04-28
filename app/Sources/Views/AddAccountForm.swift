import SwiftUI

struct AddAccountForm: View {
    @Binding var label: String
    @Binding var cookie: String
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        GroupBox("New Account") {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text("Label:").font(.footnote).frame(width: 45, alignment: .trailing)
                    TextField("e.g. Work, Personal", text: $label)
                        .textFieldStyle(.roundedBorder).font(.footnote)
                }

                Text("Session Cookie:").font(.footnote)

                VStack(alignment: .leading, spacing: 3) {
                    Text("1. Go to Settings > Usage on claude.ai")
                    Text("2. Press Cmd+Option+I → Network tab")
                    Text("3. Refresh page, click the 'usage' request")
                    Text("4. Copy 'Cookie' value from Request Headers")
                }
                .font(.caption2).foregroundColor(.secondary)

                PasteableTextField(text: $cookie, placeholder: "Paste full cookie string here...")
                    .frame(height: 60).cornerRadius(4)

                HStack(spacing: 8) {
                    Button("Save Account") { onSave() }
                        .buttonStyle(.borderedProminent).controlSize(.small).disabled(cookie.isEmpty)
                    Button("Cancel") { onCancel() }
                        .buttonStyle(.bordered).controlSize(.small)
                }
            }
        }
    }
}
