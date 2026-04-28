import SwiftUI

struct UsageRings: View {
    let sessionPct: Double
    let weeklyPct: Double
    let resetLabel: String?

    var body: some View {
        ZStack {
            Canvas { ctx, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let outerRadius: CGFloat = 50
                let innerRadius: CGFloat = 33
                let lw: CGFloat = 9
                let track = T.ink.opacity(0.08)
                let s = StrokeStyle(lineWidth: lw, lineCap: T.ringLineCap)

                ctx.stroke(arc(center, outerRadius, 1.0), with: .color(track), style: s)
                if weeklyPct > 0 {
                    ctx.stroke(arc(center, outerRadius, weeklyPct), with: .color(T.primary), style: s)
                }
                ctx.stroke(arc(center, innerRadius, 1.0), with: .color(track), style: s)
                if sessionPct > 0 {
                    ctx.stroke(arc(center, innerRadius, sessionPct), with: .color(T.ink), style: s)
                }
            }
            .frame(width: 118, height: 118)

            if let label = resetLabel {
                Text(label)
                    .font(T.mono(11, weight: .bold))
                    .foregroundColor(T.primary)
            }
        }
    }

    private func arc(_ center: CGPoint, _ radius: CGFloat, _ pct: Double) -> Path {
        let start = Angle.degrees(-90)
        return Path { p in
            p.addArc(center: center, radius: radius,
                     startAngle: start,
                     endAngle: start + .degrees(360 * min(max(pct, 0), 1)),
                     clockwise: false)
        }
    }
}
