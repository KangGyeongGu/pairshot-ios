import SwiftUI

actor FullscreenAdCoordinator {
    private(set) var isShowing: Bool = false

    init() {}

    func tryAcquire() -> Bool {
        guard !isShowing else {
            return false
        }
        isShowing = true
        return true
    }

    func release() {
        isShowing = false
    }
}

private nonisolated let defaultFullscreenAdCoordinator = FullscreenAdCoordinator()

extension EnvironmentValues {
    @Entry var fullscreenAdCoordinator: FullscreenAdCoordinator = defaultFullscreenAdCoordinator
}
