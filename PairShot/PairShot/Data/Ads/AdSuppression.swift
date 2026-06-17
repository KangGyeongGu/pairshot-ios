@MainActor
enum AdSuppression {
    static func isSuppressed(
        promotionStore: PromotionStore?,
        subscriptionStore: SubscriptionStore?,
        tutorialCoordinator: TutorialCoordinator? = nil,
    ) -> Bool {
        let promotionPro = promotionStore?.proIsActive ?? false
        let subscriptionPro = subscriptionStore?.isPro ?? false
        let tutorial = tutorialCoordinator?.isActive ?? false
        return promotionPro || subscriptionPro || tutorial
    }

    static func isSuppressed(
        membership: Membership,
        tutorialCoordinator: TutorialCoordinator? = nil,
    ) -> Bool {
        isSuppressed(
            isPro: membership.proIsActive,
            tutorialActive: tutorialCoordinator?.isActive ?? false,
        )
    }

    static func isSuppressed(
        isPro: Bool,
        tutorialActive: Bool = false,
    ) -> Bool {
        isPro || tutorialActive
    }

    static func isLoadSuppressed(
        promotionStore: PromotionStore?,
        subscriptionStore: SubscriptionStore?,
    ) -> Bool {
        let promotionPro = promotionStore?.proIsActive ?? false
        let subscriptionPro = subscriptionStore?.isPro ?? false
        return promotionPro || subscriptionPro
    }
}
