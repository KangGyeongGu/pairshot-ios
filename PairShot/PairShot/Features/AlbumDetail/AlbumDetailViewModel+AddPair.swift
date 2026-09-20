import Foundation

extension AlbumDetailViewModel: PairAddingHost {
    var addPairTargetAlbumId: UUID? {
        albumId
    }
}
