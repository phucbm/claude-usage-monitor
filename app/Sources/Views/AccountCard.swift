import SwiftUI
import AppKit

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
            VStack(alignment: .leading, spacing: 12) {
                if let error = account.errorMessage {
                    Text(error).font(.callout).foregroundColor(.orange)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else if account.hasFetchedData {
                    usageRings

                    if let updated = account.lastUpdated {
                        Text("Updated \(formatTime(updated))")
                            .font(.caption).foregroundColor(.secondary)
                    }
                } else {
                    Text("Fetching...").font(.callout).foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        } label: {
            HStack(spacing: 6) {
                Circle()
                    .fill(isActive ? Color.green : Color.secondary.opacity(0.4))
                    .frame(width: 8, height: 8)

                if isEditingLabel {
                    TextField("Label", text: $editLabel)
                        .textFieldStyle(.roundedBorder)
                        .font(.subheadline)
                        .frame(maxWidth: 140)
                        .onSubmit { commitRename() }
                    Button("Save") { commitRename() }
                        .buttonStyle(.borderless).font(.footnote).foregroundColor(.accentColor)
                    Button("Cancel") { isEditingLabel = false }
                        .buttonStyle(.borderless).font(.footnote).foregroundColor(.secondary)
                } else {
                    Text(account.label).font(.subheadline).fontWeight(isActive ? .semibold : .medium)
                    Button(action: { editLabel = account.label; isEditingLabel = true }) {
                        Image(systemName: "pencil").font(.caption)
                    }
                    .buttonStyle(.borderless).foregroundColor(.secondary)
                }

                Spacer()

                if !isEditingLabel {
                    Toggle(isOn: Binding(get: { account.showInMenuBar }, set: { onToggleMenuBar($0) })) {
                        Text("Menu bar").font(.caption2)
                    }
                    .toggleStyle(.checkbox)
                    .help("Show in menu bar")
                    Button(action: onRefresh) {
                        Image(systemName: "arrow.clockwise").font(.footnote)
                    }.buttonStyle(.borderless).foregroundColor(.secondary)
                    Button(action: onDelete) {
                        Image(systemName: "trash").font(.footnote)
                    }.buttonStyle(.borderless).foregroundColor(.secondary)
                }
            }
        }
    }

    // MARK: - Usage rings

    private var usageRings: some View {
        HStack(alignment: .center, spacing: 16) {
            Canvas { ctx, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let outerRadius: CGFloat = 50
                let innerRadius: CGFloat = 33
                let lineWidth: CGFloat = 9
                let trackColor = Color.secondary.opacity(0.15)
                let start = Angle.degrees(-90)

                let sessionPct = min(max(account.sessionPercentage, 0), 1)
                let weeklyPct  = min(max(account.weeklyPercentage,  0), 1)

                // Outer track
                ctx.stroke(
                    Path { p in p.addArc(center: center, radius: outerRadius,
                                         startAngle: start, endAngle: start + .degrees(360), clockwise: false) },
                    with: .color(trackColor),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                // Outer fill — weekly (green)
                if weeklyPct > 0 {
                    ctx.stroke(
                        Path { p in p.addArc(center: center, radius: outerRadius,
                                             startAngle: start, endAngle: start + .degrees(360 * weeklyPct), clockwise: false) },
                        with: .color(Color(nsColor: .systemGreen)),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                }
                // Inner track
                ctx.stroke(
                    Path { p in p.addArc(center: center, radius: innerRadius,
                                         startAngle: start, endAngle: start + .degrees(360), clockwise: false) },
                    with: .color(trackColor),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                // Inner fill — session (orange)
                if sessionPct > 0 {
                    ctx.stroke(
                        Path { p in p.addArc(center: center, radius: innerRadius,
                                             startAngle: start, endAngle: start + .degrees(360 * sessionPct), clockwise: false) },
                        with: .color(Color(nsColor: .systemOrange)),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                }
            }
            .frame(width: 118, height: 118)

            VStack(alignment: .leading, spacing: 2) {
                // Session
                Text("Current session")
                    .font(.caption).foregroundColor(.secondary)

                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text("\(Int(min(account.sessionPercentage, 1.0) * 100))")
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(nsColor: .systemOrange))
                        .monospacedDigit()
                    if let date = account.sessionResetsAt {
                        Text("% used (\(formatRelative(date)))")
                            .font(.footnote).foregroundColor(.secondary)
                    } else {
                        Text("% used")
                            .font(.footnote).foregroundColor(.secondary)
                    }
                }

                Rectangle()
                    .fill(Color.secondary.opacity(0.25))
                    .frame(height: 0.5)
                    .padding(.vertical, 6)

                // Weekly
                Text("Weekly limits")
                    .font(.caption).foregroundColor(.secondary)

                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text("\(Int(min(account.weeklyPercentage, 1.0) * 100))")
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(nsColor: .systemGreen))
                        .monospacedDigit()
                    if let date = account.weeklyResetsAt {
                        Text("% used (\(formatAbsolute(date)))")
                            .font(.footnote).foregroundColor(.secondary)
                    } else {
                        Text("% used")
                            .font(.footnote).foregroundColor(.secondary)
                    }
                }
            }

            Spacer(minLength: 0)
        }
    }

    // MARK: - Helpers

    private func commitRename() {
        let trimmed = editLabel.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty { onRename(trimmed) }
        isEditingLabel = false
    }

    private func formatTime(_ date: Date) -> String {
        let f = DateFormatter(); f.timeStyle = .short; return f.string(from: date)
    }

    private func formatRelative(_ date: Date) -> String {
        let secs = date.timeIntervalSince(Date())
        guard secs > 0 else { return "Resetting soon" }
        let h = Int(secs) / 3600
        let m = (Int(secs) % 3600) / 60
        return h > 0 ? "Resets in \(h) hr \(m) min" : "Resets in \(m) min"
    }

    private func formatAbsolute(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEE h:mm a"
        return "Resets \(f.string(from: date))"
    }
}
