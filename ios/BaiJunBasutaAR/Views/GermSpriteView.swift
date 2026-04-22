import SwiftUI

struct GermSpriteView: View {
    let germ: GermOverlay
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isAnimating: Bool = false

    private var resolvedImageName: String {
        germ.imageName.isEmpty ? germ.style.imageName : germ.imageName
    }

    private var isCharacter: Bool {
        !germ.imageName.isEmpty && germ.imageName.hasPrefix("char_")
    }

    var body: some View {
        ZStack {
            if isCharacter {
                characterBody
            } else {
                germBody
            }
        }
        .frame(width: germ.size, height: germ.size)
        .clipShape(.circle)
        .rotationEffect(.degrees(germ.rotation))
        .shadow(color: shadowColor.opacity(0.32), radius: 14, y: 8)
        .offset(y: reduceMotion ? 0 : (isAnimating ? -7 : 7))
        .animation(
            reduceMotion ? nil : .easeInOut(duration: 1.25).repeatForever(autoreverses: true).delay(germ.bobPhase * 0.12),
            value: isAnimating
        )
        .task {
            isAnimating = true
        }
        .accessibilityHidden(true)
    }

    private var germBody: some View {
        ZStack {
            Circle()
                .fill(glowGradient)
                .frame(width: germ.size * 1.18, height: germ.size * 1.18)
                .blur(radius: germ.size * 0.08)

            if let image = loadImage(resolvedImageName) {
                image
                    .resizable()
                    .scaledToFit()
                    .padding(germ.size * 0.04)
            } else {
                RoundedRectangle(cornerRadius: germ.size * 0.3, style: .continuous)
                    .fill(fallbackGradient)
            }
        }
        .background(.white.opacity(0.14), in: .circle)
        .overlay {
            Circle()
                .strokeBorder(.white.opacity(0.34), lineWidth: 1.4)
        }
    }

    private var characterBody: some View {
        ZStack {
            Circle()
                .fill(characterGlow)
                .frame(width: germ.size * 1.2, height: germ.size * 1.2)
                .blur(radius: germ.size * 0.1)

            if let image = loadImage(resolvedImageName) {
                image
                    .resizable()
                    .scaledToFit()
                    .padding(germ.size * 0.06)
            } else {
                Image(systemName: "questionmark")
                    .font(.system(size: germ.size * 0.5, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .background(.white.opacity(0.22), in: .circle)
        .overlay {
            Circle()
                .strokeBorder(.white.opacity(0.5), lineWidth: 1.6)
        }
    }

    private func loadImage(_ name: String) -> Image? {
        UIImage(named: name).map { Image(uiImage: $0) }
    }

    private var glowGradient: RadialGradient {
        RadialGradient(
            colors: [glowColor.opacity(0.9), glowColor.opacity(0.14), .clear],
            center: .center,
            startRadius: 4,
            endRadius: germ.size * 0.8
        )
    }

    private var characterGlow: RadialGradient {
        RadialGradient(
            colors: [.white.opacity(0.7), .white.opacity(0.2), .clear],
            center: .center,
            startRadius: 4,
            endRadius: germ.size * 0.8
        )
    }

    private var fallbackGradient: LinearGradient {
        LinearGradient(
            colors: [glowColor.opacity(0.95), glowColor.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var glowColor: Color {
        switch germ.style {
        case .mint:
            return .mint
        case .purple:
            return .purple
        case .blue:
            return .cyan
        }
    }

    private var shadowColor: Color {
        isCharacter ? .white : glowColor
    }
}
