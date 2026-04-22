import SwiftUI

struct ARExperienceScreenView: View {
    let viewModel: ToothBrushingARViewModel
    let completeAction: () -> Void
    let backAction: () -> Void

    var body: some View {
        ZStack {
            FaceTrackingARProxyView { snapshot in
                viewModel.handle(snapshot: snapshot)
            }
            .ignoresSafeArea()

            playfulOverlay
        }
        .background(.black)
        .sensoryFeedback(.success, trigger: viewModel.currentScreen == .completion)
        .sensoryFeedback(.impact, trigger: viewModel.isEscapingGerms)
        .onAppear {
            viewModel.startMotionDetection()
        }
        .onDisappear {
            viewModel.stopMotionDetection()
        }
    }

    private var playfulOverlay: some View {
        Color.clear
            .overlay(alignment: .topLeading) {
                backButton
            }
            .overlay(alignment: .center) {
                germOverlayLayer
            }
            .overlay(alignment: .bottom) {
                bottomPanel
            }
    }

    private var backButton: some View {
        Button(action: backAction) {
            Image(systemName: "chevron.backward")
                .font(.headline.weight(.bold))
                .frame(width: 48, height: 48)
                .background(.white.opacity(0.9), in: .circle)
                .overlay {
                    Circle()
                        .strokeBorder(Color(red: 0.97, green: 0.62, blue: 0.27), lineWidth: 2)
                }
                .shadow(color: .black.opacity(0.12), radius: 10, y: 6)
        }
        .foregroundStyle(Color(red: 0.27, green: 0.21, blue: 0.46))
        .padding(.leading, 16)
        .padding(.top, 12)
    }

    private var germOverlayLayer: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(viewModel.germs) { germ in
                    let isThisGermEscaping = viewModel.escapingGermIDs.contains(germ.id)
                    GermSpriteView(germ: germ)
                        .scaleEffect(isThisGermEscaping ? 0.2 : 1)
                        .opacity(isThisGermEscaping ? 0 : 1)
                        .rotationEffect(.degrees(isThisGermEscaping ? germ.rotation * 4.5 : germ.rotation))
                        .offset(
                            x: isThisGermEscaping ? germ.escapeOffsetX * 1.4 : 0,
                            y: isThisGermEscaping ? germ.escapeOffsetY * 1.4 : 0
                        )
                        .position(
                            x: clampedX(in: geometry.size, germ: germ),
                            y: clampedY(in: geometry.size, germ: germ)
                        )
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isThisGermEscaping)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .allowsHitTesting(false)
    }

    private var bottomPanel: some View {
        VStack(spacing: 12) {
            if viewModel.isEscapingGerms {
                Label(viewModel.surpriseCharacterName != nil ? "みんな あわてて にげてる！" : "ばい菌があわてて にげてる！", systemImage: "sparkles")
                    .font(.system(.subheadline, design: .rounded, weight: .heavy))
                    .foregroundStyle(Color(red: 0.29, green: 0.19, blue: 0.43))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.white.opacity(0.92), in: .capsule)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else if !viewModel.germs.isEmpty, let charName = viewModel.surpriseCharacterName {
                Label("\(charName)が あそびにきたよ！", systemImage: "heart.fill")
                    .font(.system(.subheadline, design: .rounded, weight: .heavy))
                    .foregroundStyle(Color(red: 0.19, green: 0.29, blue: 0.43))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.white.opacity(0.92), in: .capsule)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Button(action: completeAction) {
                HStack(spacing: 10) {
                    Image(systemName: "star.fill")
                    Text("ピカピカになった！")
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
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .background(.white.opacity(0.78), in: .rect(topLeadingRadius: 30, topTrailingRadius: 30))
        .overlay(alignment: .top) {
            Capsule()
                .fill(Color(red: 0.98, green: 0.56, blue: 0.63).opacity(0.7))
                .frame(width: 86, height: 6)
                .padding(.top, 10)
        }
        .animation(.spring(response: 0.32, dampingFraction: 0.78), value: viewModel.isEscapingGerms)
        .animation(.spring(response: 0.32, dampingFraction: 0.78), value: viewModel.germs.isEmpty)
    }

    private func clampedX(in size: CGSize, germ: GermOverlay) -> CGFloat {
        min(max(viewModel.mouthPoint.x + germ.offsetX, germ.size / 2), size.width - germ.size / 2)
    }

    private func clampedY(in size: CGSize, germ: GermOverlay) -> CGFloat {
        min(max(viewModel.mouthPoint.y + germ.offsetY + 12, germ.size / 2), size.height - 148)
    }
}
