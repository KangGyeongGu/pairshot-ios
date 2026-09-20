import Foundation
@testable import PairShot
import SwiftData
import Testing

@MainActor
struct HomeViewModelAddPairTests {
    @Test
    func `openAddPair — 무료 사용자 + 일일 한도 초과 시 showPaywall=true + 시트 미표시`() async throws {
        let env = Self.makeEnv()
        let today = Date()
        for _ in 0 ..< PairLimitGate.freeTierDailyLimit {
            try await env.pairRepo.add(FixturePhotoPair.make(createdAt: today))
        }
        let viewModel = env.makeHomeViewModel()

        await viewModel.openAddPair()

        #expect(viewModel.showPaywall == true)
        #expect(viewModel.showAddPair == false)
    }

    @Test
    func `openAddPair — 한도 미만이면 시트 표시 + 잔여 수량 설정`() async {
        let env = Self.makeEnv()
        let viewModel = env.makeHomeViewModel()

        await viewModel.openAddPair()

        #expect(viewModel.showAddPair == true)
        #expect(viewModel.showPaywall == false)
        #expect(viewModel.addPairDrafts.count == 2)
        #expect(viewModel.addPairDrafts.allSatisfy { $0.beforeItem == nil && $0.afterItem == nil })
        #expect(viewModel.addPairErrorText == nil)
        #expect(viewModel.addPairSelectionLimit == PairLimitGate.freeTierDailyLimit)
    }

    @Test
    func `openAddPair — 오늘 3개 생성했으면 잔여 수량 = 한도-3`() async throws {
        let env = Self.makeEnv()
        for _ in 0 ..< 3 {
            try await env.pairRepo.add(FixturePhotoPair.make(createdAt: Date()))
        }
        let viewModel = env.makeHomeViewModel()

        await viewModel.openAddPair()

        #expect(viewModel.showAddPair == true)
        #expect(viewModel.addPairSelectionLimit == PairLimitGate.freeTierDailyLimit - 3)
    }

    static func makeEnv() -> AppEnvironment {
        let suiteName = "homeviewmodel-addpair-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName) ?? .standard
        let settings = AppSettings(defaults: defaults)
        let promotionStore = PromotionStore(
            fetcher: PromotionFetcher(config: CouponApiConfig.resolve()),
            deviceHashProvider: DeviceHashProvider(),
            defaults: defaults,
        )
        return AppEnvironment(
            modelContainer: makeContainer(),
            appSettings: settings,
            promotionStore: promotionStore,
        )
    }

    static func makeContainer() -> ModelContainer {
        let schema = Schema(versionedSchema: SchemaV1.self)
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("test container failure: \(error)")
        }
    }
}

struct AddPairAspectInferenceTests {
    @Test
    func `4032x3024 (기본 카메라 4:3) → fourThree`() {
        #expect(AddPairAspectInference.nearestAspect(pixelWidth: 4032, pixelHeight: 3024) == .fourThree)
        #expect(AddPairAspectInference.nearestAspect(pixelWidth: 3024, pixelHeight: 4032) == .fourThree)
    }

    @Test
    func `3840x2160 (16:9) → sixteenNine`() {
        #expect(AddPairAspectInference.nearestAspect(pixelWidth: 3840, pixelHeight: 2160) == .sixteenNine)
        #expect(AddPairAspectInference.nearestAspect(pixelWidth: 2160, pixelHeight: 3840) == .sixteenNine)
    }

    @Test
    func `2000x2000 (정방형) → square`() {
        #expect(AddPairAspectInference.nearestAspect(pixelWidth: 2000, pixelHeight: 2000) == .square)
    }

    @Test
    func `9:19.5 초광폭 크롭 → 최근접 sixteenNine`() {
        #expect(AddPairAspectInference.nearestAspect(pixelWidth: 1170, pixelHeight: 2532) == .sixteenNine)
    }

    @Test
    func `0 치수 방어 → default`() {
        #expect(AddPairAspectInference.nearestAspect(pixelWidth: 0, pixelHeight: 0) == .default)
    }
}

struct GhostRotationRuleTests {
    @Test
    func `가로 픽셀(센서 네이티브·무편집 갤러리) → 90도`() {
        #expect(GhostRotationRule.degrees(pixelWidth: 4032, pixelHeight: 3024) == 90)
    }

    @Test
    func `세로 픽셀(방향 베이크된 갤러리 사진) → 0도`() {
        #expect(GhostRotationRule.degrees(pixelWidth: 3024, pixelHeight: 4032) == 0)
    }

    @Test
    func `정방형 → 90도 (기존 센서 규약 유지)`() {
        #expect(GhostRotationRule.degrees(pixelWidth: 2000, pixelHeight: 2000) == 90)
    }
}
