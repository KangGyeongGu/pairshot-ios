import Foundation
@testable import PairShot
import Testing

struct MembershipResolverTests {
    private static let now = Date(timeIntervalSinceReferenceDate: 700_000_000)
    private static let near = now.addingTimeInterval(60 * 60 * 24 * 7)
    private static let far = now.addingTimeInterval(60 * 60 * 24 * 90)

    @Test
    func `Subscription only active → proIsActive true`() {
        let inputs = MembershipInputs(
            subscriptionIsPro: true,
            subscriptionExpiresAt: Self.near,
            promotionProIsActive: false,
            promotionProExpiresAt: nil,
        )

        #expect(MembershipResolver.proIsActive(inputs: inputs))
        #expect(MembershipResolver.proExpiresAt(inputs: inputs) == Self.near)
    }

    @Test
    func `Pro promotion only → proIsActive true`() {
        let inputs = MembershipInputs(
            subscriptionIsPro: false,
            subscriptionExpiresAt: nil,
            promotionProIsActive: true,
            promotionProExpiresAt: Self.near,
        )

        #expect(MembershipResolver.proIsActive(inputs: inputs))
        #expect(MembershipResolver.proExpiresAt(inputs: inputs) == Self.near)
    }

    @Test
    func `Subscription + Pro promotion → max expiry wins`() {
        let inputs = MembershipInputs(
            subscriptionIsPro: true,
            subscriptionExpiresAt: Self.near,
            promotionProIsActive: true,
            promotionProExpiresAt: Self.far,
        )

        #expect(MembershipResolver.proIsActive(inputs: inputs))
        #expect(MembershipResolver.proExpiresAt(inputs: inputs) == Self.far)
    }

    @Test
    func `Permanent promotion (nil expiresAt) → expiry resolves to nil = unlimited`() {
        let inputs = MembershipInputs(
            subscriptionIsPro: false,
            subscriptionExpiresAt: nil,
            promotionProIsActive: true,
            promotionProExpiresAt: nil,
        )

        #expect(MembershipResolver.proIsActive(inputs: inputs))
        #expect(MembershipResolver.proExpiresAt(inputs: inputs) == nil)
    }

    @Test
    func `Permanent subscription wins over dated promotion`() {
        let inputs = MembershipInputs(
            subscriptionIsPro: true,
            subscriptionExpiresAt: nil,
            promotionProIsActive: true,
            promotionProExpiresAt: Self.near,
        )

        #expect(MembershipResolver.proExpiresAt(inputs: inputs) == nil)
    }

    @Test
    func `Nothing active → proIsActive false`() {
        let inputs = MembershipInputs(
            subscriptionIsPro: false,
            subscriptionExpiresAt: nil,
            promotionProIsActive: false,
            promotionProExpiresAt: nil,
        )

        #expect(MembershipResolver.proIsActive(inputs: inputs) == false)
    }
}
