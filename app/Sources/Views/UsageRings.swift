import SwiftUI

struct UsageRings: View {
    let sessionPct: Double
    let weeklyPct: Double
    let resetLabel: String?
    let trigger: UUID

    @State private var animatedSession: Double = 0
    @State private var animatedWeekly: Double = 0

    private let lw: CGFloat = 9
    private let outerD: CGFloat = 100
    private let innerD: CGFloat = 66

    var body: some View {
        ZStack {
            Circle()
                .stroke(T.ink.opacity(0.08), style: StrokeStyle(lineWidth: lw, lineCap: T.ringLineCap))
                .frame(width: outerD, height: outerD)
            if weeklyPct > 0 {
                Circle()
                    .trim(from: 0, to: animatedWeekly)
                    .stroke(T.primary, style: StrokeStyle(lineWidth: lw, lineCap: T.ringLineCap))
                    .rotationEffect(.degrees(-90))
                    .frame(width: outerD, height: outerD)
            }
            Circle()
                .stroke(T.ink.opacity(0.08), style: StrokeStyle(lineWidth: lw, lineCap: T.ringLineCap))
                .frame(width: innerD, height: innerD)
            if sessionPct > 0 {
                Circle()
                    .trim(from: 0, to: animatedSession)
                    .stroke(T.ink, style: StrokeStyle(lineWidth: lw, lineCap: T.ringLineCap))
                    .rotationEffect(.degrees(-90))
                    .frame(width: innerD, height: innerD)
            }
            if let label = resetLabel {
                Text(label)
                    .font(T.mono(11, weight: .bold))
                    .foregroundColor(T.primary)
            }
        }
        .frame(width: 118, height: 118)
        .onAppear { animate() }
        .onChange(of: trigger) { _ in animate() }
    }

    private func animate() {
        animatedSession = 0
        animatedWeekly = 0
        withAnimation(.easeOut(duration: 0.9)) {
            animatedSession = min(max(sessionPct, 0), 1)
            animatedWeekly = min(max(weeklyPct, 0), 1)
        }
    }
}
