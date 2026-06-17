import Foundation
@testable import PairShot
import Testing

@MainActor
struct AdSuppressionMergeTests {
    @Test
    func `Pro false → ads shown (suppression = false)`() {
        #expect(AdSuppression.isSuppressed(isPro: false) == false)
    }

    @Test
    func `Pro active → ads suppressed`() {
        #expect(AdSuppression.isSuppressed(isPro: true) == true)
    }

    @Test
    func `튜토리얼 활성 시 광고 단일 진리값으로 통합 차단`() {
        #expect(AdSuppression.isSuppressed(isPro: false, tutorialActive: true) == true)
        #expect(AdSuppression.isSuppressed(isPro: false, tutorialActive: false) == false)
    }

    @Test
    func `튜토리얼 비활성 + 둘 다 false → 기존과 동일하게 suppression false`() {
        let coord = TutorialCoordinator()
        #expect(
            AdSuppression.isSuppressed(
                promotionStore: nil,
                subscriptionStore: nil,
                tutorialCoordinator: coord,
            ) == false,
        )
    }

    @Test
    func `튜토리얼 활성 + 둘 다 false → suppression true (신규 가드)`() {
        let coord = TutorialCoordinator()
        coord.start()
        #expect(
            AdSuppression.isSuppressed(
                promotionStore: nil,
                subscriptionStore: nil,
                tutorialCoordinator: coord,
            ) == true,
        )
    }

    @Test
    func `튜토리얼 done 상태 → isActive false 로 간주되어 suppression false`() {
        let coord = TutorialCoordinator()
        coord.complete()
        #expect(
            AdSuppression.isSuppressed(
                promotionStore: nil,
                subscriptionStore: nil,
                tutorialCoordinator: coord,
            ) == false,
        )
    }

    @Test
    func `튜토리얼 nil 전달 시 기존 시그니처와 동일 결과`() {
        #expect(
            AdSuppression.isSuppressed(
                promotionStore: nil,
                subscriptionStore: nil,
                tutorialCoordinator: nil,
            ) == false,
        )
    }
}
