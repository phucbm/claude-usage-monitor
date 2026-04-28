import SwiftUI
import AppKit

struct AccountCard: View {
    let account: Account
    let isActive: Bool
    let onSetActive: () -> Void
    let onDelete: () -> Void
    let onRename: (String) -> Void
    let onToggleMenuBar: (Bool) -> Void

    @State private var isEditingLabel = false
    @State private var editLabel = ""
    @State private var showDeleteAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 6) {
                Rectangle()
                    .fill(isActive ? T.primary : T.ink.opacity(0.25))
                    .frame(width: 7, height: 7)

                if isEditingLabel {
                    TextField("Label", text: $editLabel)
                        .font(T.mono(12))
                        .textFieldStyle(.plain)
                        .padding(4)
                        .overlay(Rectangle().stroke(T.ink.opacity(0.3), lineWidth: T.border))
                        .frame(maxWidth: 140)
                        .onSubmit { commitRename() }
                    Button(action: commitRename) {
                        Text("SAVE")
                            .font(T.mono(10, weight: .bold))
                            .foregroundColor(T.primary)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    Button(action: { isEditingLabel = false }) {
                        Text("CANCEL")
                            .font(T.mono(10))
                            .foregroundColor(T.muted)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                } else {
                    Button(action: { editLabel = account.label; isEditingLabel = true }) {
                        HStack(spacing: 4) {
                            Text(account.label.uppercased())
                                .font(T.mono(11, weight: isActive ? .bold : .medium))
                                .foregroundColor(T.ink)
                            Image(systemName: "pencil")
                                .font(.caption2)
                                .foregroundColor(T.muted)
                        }
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                if !isEditingLabel {
                    Toggle(isOn: Binding(get: { account.showInMenuBar }, set: { onToggleMenuBar($0) })) {
                        Text("MENU BAR").font(T.mono(14)).foregroundColor(T.muted)
                    }
                    .toggleStyle(.switch)
                    .scaleEffect(0.75)
                    .frame(height: 20)

                    iconButton("trash") { showDeleteAlert = true }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(T.ink.opacity(0.04))

            Rectangle().fill(T.ink.opacity(0.12)).frame(height: T.border)

            // Body
            Group {
                if let error = account.errorMessage {
                    Text(error)
                        .font(T.mono(11))
                        .foregroundColor(T.primary)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else if account.hasFetchedData {
                    usageContent
                } else {
                    Text("FETCHING...")
                        .font(T.mono(11))
                        .foregroundColor(T.muted)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            // Billing warning
            if account.billingStatus != .ok {
                Rectangle().fill(T.ink.opacity(0.12)).frame(height: T.border)
                HStack(spacing: 8) {
                    Image(systemName: account.billingStatus.icon)
                        .font(.caption)
                        .foregroundColor(billingColor)
                    Text(account.billingStatus.message.uppercased())
                        .font(T.mono(9, weight: .bold))
                        .foregroundColor(billingColor)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(billingColor.opacity(0.07))
            }
        }
        .overlay(Rectangle().stroke(T.ink.opacity(0.18), lineWidth: T.border))
        .alert("Delete \"\(account.label)\"?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) { onDelete() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove the account and its data from the app.")
        }
    }

    // MARK: - Usage content

    private var usageContent: some View {
        HStack(alignment: .center, spacing: 16) {
            UsageRings(
                sessionPct: account.sessionPercentage,
                weeklyPct: account.weeklyPercentage,
                resetLabel: timeToReset(account.sessionResetsAt)
            )

            VStack(alignment: .leading, spacing: 2) {
                statBlock(
                    label: "SESSION",
                    pct: account.sessionPercentage,
                    color: T.ink,
                    subtitle: account.sessionResetsAt.map { formatRelative($0) }
                )

                Rectangle().fill(T.ink.opacity(0.12)).frame(height: T.border).padding(.vertical, 8)

                statBlock(
                    label: "WEEKLY",
                    pct: account.weeklyPercentage,
                    color: T.primary,
                    subtitle: account.weeklyResetsAt.map { formatAbsolute($0) }
                )
            }

            Spacer(minLength: 0)
        }
        .padding(12)
    }

    private func statBlock(label: String, pct: Double, color: Color, subtitle: String?) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(label)
                .font(T.mono(9))
                .foregroundColor(T.muted)
                .tracking(1.5)

            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text("\(Int(min(pct, 1.0) * 100))")
                    .font(T.mono(30, weight: .bold))
                    .foregroundColor(color)
                Text("%")
                    .font(T.mono(12))
                    .foregroundColor(T.muted)
                if let sub = subtitle {
                    Text(sub)
                        .font(T.mono(10))
                        .foregroundColor(T.muted)
                        .lineLimit(1)
                }
            }
        }
    }

    // MARK: - Helpers

    private var billingColor: Color {
        switch account.billingStatus {
        case .paymentRequired: return Color(red: 0xF5/255, green: 0x9E/255, blue: 0x0B/255)
        case .sessionExpired, .forbidden: return T.primary
        case .rateLimited: return Color(red: 0xF5/255, green: 0x9E/255, blue: 0x0B/255)
        case .ok: return .clear
        }
    }

    private func iconButton(_ systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName).font(.footnote)
        }
        .buttonStyle(.plain)
        .foregroundColor(T.muted)
    }

    private func commitRename() {
        let trimmed = editLabel.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty { onRename(trimmed) }
        isEditingLabel = false
    }

    private func timeToReset(_ date: Date?) -> String? {
        guard let date else { return nil }
        let secs = date.timeIntervalSince(Date())
        guard secs > 0 else { return nil }
        let h = Int(secs) / 3600
        let m = (Int(secs) % 3600) / 60
        return h > 0 ? "\(h)h\(m)m" : "\(m)m"
    }

    private func formatRelative(_ date: Date) -> String {
        let secs = date.timeIntervalSince(Date())
        guard secs > 0 else { return "· Resetting soon" }
        let h = Int(secs) / 3600
        let m = (Int(secs) % 3600) / 60
        let f = DateFormatter(); f.dateFormat = "h:mm a"
        let at = f.string(from: date)
        return h > 0 ? "· Resets in \(h)h \(m)m (\(at))" : "· Resets in \(m)m (\(at))"
    }

    private func formatAbsolute(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEE h:mm a"
        return "· Resets \(f.string(from: date))"
    }
}
