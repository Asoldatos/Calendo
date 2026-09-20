import SwiftUI

/// Animated audio waveform visualization that responds to microphone input levels.
struct WaveformView: View {
    let audioLevel: Float
    let isActive: Bool

    private let barCount = 20
    @State private var phases: [Double] = []

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<barCount, id: \.self) { index in
                WaveformBar(
                    audioLevel: audioLevel,
                    phase: phases.isEmpty ? 0 : phases[index],
                    isActive: isActive,
                    index: index,
                    totalBars: barCount
                )
            }
        }
        .onAppear {
            phases = (0..<barCount).map { _ in Double.random(in: 0...2 * .pi) }
        }
    }
}

// MARK: - Individual Bar
struct WaveformBar: View {
    let audioLevel: Float
    let phase: Double
    let isActive: Bool
    let index: Int
    let totalBars: Int

    @State private var animatedHeight: CGFloat = 4

    // Create a bell-curve distribution — bars in the center are taller
    private var positionFactor: CGFloat {
        let center = CGFloat(totalBars) / 2.0
        let distance = abs(CGFloat(index) - center) / center
        return 1.0 - (distance * 0.6)
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(barGradient)
            .frame(width: 4, height: animatedHeight)
            .onChange(of: audioLevel) { _, newLevel in
                withAnimation(.easeOut(duration: 0.1)) {
                    if isActive {
                        let randomFactor = CGFloat.random(in: 0.5...1.5)
                        let levelContribution = CGFloat(newLevel) * 50 * positionFactor * randomFactor
                        animatedHeight = max(4, min(50, 4 + levelContribution))
                    } else {
                        animatedHeight = 4
                    }
                }
            }
            .onChange(of: isActive) { _, active in
                if !active {
                    withAnimation(.easeOut(duration: 0.3)) {
                        animatedHeight = 4
                    }
                }
            }
    }

    private var barGradient: LinearGradient {
        let intensity = Double(animatedHeight / 50.0)
        return LinearGradient(
            colors: [
                Color.calendoPurple.opacity(0.4 + intensity * 0.6),
                Color.calendoCoral.opacity(0.3 + intensity * 0.5)
            ],
            startPoint: .bottom,
            endPoint: .top
        )
    }
}
