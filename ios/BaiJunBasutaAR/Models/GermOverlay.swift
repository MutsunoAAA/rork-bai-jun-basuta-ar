import CoreGraphics
import Foundation

nonisolated struct GermOverlay: Identifiable, Sendable {
    let id: UUID
    let style: GermStyle
    let imageName: String
    let offsetX: CGFloat
    let offsetY: CGFloat
    let size: CGFloat
    let rotation: Double
    let bobPhase: Double
    let escapeOffsetX: CGFloat
    let escapeOffsetY: CGFloat

    init(
        id: UUID = UUID(),
        style: GermStyle,
        imageName: String = "",
        offsetX: CGFloat,
        offsetY: CGFloat,
        size: CGFloat,
        rotation: Double,
        bobPhase: Double,
        escapeOffsetX: CGFloat,
        escapeOffsetY: CGFloat
    ) {
        self.id = id
        self.style = style
        self.imageName = imageName
        self.offsetX = offsetX
        self.offsetY = offsetY
        self.size = size
        self.rotation = rotation
        self.bobPhase = bobPhase
        self.escapeOffsetX = escapeOffsetX
        self.escapeOffsetY = escapeOffsetY
    }
}

nonisolated enum GermStyle: CaseIterable, Sendable {
    case mint
    case purple
    case blue

    var imageName: String {
        switch self {
        case .mint:
            return "germ_mint"
        case .purple:
            return "germ_purple"
        case .blue:
            return "germ_blue"
        }
    }

    var bodyColorName: String {
        switch self {
        case .mint:
            return "mint"
        case .purple:
            return "purple"
        case .blue:
            return "blue"
        }
    }

    var accentColorName: String {
        switch self {
        case .mint:
            return "green"
        case .purple:
            return "pink"
        case .blue:
            return "cyan"
        }
    }
}
