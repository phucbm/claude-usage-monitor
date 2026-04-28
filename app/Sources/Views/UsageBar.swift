import SwiftUI

struct UsageBar: View {
    let label: String
    let percentage: Double
    let resetsAt: Date?
    let includeDate: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(label).font(.caption)
                Spacer()
                if let date = resetsAt {
                    Text(formatResetTime(date)).font(.caption2).foregroundColor(.secondary)
                }
            }
            ProgressView(value: min(percentage, 1.0)).tint(colorFor(percentage))
            Text("\(Int(percentage * 100))% used").font(.caption2).foregroundColor(.secondary)
        }
    }

    private func colorFor(_ p: Double) -> Color {
        if p < 0.7 { return .green }
        if p < 0.9 { return .orange }
        return .red
    }

    private func formatResetTime(_ date: Date) -> String {
        let f = DateFormatter()
        if includeDate {
            f.dateFormat = "d MMM yyyy 'at' h:mm a"
            return "on \(f.string(from: date))"
        } else {
            f.timeStyle = .short
            f.dateStyle = .none
            return "at \(f.string(from: date))"
        }
    }
}
