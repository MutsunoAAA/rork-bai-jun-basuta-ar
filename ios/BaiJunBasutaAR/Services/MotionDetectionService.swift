import CoreMotion
import Foundation

nonisolated final class MotionDetectionService: @unchecked Sendable {
    private let motionManager: CMMotionManager = CMMotionManager()
    private let queue: OperationQueue = {
        let queue: OperationQueue = OperationQueue()
        queue.name = "MotionDetectionServiceQueue"
        queue.qualityOfService = .userInteractive
        return queue
    }()

    private let sampleRate: Double = 1.0 / 60.0
    private let bufferSize: Int = 20
    private let energyThreshold: Double = 0.03
    private let debounceInterval: TimeInterval = 0.3
    private let peakThreshold: Double = 0.08
    private var directionChanges: Int = 0
    private var lastDominantAxis: Double = 0
    private var recentMagnitudes: [Double] = []
    private var lastTriggerDate: Date = .distantPast

    func start(onShake: @escaping @Sendable () -> Void) {
        guard motionManager.isAccelerometerAvailable else {
            return
        }

        recentMagnitudes = []
        lastTriggerDate = .distantPast
        motionManager.accelerometerUpdateInterval = sampleRate
        motionManager.startAccelerometerUpdates(to: queue) { [weak self] data, _ in
            guard let self, let data else {
                return
            }
            processAccelerometer(data: data, onShake: onShake)
        }
    }

    func stop() {
        motionManager.stopAccelerometerUpdates()
        recentMagnitudes = []
        directionChanges = 0
        lastDominantAxis = 0
    }

    private func processAccelerometer(data: CMAccelerometerData, onShake: @escaping @Sendable () -> Void) {
        let a = data.acceleration
        let magnitude: Double = sqrt(a.x * a.x + a.y * a.y + a.z * a.z)
        let deviation: Double = abs(magnitude - 1.0)

        recentMagnitudes.append(deviation)
        if recentMagnitudes.count > bufferSize {
            recentMagnitudes.removeFirst()
        }

        let dominantAxis: Double = max(abs(a.x), abs(a.y))
        if dominantAxis > peakThreshold {
            let sign: Double = (abs(a.x) > abs(a.y)) ? a.x : a.y
            if sign * lastDominantAxis < 0 {
                directionChanges += 1
            }
            lastDominantAxis = sign
        }

        guard recentMagnitudes.count >= bufferSize else {
            return
        }

        let energy: Double = recentMagnitudes.reduce(0, +) / Double(bufferSize)

        let now: Date = Date()
        guard energy > energyThreshold,
              directionChanges >= 2,
              now.timeIntervalSince(lastTriggerDate) > debounceInterval else {
            return
        }

        lastTriggerDate = now
        directionChanges = 0
        onShake()
    }
}
