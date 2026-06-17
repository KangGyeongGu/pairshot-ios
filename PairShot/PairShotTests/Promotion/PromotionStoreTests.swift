import Foundation
@testable import PairShot
import Testing

@MainActor
struct PromotionStoreTests {
    private static let frozenNow = Date(timeIntervalSinceReferenceDate: 700_000_000)

    @Test
    func `Initial state: nothing active when no snapshot exists`() {
        let defaults = Self.makeIsolatedDefaults()
        let store = PromotionStore(
            fetcher: StubFetcher(snapshot: nil),
            deviceHashProvider: DeviceHashProvider(identifierResolver: { "device-id" }),
            defaults: defaults,
        )

        #expect(store.proIsActive == false)
        #expect(store.proExpiresAt == nil)
    }

    @Test
    func `Pro promotion: refresh sets proIsActive`() async {
        let defaults = Self.makeIsolatedDefaults()
        let expiry = Self.frozenNow.addingTimeInterval(60 * 60 * 24 * 365)
        let snapshot = MembershipSnapshot(
            pro: .init(active: true, expiresAt: expiry),
        )
        let store = PromotionStore(
            fetcher: StubFetcher(snapshot: snapshot),
            deviceHashProvider: DeviceHashProvider(identifierResolver: { "device-id" }),
            defaults: defaults,
            clock: { Self.frozenNow },
        )

        await store.refresh()

        #expect(store.proIsActive == true)
        #expect(store.proExpiresAt == expiry)
    }

    @Test
    func `Permanent promotion: nil expiresAt preserved`() async {
        let defaults = Self.makeIsolatedDefaults()
        let snapshot = MembershipSnapshot(
            pro: .init(active: true, expiresAt: nil),
        )
        let store = PromotionStore(
            fetcher: StubFetcher(snapshot: snapshot),
            deviceHashProvider: DeviceHashProvider(identifierResolver: { "device-id" }),
            defaults: defaults,
        )

        await store.refresh()

        #expect(store.proIsActive == true)
        #expect(store.proExpiresAt == nil)
    }

    @Test
    func `refresh keeps state when fetcher returns nil`() async {
        let defaults = Self.makeIsolatedDefaults()
        let store = PromotionStore(
            fetcher: StubFetcher(snapshot: nil),
            deviceHashProvider: DeviceHashProvider(identifierResolver: { "device-id" }),
            defaults: defaults,
        )

        await store.refresh()

        #expect(store.proIsActive == false)
    }

    @Test
    func `만료된 expiresAt 스냅샷은 init 시 active false 로 강제된다`() async {
        let defaults = Self.makeIsolatedDefaults()
        let pastExpiry = Self.frozenNow.addingTimeInterval(-60 * 60 * 24)
        let snapshot = MembershipSnapshot(
            pro: .init(active: true, expiresAt: pastExpiry),
        )
        let firstStore = PromotionStore(
            fetcher: StubFetcher(snapshot: snapshot),
            deviceHashProvider: DeviceHashProvider(identifierResolver: { "device-id" }),
            defaults: defaults,
            clock: { Self.frozenNow },
        )
        await firstStore.refresh()

        let reload = PromotionStore(
            fetcher: StubFetcher(snapshot: nil),
            deviceHashProvider: DeviceHashProvider(identifierResolver: { "device-id" }),
            defaults: defaults,
            clock: { Self.frozenNow },
        )

        #expect(reload.proIsActive == false)
        #expect(reload.proExpiresAt == pastExpiry)
    }

    @Test
    func `refresh 시 만료된 active true 항목은 false 로 게이팅된다`() async {
        let defaults = Self.makeIsolatedDefaults()
        let pastExpiry = Self.frozenNow.addingTimeInterval(-3600)
        let snapshot = MembershipSnapshot(
            pro: .init(active: true, expiresAt: pastExpiry),
        )
        let store = PromotionStore(
            fetcher: StubFetcher(snapshot: snapshot),
            deviceHashProvider: DeviceHashProvider(identifierResolver: { "device-id" }),
            defaults: defaults,
            clock: { Self.frozenNow },
        )

        await store.refresh()

        #expect(store.proIsActive == false)
    }

    @Test
    func `Snapshot persistence: subsequent init restores prior state`() async {
        let defaults = Self.makeIsolatedDefaults()
        let expiry = Self.frozenNow.addingTimeInterval(60 * 60 * 24 * 7)
        let snapshot = MembershipSnapshot(
            pro: .init(active: true, expiresAt: expiry),
        )
        let firstStore = PromotionStore(
            fetcher: StubFetcher(snapshot: snapshot),
            deviceHashProvider: DeviceHashProvider(identifierResolver: { "device-id" }),
            defaults: defaults,
            clock: { Self.frozenNow },
        )
        await firstStore.refresh()

        let secondStore = PromotionStore(
            fetcher: StubFetcher(snapshot: nil),
            deviceHashProvider: DeviceHashProvider(identifierResolver: { "device-id" }),
            defaults: defaults,
            clock: { Self.frozenNow },
        )

        #expect(secondStore.proIsActive == true)
        #expect(secondStore.proExpiresAt == expiry)
    }

    private static func makeIsolatedDefaults() -> UserDefaults {
        let suiteName = "PromotionStoreTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName) ?? .standard
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }
}

private struct StubFetcher: PromotionFetching {
    let snapshot: MembershipSnapshot?

    func fetch(deviceHash _: String) async -> MembershipSnapshot? {
        snapshot
    }
}
