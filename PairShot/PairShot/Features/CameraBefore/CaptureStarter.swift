import Foundation

@MainActor
protocol CaptureStarter: AnyObject {
    var membership: Membership { get }
    var snackbarQueue: SnackbarQueue { get }
    var pairRepo: PhotoPairRepository { get }
    var showPaywall: Bool { get set }
    var beforeCameraTargetPairId: UUID? { get set }
    var showBeforeCamera: Bool { get set }
}

extension CaptureStarter {
    func startCapture() async {
        guard await passesDailyPairGate() else { return }
        beforeCameraTargetPairId = nil
        showBeforeCamera = true
    }

    func passesDailyPairGate() async -> Bool {
        guard let remaining = await dailyPairQuotaRemaining() else { return true }
        guard remaining > 0 else {
            presentDailyLimitGate()
            return false
        }
        return true
    }

    func presentDailyLimitGate() {
        snackbarQueue.enqueue(
            .dailyLimitGate,
            debounceKey: "pro_gate_daily_limit",
        )
        showPaywall = true
    }

    func dailyPairQuotaRemaining() async -> Int? {
        if membership.proIsActive { return nil }
        let count = await todayCreatedCountOrZero()
        return max(0, PairLimitGate.freeTierDailyLimit - count)
    }

    func todayCreatedCountOrZero() async -> Int {
        let dayStart = PairLimitGate.startOfToday()
        return await (try? pairRepo.countCreated(since: dayStart)) ?? 0
    }
}
