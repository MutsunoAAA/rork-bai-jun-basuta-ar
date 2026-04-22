import SwiftUI

struct SparkleScreenView: View {
    let onDone: () -> Void
    let onRestart: () -> Void

    @State private var sparkles: [SparkleParticle] = []
    @State private var showMessage: Bool = false
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            FaceTrackingARProxyView { _ in }
                .ignoresSafeArea()

            sparkleOverlay
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack {
                if showMessage {
                    Text("ピッカピカ！")
                        .font(.system(.largeTitle, design: .rounded, weight: .heavy))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
                        .shadow(color: Color(red: 1.0, green: 0.85, blue: 0.2).opacity(0.6), radius: 20)
                        .transition(.scale.combined(with: .opacity))
                        .padding(.top, 80)
                }

                Spacer()

                VStack(spacing: 12) {
                    Button(action: onRestart) {
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.clockwise")
                            Text("もういちど あそぶ")
                        }
                        .font(.system(.title3, design: .rounded, weight: .heavy))
                        .foregroundStyle(Color(red: 0.24, green: 0.13, blue: 0.04))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 1.0, green: 0.88, blue: 0.28), Color(red: 1.0, green: 0.65, blue: 0.24)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: .rect(cornerRadius: 24)
                        )
                    }
                    .buttonStyle(.plain)
                    .shadow(color: .black.opacity(0.14), radius: 16, y: 10)

                    Button(action: onDone) {
                        Text("おわる")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.white.opacity(0.25), in: .rect(cornerRadius: 22))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 26)
            }
        }
        .onAppear {
            generateSparkles()
            startSparkleTimer()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3)) {
                showMessage = true
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }

    private var sparkleOverlay: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(sparkles) { sparkle in
                    Image(systemName: sparkle.symbol)
                        .font(.system(size: sparkle.size, weight: .bold))
                        .foregroundStyle(sparkle.color)
                        .opacity(sparkle.opacity)
                        .scaleEffect(sparkle.scale)
                        .rotationEffect(.degrees(sparkle.rotation))
                        .position(x: sparkle.x * geometry.size.width, y: sparkle.y * geometry.size.height)
                        .animation(.easeInOut(duration: sparkle.duration), value: sparkle.opacity)
                        .animation(.easeInOut(duration: sparkle.duration), value: sparkle.scale)
                }
            }
        }
    }

    private func generateSparkles() {
        sparkles = (0..<18).map { _ in
            SparkleParticle.random()
        }
    }

    private func startSparkleTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            Task { @MainActor in
                withAnimation {
                    if sparkles.count > 24 {
                        sparkles.removeFirst(4)
                    }
                    for i in sparkles.indices {
                        if Bool.random() {
                            sparkles[i].opacity = Double.random(in: 0.3...1.0)
                            sparkles[i].scale = CGFloat.random(in: 0.6...1.3)
                            sparkles[i].rotation = Double.random(in: 0...360)
                        }
                    }
                    sparkles.append(contentsOf: (0..<3).map { _ in SparkleParticle.random() })
                }
            }
        }
    }
}

struct SparkleParticle: Identifiable {
    let id: UUID = UUID()
    let symbol: String
    let size: CGFloat
    let color: Color
    let x: CGFloat
    let y: CGFloat
    let duration: Double
    var opacity: Double
    var scale: CGFloat
    var rotation: Double

    static func random() -> SparkleParticle {
        let symbols = ["sparkle", "sparkles", "star.fill", "sun.min.fill"]
        let colors: [Color] = [
            Color(red: 1.0, green: 0.85, blue: 0.2),
            Color(red: 1.0, green: 0.95, blue: 0.6),
            .white,
            Color(red: 0.6, green: 0.9, blue: 1.0),
            Color(red: 1.0, green: 0.7, blue: 0.85)
        ]
        return SparkleParticle(
            symbol: symbols.randomElement()!,
            size: CGFloat.random(in: 14...36),
            color: colors.randomElement()!,
            x: CGFloat.random(in: 0.05...0.95),
            y: CGFloat.random(in: 0.05...0.85),
            duration: Double.random(in: 0.6...1.4),
            opacity: Double.random(in: 0.5...1.0),
            scale: CGFloat.random(in: 0.7...1.2),
            rotation: Double.random(in: 0...360)
        )
    }
}
