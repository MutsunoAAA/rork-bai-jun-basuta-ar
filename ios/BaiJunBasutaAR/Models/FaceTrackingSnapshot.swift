import CoreGraphics
import Foundation

nonisolated struct FaceTrackingSnapshot: Sendable {
    let jawOpen: Float
    let smileValue: Float
    let mouthPoint: CGPoint?
    let isHandNearMouth: Bool
}
