import AVFoundation
import Foundation

@MainActor
final class SoundEffectService {
    private let engine: AVAudioEngine = AVAudioEngine()
    private let playerNode: AVAudioPlayerNode = AVAudioPlayerNode()
    private let format: AVAudioFormat
    private let mouthOpenBuffer: AVAudioPCMBuffer?
    private let successBuffer: AVAudioPCMBuffer?

    init() {
        let format: AVAudioFormat = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1) ?? AVAudioFormat()
        self.format = format
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: format)
        mouthOpenBuffer = SoundEffectService.makeBuffer(
            format: format,
            notes: [
                SoundNote(frequency: 440, duration: 0.08, amplitude: 0.18),
                SoundNote(frequency: 520, duration: 0.09, amplitude: 0.16),
                SoundNote(frequency: 640, duration: 0.1, amplitude: 0.14)
            ]
        )
        successBuffer = SoundEffectService.makeBuffer(
            format: format,
            notes: [
                SoundNote(frequency: 880, duration: 0.08, amplitude: 0.16),
                SoundNote(frequency: 1_048, duration: 0.08, amplitude: 0.14),
                SoundNote(frequency: 1_320, duration: 0.12, amplitude: 0.12)
            ]
        )
        configureAudioSession()
        startEngineIfNeeded()
    }

    func play(_ effect: SoundEffect) {
        guard let buffer = effect == .mouthOpen ? mouthOpenBuffer : successBuffer else {
            return
        }

        startEngineIfNeeded()
        playerNode.stop()
        playerNode.scheduleBuffer(buffer, at: nil, options: [])
        playerNode.play()
    }

    private func configureAudioSession() {
        let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
        try? audioSession.setActive(true)
    }

    private func startEngineIfNeeded() {
        guard !engine.isRunning else {
            return
        }

        engine.prepare()
        try? engine.start()
    }

    private static func makeBuffer(format: AVAudioFormat, notes: [SoundNote]) -> AVAudioPCMBuffer? {
        let sampleRate: Double = format.sampleRate
        let totalFrames: Int = notes.reduce(0) { partialResult, note in
            partialResult + Int(sampleRate * note.duration)
        }

        guard totalFrames > 0,
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(totalFrames)),
              let channelData = buffer.floatChannelData?[0] else {
            return nil
        }

        buffer.frameLength = AVAudioFrameCount(totalFrames)

        var frameIndex: Int = 0
        for note in notes {
            let noteFrames: Int = Int(sampleRate * note.duration)
            let attackFrames: Int = max(1, Int(Double(noteFrames) * 0.15))
            let releaseFrames: Int = max(1, Int(Double(noteFrames) * 0.25))

            for localFrame in 0..<noteFrames {
                let time: Double = Double(localFrame) / sampleRate
                let wave: Double = sin(2 * .pi * note.frequency * time)
                let envelope: Double

                if localFrame < attackFrames {
                    envelope = Double(localFrame) / Double(attackFrames)
                } else if localFrame > noteFrames - releaseFrames {
                    envelope = Double(noteFrames - localFrame) / Double(releaseFrames)
                } else {
                    envelope = 1
                }

                channelData[frameIndex] = Float(wave * envelope * note.amplitude)
                frameIndex += 1
            }
        }

        return buffer
    }
}

nonisolated enum SoundEffect: Sendable {
    case mouthOpen
    case success
}

nonisolated struct SoundNote: Sendable {
    let frequency: Double
    let duration: Double
    let amplitude: Double
}
