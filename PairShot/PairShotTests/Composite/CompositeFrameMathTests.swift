import CoreGraphics
import Foundation
@testable import PairShot
import Testing

struct CompositeFrameMathTests {
    private static let landscape = CGSize(width: 1200, height: 800)
    private static let portrait = CGSize(width: 800, height: 1200)
    private static let noBorders = EdgeBorders.uniform(0)

    @Test
    func `paneScaledSizes: 종횡비가 달라도 두 칸이 동일 슬롯 (minW, minH)`() {
        let panes = CompositeFrameMath.paneScaledSizes(
            beforeSize: Self.landscape,
            afterSize: Self.portrait,
        )
        #expect(panes.before == panes.after)
        #expect(panes.before == CGSize(width: 800, height: 800))
    }

    @Test
    func `horizontal: 종횡비 다른 페어도 두 칸 너비가 정확히 50:50`() {
        let panes = CompositeFrameMath.paneScaledSizes(beforeSize: Self.landscape, afterSize: Self.portrait)
        let frames = CompositeFrameMath.horizontal(paneSizes: panes, borders: Self.noBorders)
        #expect(frames.beforeRect.width == frames.afterRect.width)
        #expect(frames.beforeRect.height == frames.afterRect.height)
        #expect(frames.beforeRect.width == frames.canvas.width / 2)
    }

    @Test
    func `vertical: 종횡비 다른 페어도 두 칸 높이가 정확히 50:50`() {
        let panes = CompositeFrameMath.paneScaledSizes(beforeSize: Self.landscape, afterSize: Self.portrait)
        let frames = CompositeFrameMath.vertical(paneSizes: panes, borders: Self.noBorders)
        #expect(frames.beforeRect.height == frames.afterRect.height)
        #expect(frames.beforeRect.width == frames.afterRect.width)
        #expect(frames.beforeRect.height == frames.canvas.height / 2)
    }

    @Test
    func `동일 크기 사진은 슬롯 그대로 유지 (회귀)`() {
        let size = CGSize(width: 800, height: 600)
        let panes = CompositeFrameMath.paneScaledSizes(beforeSize: size, afterSize: size)
        #expect(panes.before == size)
        #expect(panes.after == size)
    }

    @Test
    func `0 이하 크기는 1 로 클램프`() {
        let panes = CompositeFrameMath.paneScaledSizes(
            beforeSize: .zero,
            afterSize: CGSize(width: 500, height: 500),
        )
        #expect(panes.before == CGSize(width: 1, height: 1))
        #expect(panes.after == CGSize(width: 1, height: 1))
    }
}
