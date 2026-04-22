import ARKit
import RealityKit
import SwiftUI
import Vision
import simd

struct FaceTrackingARProxyView: View {
    let onSnapshot: (FaceTrackingSnapshot) -> Void

    var body: some View {
        Group {
            #if targetEnvironment(simulator)
            ARFaceTrackingUnavailableView()
            #else
            if ARFaceTrackingConfiguration.isSupported {
                FaceTrackingARView(onSnapshot: onSnapshot)
            } else {
                ARFaceTrackingUnavailableView()
            }
            #endif
        }
    }
}

private struct FaceTrackingARView: UIViewRepresentable {
    let onSnapshot: (FaceTrackingSnapshot) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onSnapshot: onSnapshot)
    }

    func makeUIView(context: Context) -> ARView {
        let arView: ARView = ARView(frame: .zero)
        arView.automaticallyConfigureSession = false
        arView.environment.background = .cameraFeed()
        context.coordinator.attach(to: arView)
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.onSnapshot = onSnapshot
    }
}

@MainActor
private final class Coordinator: NSObject, ARSessionDelegate {
    var onSnapshot: (FaceTrackingSnapshot) -> Void
    private weak var arView: ARView?
    private let handPoseRequest: VNDetectHumanHandPoseRequest = {
        let request = VNDetectHumanHandPoseRequest()
        request.maximumHandCount = 1
        return request
    }()
    private var isProcessingVision: Bool = false
    private var lastHandNearMouth: Bool = false
    private var lastFaceMouthNormalized: CGPoint?

    init(onSnapshot: @escaping (FaceTrackingSnapshot) -> Void) {
        self.onSnapshot = onSnapshot
    }

    func attach(to arView: ARView) {
        self.arView = arView
        arView.session.delegate = self

        let configuration: ARFaceTrackingConfiguration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    nonisolated func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.compactMap({ $0 as? ARFaceAnchor }).first else {
            Task { @MainActor in
                onSnapshot(FaceTrackingSnapshot(jawOpen: 0, smileValue: 0, mouthPoint: nil, isHandNearMouth: false))
            }
            return
        }

        let jawOpen: Float = faceAnchor.blendShapes[.jawOpen]?.floatValue ?? 0
        let smileLeft: Float = faceAnchor.blendShapes[.mouthSmileLeft]?.floatValue ?? 0
        let smileRight: Float = faceAnchor.blendShapes[.mouthSmileRight]?.floatValue ?? 0
        let smileValue: Float = max(smileLeft, smileRight)
        Task { @MainActor in
            handle(faceAnchor: faceAnchor, jawOpen: jawOpen, smileValue: smileValue)
        }
    }

    nonisolated func session(_ session: ARSession, didUpdate frame: ARFrame) {
        Task { @MainActor in
            processHandDetection(frame: frame)
        }
    }

    private func processHandDetection(frame: ARFrame) {
        guard !isProcessingVision else { return }
        isProcessingVision = true

        let pixelBuffer = frame.capturedImage
        let mouthNorm = lastFaceMouthNormalized

        Task.detached { [weak self, handPoseRequest] in
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
            var handNear = false
            do {
                try handler.perform([handPoseRequest])
                if let observation = handPoseRequest.results?.first {
                    handNear = Self.checkHandNearMouth(observation: observation, mouthNormalized: mouthNorm)
                }
            } catch {}

            await MainActor.run {
                self?.lastHandNearMouth = handNear
                self?.isProcessingVision = false
            }
        }
    }

    nonisolated private static func checkHandNearMouth(
        observation: VNHumanHandPoseObservation,
        mouthNormalized: CGPoint?
    ) -> Bool {
        guard let mouthNorm = mouthNormalized else { return false }

        let jointNames: [VNHumanHandPoseObservation.JointName] = [
            .wrist, .indexMCP, .middleMCP, .indexTip, .middleTip, .ringMCP
        ]

        var closestDistance: CGFloat = .greatestFiniteMagnitude
        for jointName in jointNames {
            guard let point = try? observation.recognizedPoint(jointName),
                  point.confidence > 0.15 else { continue }
            let handPoint = CGPoint(x: point.location.x, y: point.location.y)
            let dx = handPoint.x - mouthNorm.x
            let dy = handPoint.y - mouthNorm.y
            let dist = sqrt(dx * dx + dy * dy)
            if dist < closestDistance {
                closestDistance = dist
            }
        }

        return closestDistance < 0.25
    }

    private func handle(faceAnchor: ARFaceAnchor, jawOpen: Float, smileValue: Float) {
        guard let arView else {
            return
        }

        let smileLift: Float = min(max(smileValue, 0), 1) * 0.008
        let mouthCenter: SIMD3<Float> = worldPoint(for: faceAnchor, localPoint: SIMD3<Float>(0, -0.03 + smileLift, 0.045))
        let screenPoint: CGPoint? = arView.project(mouthCenter)

        let viewSize = arView.bounds.size
        if let sp = screenPoint, viewSize.width > 0, viewSize.height > 0 {
            lastFaceMouthNormalized = CGPoint(
                x: sp.x / viewSize.width,
                y: 1.0 - (sp.y / viewSize.height)
            )
        } else {
            lastFaceMouthNormalized = nil
        }

        onSnapshot(FaceTrackingSnapshot(
            jawOpen: jawOpen,
            smileValue: smileValue,
            mouthPoint: screenPoint,
            isHandNearMouth: lastHandNearMouth
        ))
    }

    private func worldPoint(for faceAnchor: ARFaceAnchor, localPoint: SIMD3<Float>) -> SIMD3<Float> {
        let localVector: simd_float4 = simd_float4(localPoint.x, localPoint.y, localPoint.z, 1)
        let transformed: simd_float4 = faceAnchor.transform * localVector
        return SIMD3<Float>(transformed.x, transformed.y, transformed.z)
    }
}

private struct ARFaceTrackingUnavailableView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "faceid")
                .font(.system(size: 52))
                .foregroundStyle(.secondary)
            Text("AR Face Tracking")
                .font(.title2.weight(.semibold))
            Text("Install this app on your device\nvia the Rork App for the AR experience.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}
