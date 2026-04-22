import SwiftUI

struct CompletionScreenView: View {
    let defeatedGermCount: Int
    let surpriseCharacterCount: Int
    let playAgainAction: () -> Void
    let closeAction: () -> Void

    @State private var showHero: Bool = false
    @State private var showTitle: Bool = false
    @State private var showResults: Bool = false
    @State private var showRating: Bool = false
    @State private var showButtons: Bool = false
    @State private var starBurst: Bool = false
    @State private var heroFloat: Bool = false
    @State private var buttonPulse: Bool = false
    @State private var germFloatPhase: Bool = false
    @State private var bubblesAnimating: Bool = false
    @State private var confettiPhase: Bool = false

    private var ratingTitle: String {
        switch defeatedGermCount {
        case 0...12: return "もっとがんばろう！"
        case 13...25: return "ばい菌ハンター！"
        case 26...60: return "ばい菌バスター！"
        default: return "プロばい菌バスター！"
        }
    }

    private var ratingColor: Color {
        switch defeatedGermCount {
        case 0...12: return Color(red: 0.55, green: 0.78, blue: 0.95)
        case 13...25: return Color(red: 0.45, green: 0.85, blue: 0.55)
        case 26...60: return Color(red: 1.0, green: 0.72, blue: 0.22)
        default: return Color(red: 0.95, green: 0.42, blue: 0.55)
        }
    }

    private var ratingEmoji: String {
        switch defeatedGermCount {
        case 0...12: return "💪"
        case 13...25: return "🎯"
        case 26...60: return "⚡"
        default: return "👑"
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                backgroundLayer(geo: geo)
                decorativeGerms(geo: geo)
                floatingSparkles(geo: geo)
                confettiOverlay(geo: geo)
                mainContent(geo: geo)
            }
        }
        .ignoresSafeArea()
        .task {
            runEntrance()
        }
    }

    private func runEntrance() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.65).delay(0.15)) {
            showHero = true
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.5)) {
            showTitle = true
        }
        withAnimation(.spring(response: 0.55, dampingFraction: 0.65).delay(0.9)) {
            showResults = true
        }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.5).delay(1.4)) {
            showRating = true
            starBurst = true
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(1.8)) {
            showButtons = true
        }
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(0.3)) {
            heroFloat = true
        }
        withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true).delay(1.8)) {
            buttonPulse = true
        }
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            germFloatPhase = true
        }
        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
            bubblesAnimating = true
        }
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true).delay(0.5)) {
            confettiPhase = true
        }
    }

    private func backgroundLayer(geo: GeometryProxy) -> some View {
        ZStack {
            if let bgImage = UIImage(named: "completion_bg") {
                Image(uiImage: bgImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
            } else {
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.92, blue: 0.55),
                        Color(red: 1.0, green: 0.78, blue: 0.85),
                        Color(red: 0.78, green: 0.72, blue: 1.0),
                        Color(red: 0.65, green: 0.88, blue: 1.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }

            RadialGradient(
                colors: [.white.opacity(0.45), .clear],
                center: .init(x: 0.5, y: 0.2),
                startRadius: 10,
                endRadius: geo.size.width * 0.7
            )
        }
    }

    private func mainContent(geo: GeometryProxy) -> some View {
        let isCompact = geo.size.height < 700
        return VStack(spacing: 0) {
            Spacer(minLength: isCompact ? 24 : 44)

            if showHero {
                heroSection(isCompact: isCompact)
                    .transition(.scale(scale: 0.3).combined(with: .opacity))
            }

            Spacer(minLength: isCompact ? 8 : 14)

            if showTitle {
                titleSection(isCompact: isCompact)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Spacer(minLength: isCompact ? 10 : 16)

            if showResults {
                resultCard(isCompact: isCompact)
                    .padding(.horizontal, 24)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.6).combined(with: .opacity),
                        removal: .opacity
                    ))
            }

            Spacer(minLength: isCompact ? 8 : 12)

            if showRating {
                ratingBadge(isCompact: isCompact)
                    .padding(.horizontal, 24)
                    .transition(.scale(scale: 0.1).combined(with: .opacity))
            }

            Spacer()

            if showButtons {
                buttonSection(isCompact: isCompact)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.horizontal, 0)
    }

    private func heroSection(isCompact: Bool) -> some View {
        let toothSize: CGFloat = isCompact ? 120 : 150

        return ZStack {
            Circle()
                .fill(.white.opacity(0.15))
                .frame(width: toothSize * 1.5, height: toothSize * 1.5)
                .blur(radius: 20)

            ForEach(0..<8, id: \.self) { index in
                let angle = Double(index) * (360.0 / 8.0)
                let radius: CGFloat = starBurst ? (toothSize * 0.6) : (toothSize * 0.3)
                Image(systemName: index.isMultiple(of: 2) ? "star.fill" : "sparkles")
                    .font(.system(size: index.isMultiple(of: 2) ? 18 : 14, weight: .bold))
                    .foregroundStyle(index.isMultiple(of: 2) ? Color(red: 1.0, green: 0.71, blue: 0.2) : Color(red: 0.98, green: 0.45, blue: 0.65))
                    .offset(
                        x: cos(angle * .pi / 180) * radius,
                        y: sin(angle * .pi / 180) * radius
                    )
                    .opacity(starBurst ? 1 : 0)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.5).delay(Double(index) * 0.05),
                        value: starBurst
                    )
            }

            if let toothImage = UIImage(named: "completion_tooth_trophy") {
                Image(uiImage: toothImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: toothSize, height: toothSize)
                    .offset(y: heroFloat ? -8 : 8)
                    .shadow(color: .white.opacity(0.6), radius: 20)
            } else {
                ZStack {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: isCompact ? 56 : 68, weight: .black))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 1.0, green: 0.85, blue: 0.2), Color(red: 1.0, green: 0.55, blue: 0.15)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.1).opacity(0.5), radius: 16, y: 6)
                }
                .offset(y: heroFloat ? -8 : 8)
            }
        }
        .accessibilityHidden(true)
    }

    private func titleSection(isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 6 : 10) {
            styledText("よくがんばったね！", fontSize: isCompact ? 34 : 42,
                       gradientColors: [Color(red: 1.0, green: 0.55, blue: 0.65), Color(red: 0.95, green: 0.35, blue: 0.5)],
                       strokeColor: Color(red: 0.55, green: 0.12, blue: 0.2),
                       shadowColor: Color(red: 0.5, green: 0.1, blue: 0.15))

            Text("おくちのばい菌が ピカピカになったよ")
                .font(.system(size: isCompact ? 14 : 16, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.25, green: 0.25, blue: 0.45))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.white.opacity(0.65), in: .capsule)
        }
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
        .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
    }

    private func resultCard(isCompact: Bool) -> some View {
        HStack(spacing: 0) {
            resultItem(
                icon: "bolt.fill",
                iconColor: Color(red: 0.95, green: 0.45, blue: 0.45),
                label: "たおした ばい菌",
                count: defeatedGermCount,
                bgColor: Color(red: 1.0, green: 0.92, blue: 0.9),
                isCompact: isCompact
            )

            RoundedRectangle(cornerRadius: 1)
                .fill(Color(red: 0.85, green: 0.82, blue: 0.92).opacity(0.5))
                .frame(width: 1.5, height: isCompact ? 70 : 80)

            resultItem(
                icon: "heart.fill",
                iconColor: Color(red: 0.95, green: 0.55, blue: 0.75),
                label: "おうえんキャラ",
                count: surpriseCharacterCount,
                bgColor: Color(red: 1.0, green: 0.92, blue: 0.96),
                isCompact: isCompact
            )
        }
        .padding(.vertical, isCompact ? 16 : 20)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.white.opacity(0.8))
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.6), .white.opacity(0.1)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.9), .white.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1.5
                )
        }
        .shadow(color: .black.opacity(0.06), radius: 16, y: 8)
    }

    private func resultItem(icon: String, iconColor: Color, label: String, count: Int, bgColor: Color, isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 6 : 10) {
            ZStack {
                Circle()
                    .fill(bgColor)
                    .frame(width: isCompact ? 44 : 52, height: isCompact ? 44 : 52)

                Image(systemName: icon)
                    .font(.system(size: isCompact ? 20 : 24, weight: .bold))
                    .foregroundStyle(iconColor)
            }

            Text("\(count)")
                .font(.system(size: isCompact ? 30 : 36, weight: .heavy, design: .rounded))
                .foregroundStyle(Color(red: 0.25, green: 0.17, blue: 0.43))
                .contentTransition(.numericText())

            Text(label)
                .font(.system(size: isCompact ? 11 : 13, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.4, green: 0.36, blue: 0.52))
        }
        .frame(maxWidth: .infinity)
    }

    private func ratingBadge(isCompact: Bool) -> some View {
        HStack(spacing: 12) {
            Text(ratingEmoji)
                .font(.system(size: isCompact ? 28 : 34))

            VStack(alignment: .leading, spacing: 2) {
                Text("きみのランク")
                    .font(.system(size: isCompact ? 10 : 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(ratingTitle)
                    .font(.system(size: isCompact ? 20 : 24, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color(red: 0.25, green: 0.17, blue: 0.43))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }

            Spacer()

            Image(systemName: "trophy.fill")
                .font(.system(size: isCompact ? 24 : 28, weight: .bold))
                .foregroundStyle(ratingColor)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, isCompact ? 14 : 18)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(ratingColor.opacity(0.12))
                .overlay {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [ratingColor.opacity(0.2), ratingColor.opacity(0.02)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(ratingColor.opacity(0.35), lineWidth: 2)
        }
        .shadow(color: ratingColor.opacity(0.15), radius: 12, y: 6)
    }

    private func buttonSection(isCompact: Bool) -> some View {
        VStack(spacing: 12) {
            Button(action: playAgainAction) {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: isCompact ? 18 : 22, weight: .black))
                    Text("もういちど あそぶ")
                        .font(.system(size: isCompact ? 22 : 26, weight: .heavy, design: .rounded))
                }
                .foregroundStyle(Color(red: 0.28, green: 0.15, blue: 0.02))
                .frame(maxWidth: .infinity)
                .padding(.vertical, isCompact ? 16 : 20)
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
                                .frame(height: (isCompact ? 16 : 20) + 10)
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

            Button(action: closeAction) {
                Text("おわる")
                    .font(.system(size: isCompact ? 15 : 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.28, green: 0.22, blue: 0.46))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, isCompact ? 14 : 16)
                    .background(.white.opacity(0.7), in: .rect(cornerRadius: 22))
                    .overlay {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .strokeBorder(.white.opacity(0.9), lineWidth: 1.5)
                    }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 28)
    }

    private func decorativeGerms(geo: GeometryProxy) -> some View {
        let germSize: CGFloat = geo.size.height < 700 ? 60 : 75

        return ZStack {
            germDecoration(name: "germ_mint", size: germSize * 0.8)
                .offset(x: -geo.size.width * 0.36, y: -geo.size.height * 0.22)
                .rotationEffect(.degrees(germFloatPhase ? -12 : 8))

            germDecoration(name: "germ_purple", size: germSize * 0.9)
                .offset(x: geo.size.width * 0.38, y: -geo.size.height * 0.18)
                .rotationEffect(.degrees(germFloatPhase ? 10 : -6))

            germDecoration(name: "germ_blue", size: germSize * 0.7)
                .offset(x: -geo.size.width * 0.3, y: geo.size.height * 0.38)
                .rotationEffect(.degrees(germFloatPhase ? -8 : 12))

            if let charImg = UIImage(named: "char_rabbit") {
                Image(uiImage: charImg)
                    .resizable()
                    .scaledToFit()
                    .frame(width: germSize * 0.7, height: germSize * 0.7)
                    .offset(x: geo.size.width * 0.35, y: geo.size.height * 0.4)
                    .offset(y: germFloatPhase ? -5 : 5)
                    .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
            }
        }
        .allowsHitTesting(false)
    }

    private func germDecoration(name: String, size: CGFloat) -> some View {
        Group {
            if let img = UIImage(named: name) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .opacity(0.6)
                    .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
            }
        }
        .offset(y: germFloatPhase ? -5 : 5)
    }

    private func floatingSparkles(geo: GeometryProxy) -> some View {
        let positions: [(CGFloat, CGFloat, CGFloat)] = [
            (0.12, 0.1, 14),
            (0.88, 0.06, 11),
            (0.06, 0.5, 12),
            (0.94, 0.48, 10),
            (0.5, 0.03, 16),
            (0.78, 0.65, 9),
            (0.22, 0.68, 11),
            (0.65, 0.12, 8),
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

    private func confettiOverlay(geo: GeometryProxy) -> some View {
        let confettiData: [(String, Color, CGFloat, CGFloat, CGFloat)] = [
            ("circle.fill", Color(red: 1.0, green: 0.55, blue: 0.65), 0.18, 0.3, 7),
            ("circle.fill", Color(red: 0.55, green: 0.8, blue: 1.0), 0.75, 0.25, 6),
            ("diamond.fill", Color(red: 1.0, green: 0.82, blue: 0.2), 0.4, 0.15, 8),
            ("circle.fill", Color(red: 0.75, green: 0.55, blue: 1.0), 0.85, 0.45, 5),
            ("diamond.fill", Color(red: 0.45, green: 0.9, blue: 0.65), 0.1, 0.6, 7),
            ("circle.fill", Color(red: 1.0, green: 0.7, blue: 0.4), 0.6, 0.08, 6),
            ("diamond.fill", Color(red: 0.95, green: 0.45, blue: 0.65), 0.92, 0.7, 5),
            ("circle.fill", Color(red: 0.4, green: 0.75, blue: 1.0), 0.3, 0.85, 6),
        ]

        return ZStack {
            ForEach(0..<confettiData.count, id: \.self) { i in
                let d = confettiData[i]
                Image(systemName: d.0)
                    .font(.system(size: d.4))
                    .foregroundStyle(d.1.opacity(confettiPhase ? 0.7 : 0.3))
                    .position(
                        x: geo.size.width * d.2,
                        y: geo.size.height * d.3 + (confettiPhase ? 8 : -8)
                    )
                    .opacity(starBurst ? 1 : 0)
            }
        }
        .allowsHitTesting(false)
    }
}
