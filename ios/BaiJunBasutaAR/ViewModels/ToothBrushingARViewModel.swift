import ARKit
import Foundation
import Observation

@MainActor
@Observable
final class ToothBrushingARViewModel {
    let isFaceTrackingSupported: Bool = ARFaceTrackingConfiguration.isSupported
    var currentScreen: AppScreen = .start
    var jawOpenValue: Float = 0
    var smileValue: Float = 0
    var isMouthOpen: Bool = false
    var isSmileShowing: Bool = false
    var isEscapingGerms: Bool = false
    var escapingGermIDs: Set<UUID> = []
    var mouthPoint: CGPoint = .zero
    var germs: [GermOverlay] = []
    var hasActiveFace: Bool = false
    var currentTheme: CharacterTheme = .germs
    var surpriseCharacterName: String? = nil
    var sessionCount: Int = 0
    var defeatedGermCount: Int = 0
    var surpriseCharacterCount: Int = 0

    private let soundEffectService: SoundEffectService = SoundEffectService()
    private let jawOpenThreshold: Float = 0.5
    private let smileThreshold: Float = 0.38
    private var hideGermsTask: Task<Void, Never>?
    private var handNearMouthFrames: Int = 0
    private let handTriggerFrames: Int = 3
    private let sessionCountKey: String = "toothbrush_session_count"

    func startSession() {
        hideGermsTask?.cancel()
        jawOpenValue = 0
        smileValue = 0
        isMouthOpen = false
        isSmileShowing = false
        isEscapingGerms = false
        escapingGermIDs = []
        germs = []
        hasActiveFace = false
        currentTheme = .germs
        surpriseCharacterName = nil
        defeatedGermCount = 0
        surpriseCharacterCount = 0
        currentScreen = .experience
    }

    func restartSession() {
        startSession()
    }

    func returnToStart() {
        stopMotionDetection()
        hideGermsTask?.cancel()
        jawOpenValue = 0
        smileValue = 0
        isMouthOpen = false
        isSmileShowing = false
        isEscapingGerms = false
        escapingGermIDs = []
        germs = []
        hasActiveFace = false
        currentScreen = .start
    }

    func completeSession() {
        stopMotionDetection()
        hideGermsTask?.cancel()
        germs = []
        escapingGermIDs = []
        isMouthOpen = false
        isSmileShowing = false
        isEscapingGerms = false
        jawOpenValue = 0
        smileValue = 0
        incrementSessionCount()
        soundEffectService.play(.success)
        currentScreen = .sparkle
    }

    func startMotionDetection() {}

    func stopMotionDetection() {}

    func handle(snapshot: FaceTrackingSnapshot) {
        jawOpenValue = snapshot.jawOpen
        smileValue = snapshot.smileValue
        hasActiveFace = snapshot.mouthPoint != nil

        guard let mouthPoint = snapshot.mouthPoint else {
            hideGermsTask?.cancel()
            isMouthOpen = false
            isSmileShowing = false
            isEscapingGerms = false
            germs = []
            return
        }

        self.mouthPoint = mouthPoint

        let shouldOpen: Bool = snapshot.jawOpen >= jawOpenThreshold
        let shouldSmileShow: Bool = snapshot.smileValue >= smileThreshold
        let shouldShowGerms: Bool = shouldOpen || shouldSmileShow

        isMouthOpen = shouldOpen
        isSmileShowing = shouldSmileShow

        if snapshot.isHandNearMouth && shouldShowGerms && !germs.isEmpty {
            handNearMouthFrames += 1
        } else {
            handNearMouthFrames = 0
        }

        if handNearMouthFrames >= handTriggerFrames && !isEscapingGerms && !germs.isEmpty {
            handNearMouthFrames = 0
            triggerGermEscape()
            return
        }

        guard !isEscapingGerms else {
            if !shouldShowGerms {
                hideGermsTask?.cancel()
                germs = []
                escapingGermIDs = []
                isEscapingGerms = false
            }
            return
        }

        if shouldShowGerms && germs.isEmpty {
            germs = makeGerms()
            soundEffectService.play(.mouthOpen)
        } else if !shouldShowGerms && !germs.isEmpty {
            hideGermsTask?.cancel()
            germs = []
        }
    }

    func triggerGermEscape() {
        guard !germs.isEmpty, !isEscapingGerms else {
            return
        }

        hideGermsTask?.cancel()
        isEscapingGerms = true
        escapingGermIDs = []

        let currentGerms = germs
        for germ in currentGerms {
            if germ.imageName.hasPrefix("char_") {
                surpriseCharacterCount += 1
            } else {
                defeatedGermCount += 1
            }
        }

        let germsToEscape = germs
        hideGermsTask = Task { @MainActor [weak self] in
            for (index, germ) in germsToEscape.enumerated() {
                guard let self, !Task.isCancelled else { return }
                escapingGermIDs.insert(germ.id)
                let delay: Int = index == 0 ? 180 : Int.random(in: 280...500)
                try? await Task.sleep(for: .milliseconds(delay))
            }
            try? await Task.sleep(for: .milliseconds(400))
            guard let self else { return }
            germs = []
            escapingGermIDs = []
            isEscapingGerms = false
        }
    }

    private func makeGerms() -> [GermOverlay] {
        let templates: [(CGFloat, CGFloat, CGFloat, Double, Double, CGFloat, CGFloat)] = [
            (-60, -12, 40, -10, 0, -110, -112),
            (-18, 10, 34, 8, 0.8, -24, -146),
            (28, 18, 38, 10, 1.6, 94, -102),
            (64, -6, 32, -16, 2.2, 126, -132)
        ]

        let shouldIncludeSurprise = Int.random(in: 0..<10) < 4
        let surpriseIndex = shouldIncludeSurprise ? Int.random(in: 0..<templates.count) : -1
        let surpriseTheme = shouldIncludeSurprise ? CharacterTheme.surpriseThemes.randomElement() : nil

        if let theme = surpriseTheme {
            surpriseCharacterName = theme.displayName
            currentTheme = .germs
        } else {
            surpriseCharacterName = nil
            currentTheme = .germs
        }

        return templates.enumerated().map { index, template in
            let style: GermStyle = GermStyle.allCases[index % GermStyle.allCases.count]
            let isSurpriseSlot = index == surpriseIndex
            let imageName: String = isSurpriseSlot ? (surpriseTheme?.imageNames.first ?? "") : ""
            return GermOverlay(
                style: style,
                imageName: imageName,
                offsetX: template.0,
                offsetY: template.1,
                size: isSurpriseSlot ? template.2 * 1.15 : template.2,
                rotation: template.3,
                bobPhase: template.4,
                escapeOffsetX: template.5,
                escapeOffsetY: template.6
            )
        }
    }

    private func incrementSessionCount() {
        sessionCount = UserDefaults.standard.integer(forKey: sessionCountKey) + 1
        UserDefaults.standard.set(sessionCount, forKey: sessionCountKey)
    }
}
