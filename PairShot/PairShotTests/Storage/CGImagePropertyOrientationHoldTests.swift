import ImageIO
@testable import PairShot
import Testing

struct CGImagePropertyOrientationHoldTests {
    @Test
    func `orientation 1~4 는 가로(landscape) hold`() {
        for raw in UInt32(1) ... 4 {
            let orientation = CGImagePropertyOrientation(rawValue: raw)
            #expect(orientation?.indicatesLandscapeHold == true)
        }
    }

    @Test
    func `orientation 5~8 은 세로(portrait) hold`() {
        for raw in UInt32(5) ... 8 {
            let orientation = CGImagePropertyOrientation(rawValue: raw)
            #expect(orientation?.indicatesLandscapeHold == false)
        }
    }
}
