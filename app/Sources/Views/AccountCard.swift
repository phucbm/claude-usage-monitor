import SwiftUI

struct AccountCard: View {
    let account: Account
    let isActive: Bool
    let onSetActive: () -> Void
    let onDelete: () -> Void
    let onRefresh: () -> Void
    let onRename: (String) -> Void
    let onToggleMenuBar: (Bool) -> Void

    @State private var isEditingLabel = false
    @State private var editLabel = ""

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                if let error = account.errorMessage {
                    Text(error).font(.footnote).foregroundColor(.orange)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else if account.hasFetchedData {
                    // SECTION 1 — Plan usage limits
                    sectionHeader("Plan usage limits")
                    UsageBar(label: "Current session",
                             percentage: account.sessionPercentage,
                             resetsAt: account.sessionResetsAt,
                             resetStyle: .relative)

                    // SECTION 2 — Weekly limits
                    Divider().padding(.vertical, 2)
                    sectionHeader("Weekly limits")
                    UsageBar(label: "All models",
                             percentage: account.weeklyPercentage,
                             resetsAt: account.weeklyResetsAt,
                             resetStyle: .absolute)
                    if account.hasWeeklySonnet {
                        UsageBar(label: "Sonnet",
                                 percentage: account.weeklySonnetPercentage,
                                 resetsAt: account.weeklySonnetResetsAt,
                                 resetStyle: .absolute)
                    }

                    if let updated = account.lastUpdated {
                        Text("Updated \(formatTime(updated))")
                            .font(.caption2).foregroundColor(.secondary)
                            .padding(.top, 2)
                    }
                } else {
                    Text("Fetching...").font(.footnote).foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Menu bar visibility toggle
                Toggle(isOn: Binding(get: { account.showInMenuBar }, set: { onToggleMenuBar($0) })) {
                    Text("Show in menu bar").font(.caption2).foregroundColor(.secondary)
                }
                .toggleStyle(.checkbox)
            }
        } label: {
            HStack(spacing: 6) {
                Circle()
                    .fill(isActive ? Color.green : Color.secondary.opacity(0.4))
                    .frame(width: 7, height: 7)

                if isEditingLabel {
                    TextField("Label", text: $editLabel)
                        .textFieldStyle(.roundedBorder)
                        .font(.callout)
                        .frame(maxWidth: 120)
                        .onSubmit { commitRename() }
                    Button("Save") { commitRename() }
                        .buttonStyle(.borderless)
                        .font(.caption)
                        .foregroundColor(.accentColor)
                    Button("Cancel") { isEditingLabel = false }
                        .buttonStyle(.borderless)
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text(account.label).font(.callout).fontWeight(isActive ? .semibold : .regular)
                    Button(action: { editLabel = account.label; isEditingLabel = true }) {
                        Image(systemName: "pencil").font(.caption2)
                    }
                    .buttonStyle(.borderless).foregroundColor(.secondary)
                }

                Spacer()

                if !isActive && !isEditingLabel {
                    Button("Set Active") { onSetActive() }
                        .buttonStyle(.borderless).font(.caption).foregroundColor(.accentColor)
                }
                if !isEditingLabel {
                    Button(action: onRefresh) {
                        Image(systemName: "arrow.clockwise").font(.caption)
                    }.buttonStyle(.borderless).foregroundColor(.secondary)
                    Button(action: onDelete) {
                        Image(systemName: "trash").font(.caption)
                    }.buttonStyle(.borderless).foregroundColor(.secondary)
                }
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(.secondary)
            .kerning(0.4)
    }

    private func commitRename() {
        let trimmed = editLabel.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty { onRename(trimmed) }
        isEditingLabel = false
    }

    private func formatTime(_ date: Date) -> String {
        let f = DateFormatter(); f.timeStyle = .short; return f.string(from: date)
    }
}
