import SwiftUI

enum ResetTimeStyle {
    case relative
    case absolute
}

struct UsageBar: View {
    let label: String
    let percentage: Double
    let resetsAt: Date?
    let resetStyle: ResetTimeStyle

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(label.uppercased())
                    .font(T.mono(10, weight: .medium))
                    .foregroundColor(T.ink)
                    .tracking(1)
                Spacer()
                Text("\(Int(min(percentage, 1.0) * 100))%")
                    .font(T.mono(10, weight: .bold))
                    .foregroundColor(T.muted)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(T.ink.opacity(0.1))
                        .frame(height: 4)
                    Rectangle()
                        .fill(barColor(for: percentage))
                        .frame(width: geo.size.width * min(max(percentage, 0), 1.0), height: 4)
                }
            }
            .frame(height: 4)

            if let date = resetsAt {
                Text(formatReset(date))
                    .font(T.mono(9))
                    .foregroundColor(T.muted)
            }
        }
    }

    private func barColor(for p: Double) -> Color {
        if p < 0.5 { return T.ink.opacity(0.6) }
        if p < 0.8 { return T.ink.opacity(0.8) }
        return T.primary
    }

    private func formatReset(_ date: Date) -> String {
        switch resetStyle {
        case .relative:
            let secs = date.timeIntervalSince(Date())
            guard secs > 0 else { return "Resetting soon" }
            let h = Int(secs) / 3600
            let m = (Int(secs) % 3600) / 60
            return h > 0 ? "Resets in \(h)h \(m)m" : "Resets in \(m)m"
        case .absolute:
            let f = DateFormatter()
            f.dateFormat = "EEE h:mm a"
            return "Resets \(f.string(from: date))"
        }
    }
}
