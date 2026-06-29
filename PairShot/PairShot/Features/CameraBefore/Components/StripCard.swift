import SwiftUI
import UIKit

struct StripCard: View {
    private enum HoldOrientation {
        case unknown
        case landscape
        case portrait
    }

    @Environment(AppEnvironment.self) private var env
    @Environment(\.displayScale) private var displayScale

    let pair: PhotoPair
    let isActive: Bool
    let stripZoneHeight: CGFloat

    @State private var thumbnail: UIImage?
    @State private var hold: HoldOrientation = .unknown

    private var cardWidth: CGFloat {
        StripDesign.cardWidth(stripHeight: stripZoneHeight)
    }

    private var cardHeight: CGFloat {
        StripDesign.cardHeight(stripHeight: stripZoneHeight)
    }

    private var cornerRadius: CGFloat {
        StripDesign.cornerRadius(stripHeight: stripZoneHeight)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.white.opacity(0.06))

            if let thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "photo")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.45))
            }
        }
        .frame(width: cardWidth, height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(alignment: .topTrailing) {
            if hold != .unknown {
                orientationBadge(isLandscape: hold == .landscape)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(
                    isActive ? StripDesign.activeBorderColor : StripDesign.inactiveBorderColor,
                    lineWidth: isActive ? StripDesign.activeBorderWidth : StripDesign.inactiveBorderWidth,
                ),
        )
        .scaleEffect(isActive ? StripDesign.activeScale : StripDesign.inactiveScale, anchor: .center)
        .animation(.easeInOut(duration: 0.18), value: isActive)
        .task(id: pair.id) {
            await loadThumbnail()
        }
    }

    private func loadThumbnail() async {
        guard let identifier = pair.beforePhotoLocalIdentifier, !identifier.isEmpty else { return }
        let scale = max(1, displayScale)
        thumbnail = await env.thumbnailCache.image(
            for: identifier,
            pixelSize: cardWidth * scale,
        )
        if let orientation = await env.thumbnailCache.orientation(for: identifier) {
            hold = orientation.indicatesLandscapeHold ? .landscape : .portrait
        }
    }

    @ViewBuilder
    private func orientationBadge(isLandscape: Bool) -> some View {
        let badgeSize = cardWidth * 0.3
        Image(systemName: "iphone")
            .font(.system(size: badgeSize * 0.56, weight: .semibold))
            .foregroundStyle(.white)
            .rotationEffect(isLandscape ? .degrees(90) : .zero)
            .frame(width: badgeSize, height: badgeSize)
            .background(.black.opacity(0.5), in: RoundedRectangle(cornerRadius: badgeSize * 0.28))
            .padding(cardWidth * 0.06)
    }
}
