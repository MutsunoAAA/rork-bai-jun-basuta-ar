import SwiftUI

struct StartScreenView: View {
    let isFaceTrackingSupported: Bool
    let startAction: () -> Void

    @State private var bubblesAnimating: Bool = false
    @State private var titleScale: CGFloat = 0.3
    @State private var titleOpacity: Double = 0
    @State private var buttonPulse: Bool = false
    @State private var toothBounce: Bool = false
    @State private var heroRotation: Double = -5
    @State private var germFloatPhase: Bool = false
    @State private var sparkleRotation: Double = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                backgroundLayer(geo: geo)
                decorativeGerms(geo: geo)
                mainContent(geo: geo)
                floatingSparkles(geo: geo)
            }
        }
        .ignoresSafeArea()
        .task {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
                titleScale = 1.0
                titleOpacity = 1.0
            }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                toothBounce = true
            }
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                buttonPulse = true
            }
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                heroRotation = 5
            }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                germFloatPhase = true
            }
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                sparkleRotation = 360
            }
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                bubblesAnimating = true
            }
        }
    }

    private func backgroundLayer(geo: GeometryProxy) -> some View {
        ZStack {
            if let bgImage = UIImage(named: "start_bg") {
                Image(uiImage: bgImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
            } else {
                LinearGradient(
                    colors: [
                        Color(red: 0.63, green: 0.9, blue: 1.0),
                        Color(red: 0.88, green: 0.78, blue: 1.0),
                        Color(red: 1.0, green: 0.84, blue: 0.92),
                        Color(red: 1.0, green: 0.96, blue: 0.74)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }

            RadialGradient(
                colors: [.white.opacity(0.5), .clear],
                center: .init(x: 0.5, y: 0.25),
                startRadius: 10,
                endRadius: geo.size.width * 0.7
            )
        }
    }

    private func mainContent(geo: GeometryProxy) -> some View {
        let isCompact = geo.size.height < 700
        return VStack(spacing: 0) {
            Spacer(minLength: isCompact ? 30 : 50)

            heroSection(geo: geo, isCompact: isCompact)

            Spacer(minLength: isCompact ? 10 : 16)

            titleSection(isCompact: isCompact)

            Spacer(minLength: isCompact ? 14 : 24)

            startButtonSection(isCompact: isCompact)

            Spacer(minLength: isCompact ? 16 : 30)
        }
        .padding(.horizontal, 24)
    }

    private func heroSection(geo: GeometryProxy, isCompact: Bool) -> some View {
        let toothSize: CGFloat = isCompact ? 140 : 180
        let heroSize: CGFloat = isCompact ? 100 : 130

        return ZStack {
            Circle()
                .fill(.white.opacity(0.15))
                .frame(width: toothSize * 1.6, height: toothSize * 1.6)
                .blur(radius: 20)

            if let toothImage = UIImage(named: "start_tooth_char") {
                Image(uiImage: toothImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: toothSize, height: toothSize)
                    .offset(y: toothBounce ? -8 : 8)
                    .shadow(color: .white.opacity(0.6), radius: 20)
            } else {
                Image(systemName: "mouth.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(.white)
            }

            if let heroImage = UIImage(named: "start_hero_boy") {
                Image(uiImage: heroImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: heroSize, height: heroSize)
                    .rotationEffect(.degrees(heroRotation))
                    .offset(x: toothSize * 0.55, y: toothSize * 0.15)
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
            }
        }
        .scaleEffect(titleScale)
        .opacity(titleOpacity)
    }

    private func titleSection(isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 6 : 10) {
            gameTitleLogo(isCompact: isCompact)

            Text("インカメラでばい菌をやっつけよう！")
                .font(.system(size: isCompact ? 14 : 16, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.25, green: 0.25, blue: 0.45))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.white.opacity(0.65), in: .capsule)
        }
        .scaleEffect(titleScale)
        .opacity(titleOpacity)
    }

    private func gameTitleLogo(isCompact: Bool) -> some View {
        let topSize: CGFloat = isCompact ? 38 : 48
        let bottomSize: CGFloat = isCompact ? 46 : 58

        return VStack(spacing: isCompact ? -4 : -6) {
            styledText("ばい菌", fontSize: topSize,
                       gradientColors: [Color(red: 0.45, green: 0.82, blue: 1.0), Color(red: 0.3, green: 0.65, blue: 0.95)],
                       strokeColor: Color(red: 0.15, green: 0.35, blue: 0.7),
                       shadowColor: Color(red: 0.1, green: 0.3, blue: 0.6))

            styledText("バスターAR", fontSize: bottomSize,
                       gradientColors: [Color(red: 1.0, green: 0.85, blue: 0.2), Color(red: 1.0, green: 0.55, blue: 0.15)],
                       strokeColor: Color(red: 0.6, green: 0.25, blue: 0.05),
                       shadowColor: Color(red: 0.5, green: 0.2, blue: 0.0))
        }
        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
    }

    private func styledText(_ text: String, fontSize: CGFloat, gradientColors: [Color], strokeColor: Color, shadowColor: Color) -> some View {
        ZStack {
            Text(text)
                .font(.system(size: fontSize, weight: .heavy, design: .rounded))
                .foregroundStyle(strokeColor)
                .offset(x: 2, y: 2)

            Text(text)
                .font(.system(size: fontSize, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .offset(x: -0.8, y: -0.8)

            Text(text)
                .font(.system(size: fontSize, weight: .heavy, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Text(text)
                .font(.system(size: fontSize, weight: .heavy, design: .rounded))
                .foregroundStyle(.clear)
                .overlay {
                    LinearGradient(
                        colors: [.white.opacity(0.5), .clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                    .mask {
                        Text(text)
                            .font(.system(size: fontSize, weight: .heavy, design: .rounded))
                    }
                }
        }
    }

    private func startButtonSection(isCompact: Bool) -> some View {
        VStack(spacing: 12) {
            Button(action: startAction) {
                HStack(spacing: 10) {
                    Image(systemName: "play.fill")
                        .font(.system(size: isCompact ? 20 : 24, weight: .black))
                    Text("スタート")
                        .font(.system(size: isCompact ? 24 : 28, weight: .heavy, design: .rounded))
                }
                .foregroundStyle(Color(red: 0.28, green: 0.15, blue: 0.02))
                .frame(maxWidth: .infinity)
                .padding(.vertical, isCompact ? 18 : 22)
                .background {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.92, blue: 0.3),
                                    Color(red: 1.0, green: 0.78, blue: 0.2),
                                    Color(red: 1.0, green: 0.65, blue: 0.18)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(alignment: .top) {
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .fill(.white.opacity(0.25))
                                .frame(height: (isCompact ? 18 : 22) + 10)
                        }
                        .clipShape(.rect(cornerRadius: 30))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [.white.opacity(0.8), Color(red: 1.0, green: 0.7, blue: 0.1).opacity(0.5)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 2.5
                        )
                }
            }
            .buttonStyle(.plain)
            .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.1).opacity(0.4), radius: 16, y: 8)
            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
            .scaleEffect(buttonPulse ? 1.03 : 0.97)
            .sensoryFeedback(.impact(flexibility: .soft), trigger: buttonPulse)

            HStack(spacing: 6) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 13, weight: .semibold))
                Text("インカメラで口の動きをみます")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(Color(red: 0.3, green: 0.3, blue: 0.5).opacity(0.8))

            if !isFaceTrackingSupported {
                Text("この端末では顔トラッキングARが使えません")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.red.opacity(0.8))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(.white.opacity(0.7), in: .capsule)
            }
        }
    }

    private func decorativeGerms(geo: GeometryProxy) -> some View {
        let germSize: CGFloat = geo.size.height < 700 ? 75 : 95

        return ZStack {
            germDecoration(name: "germ_mint", size: germSize * 0.85)
                .offset(x: -geo.size.width * 0.34, y: -geo.size.height * 0.2)
                .rotationEffect(.degrees(germFloatPhase ? -10 : 10))

            germDecoration(name: "germ_purple", size: germSize)
                .offset(x: -geo.size.width * 0.32, y: geo.size.height * 0.35)
                .rotationEffect(.degrees(germFloatPhase ? 8 : -8))

            germDecoration(name: "germ_blue", size: germSize)
                .offset(x: geo.size.width * 0.32, y: geo.size.height * 0.35)
                .rotationEffect(.degrees(germFloatPhase ? -12 : 6))
        }
    }

    private func germDecoration(name: String, size: CGFloat) -> some View {
        Group {
            if let img = UIImage(named: name) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
            }
        }
        .offset(y: germFloatPhase ? -6 : 6)
    }

    private func floatingSparkles(geo: GeometryProxy) -> some View {
        let positions: [(CGFloat, CGFloat, CGFloat)] = [
            (0.15, 0.12, 14),
            (0.85, 0.08, 10),
            (0.08, 0.55, 12),
            (0.92, 0.52, 11),
            (0.5, 0.05, 16),
            (0.75, 0.7, 9),
            (0.25, 0.72, 10),
            (0.6, 0.15, 8),
        ]

        return ZStack {
            ForEach(0..<positions.count, id: \.self) { i in
                let p = positions[i]
                Image(systemName: "sparkle")
                    .font(.system(size: p.2, weight: .bold))
                    .foregroundStyle(.white.opacity(bubblesAnimating ? 0.9 : 0.3))
                    .position(x: geo.size.width * p.0, y: geo.size.height * p.1)
            }
        }
        .allowsHitTesting(false)
    }
}
