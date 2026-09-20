import Foundation
import Photos
import PhotosUI
import SwiftUI

struct AddPairDraft: Identifiable, Equatable {
    let id = UUID()
    var beforeItem: PhotosPickerItem?
    var afterItem: PhotosPickerItem?
}

@MainActor
protocol PairAddingHost: CaptureStarter {
    var showAddPair: Bool { get set }
    var addPairDrafts: [AddPairDraft] { get set }
    var addPairErrorText: String? { get set }
    var addPairSelectionLimit: Int? { get set }
    var addPairTargetAlbumId: UUID? { get }

    var photoLibrary: PhotoLibraryService { get }
    var thumbnailCache: PhotoLibraryThumbnailCache { get }
    var albumRepo: AlbumRepository { get }
}

extension PairAddingHost {
    func openAddPair() async {
        let quota = await dailyPairQuotaRemaining()
        if let quota, quota <= 0 {
            presentDailyLimitGate()
            return
        }
        addPairSelectionLimit = quota
        let initialCount = min(2, quota ?? 2)
        addPairDrafts = (0 ..< initialCount).map { _ in AddPairDraft() }
        addPairErrorText = nil
        showAddPair = true
    }

    func confirmAddPair() async {
        let filled = addPairDrafts.filter { $0.beforeItem != nil }
        guard !filled.isEmpty else { return }
        var resolved: [ResolvedAddPairEntry] = []
        for draft in filled {
            guard let beforeId = draft.beforeItem?.itemIdentifier,
                  let beforeAsset = photoLibrary.fetchAsset(localIdentifier: beforeId)
            else {
                addPairErrorText = String(localized: "addpair_desc_inaccessible")
                return
            }
            var afterId: String?
            var afterAsset: PHAsset?
            if let afterItem = draft.afterItem {
                guard let id = afterItem.itemIdentifier,
                      let asset = photoLibrary.fetchAsset(localIdentifier: id)
                else {
                    addPairErrorText = String(localized: "addpair_desc_inaccessible")
                    return
                }
                afterId = id
                afterAsset = asset
            }
            resolved.append(
                ResolvedAddPairEntry(
                    beforeId: beforeId,
                    beforeAsset: beforeAsset,
                    afterId: afterId,
                    afterAsset: afterAsset,
                ),
            )
        }
        var createdDraftIds: Set<UUID> = []
        for (index, entry) in resolved.enumerated() {
            let pair = PhotoPair(
                beforePhotoLocalIdentifier: entry.beforeId,
                afterPhotoLocalIdentifier: entry.afterId,
                createdAt: entry.beforeAsset.creationDate ?? .now,
                afterCapturedAt: entry.afterAsset?.creationDate,
                latitude: entry.beforeAsset.location?.coordinate.latitude,
                longitude: entry.beforeAsset.location?.coordinate.longitude,
                cameraSettings: CameraSettings(
                    aspectRatio: AddPairAspectInference.nearestAspect(
                        pixelWidth: entry.beforeAsset.pixelWidth,
                        pixelHeight: entry.beforeAsset.pixelHeight,
                    ),
                ),
            )
            do {
                try await pairRepo.add(pair)
                if let albumId = addPairTargetAlbumId {
                    try await albumRepo.addPair(pairId: pair.id, toAlbum: albumId)
                }
                createdDraftIds.insert(filled[index].id)
            } catch {
                addPairDrafts.removeAll { createdDraftIds.contains($0.id) }
                addPairErrorText = String(localized: "addpair_desc_save_failed")
                return
            }
        }
        addPairDrafts = [AddPairDraft()]
        addPairErrorText = nil
        showAddPair = false
    }
}

private struct ResolvedAddPairEntry {
    let beforeId: String
    let beforeAsset: PHAsset
    let afterId: String?
    let afterAsset: PHAsset?
}

nonisolated enum AddPairAspectInference {
    static func nearestAspect(pixelWidth: Int, pixelHeight: Int) -> AspectRatio {
        let long = Double(max(pixelWidth, pixelHeight))
        let short = Double(min(pixelWidth, pixelHeight))
        guard short > 0 else { return .default }
        let ratio = long / short
        let candidates: [(aspect: AspectRatio, value: Double)] = [
            (.fourThree, 4.0 / 3.0),
            (.sixteenNine, 16.0 / 9.0),
            (.square, 1.0),
        ]
        var best = candidates[0]
        for candidate in candidates where abs(candidate.value - ratio) < abs(best.value - ratio) {
            best = candidate
        }
        return best.aspect
    }
}
