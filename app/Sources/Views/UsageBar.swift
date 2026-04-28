import SwiftUI

enum ResetTimeStyle {
    case relative   // "Resets in X hr Y min"
    case absolute   // "Resets Sat 4:00 PM"
}

struct UsageBar: View {
    let label: String
    let percentage: Double
    let resetsAt: Date?
    let resetStyle: ResetTimeStyle

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Label + percentage
            HStack {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(Int(min(percentage, 1.0) * 100))% used")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            // Custom 5pt capsule bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.15))
                        .frame(height: 5)
                    Capsule()
                        .fill(barColor(for: percentage))
                        .frame(width: geo.size.width * min(max(percentage, 0), 1.0), height: 5)
                }
            }
            .frame(height: 5)

            // Reset subtitle
            if let date = resetsAt {
                Text(formatReset(date))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }

    private func barColor(for p: Double) -> Color {
        if p < 0.5 { return Color(red: 0.204, green: 0.780, blue: 0.349) } // #34C759
        if p < 0.8 { return Color(red: 1.000, green: 0.624, blue: 0.039) } // #FF9F0A
        return Color(red: 1.000, green: 0.231, blue: 0.188)                // #FF3B30
    }

    private func formatReset(_ date: Date) -> String {
        switch resetStyle {
        case .relative:
            let secs = date.timeIntervalSince(Date())
            guard secs > 0 else { return "Resetting soon" }
            let h = Int(secs) / 3600
            let m = (Int(secs) % 3600) / 60
            return h > 0 ? "Resets in \(h) hr \(m) min" : "Resets in \(m) min"
        case .absolute:
            let f = DateFormatter()
            f.dateFormat = "EEE h:mm a"
            return "Resets \(f.string(from: date))"
        }
    }
}
