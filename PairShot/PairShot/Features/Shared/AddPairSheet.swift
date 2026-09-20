import PhotosUI
import SwiftUI

struct AddPairSheet: View {
    @Binding var drafts: [AddPairDraft]
    let selectionLimit: Int?
    let errorText: String?
    let thumbnailCache: PhotoLibraryThumbnailCache
    let onConfirm: () -> Void

    @State private var scrolledDraftId: AddPairDraft.ID?

    private var filledCount: Int {
        drafts.count { $0.beforeItem != nil }
    }

    private var currentIndex: Int {
        guard let scrolledDraftId else { return 0 }
        return drafts.firstIndex { $0.id == scrolledDraftId } ?? 0
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(String(localized: "addpair_dialog_title"))
                .font(.title3.weight(.semibold))
                .padding(.top, 28)

            Text(String(localized: "addpair_desc_assist"))
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer(minLength: 8)

            draftPager

            pageIndicator

            Text(String(localized: "addpair_desc_swipe"))
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer(minLength: 8)

            if let errorText {
                Text(errorText)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            Button(action: onConfirm) {
                Text(
                    String(
                        format: String(localized: "addpair_button_confirm_int"),
                        filledCount,
                    ),
                )
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 36)
            }
            .buttonStyle(.borderedProminent)
            .disabled(filledCount == 0)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .onChange(of: drafts) { _, updated in
            appendEmptyDraftIfNeeded(updated)
        }
        .presentationDetents([.fraction(0.6)])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color(.systemGroupedBackground))
    }

    private var draftPager: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 20) {
                ForEach($drafts) { $draft in
                    AddPairDraftCard(draft: $draft, thumbnailCache: thumbnailCache)
                        .containerRelativeFrame(.horizontal) { length, _ in
                            length - 72
                        }
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(.horizontal, 36, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $scrolledDraftId)
        .scrollIndicators(.hidden)
    }

    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(drafts.indices, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Color.primary : Color.secondary.opacity(0.3))
                    .frame(width: 7, height: 7)
            }
        }
    }

    private func appendEmptyDraftIfNeeded(_ updated: [AddPairDraft]) {
        guard let last = updated.last, last.beforeItem != nil else { return }
        guard updated.count < (selectionLimit ?? Int.max) else { return }
        drafts.append(AddPairDraft())
    }
}

private struct AddPairDraftCard: View {
    @Binding var draft: AddPairDraft
    let thumbnailCache: PhotoLibraryThumbnailCache

    var body: some View {
        HStack(spacing: 12) {
            AddPairSlot(
                title: String(localized: "addpair_label_before"),
                item: $draft.beforeItem,
                thumbnailCache: thumbnailCache,
            )
            AddPairSlot(
                title: String(localized: "addpair_label_after"),
                item: $draft.afterItem,
                thumbnailCache: thumbnailCache,
            )
            .disabled(draft.beforeItem == nil)
            .opacity(draft.beforeItem == nil ? 0.4 : 1)
        }
    }
}

private struct AddPairSlot: View {
    let title: String
    @Binding var item: PhotosPickerItem?
    let thumbnailCache: PhotoLibraryThumbnailCache

    @State private var thumbnail: UIImage?

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            PhotosPicker(
                selection: $item,
                matching: .images,
                photoLibrary: .shared(),
            ) {
                slotContent
            }
        }
        .task(id: item) { await loadThumbnail() }
    }

    private var slotContent: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemGroupedBackground))
            if let thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "photo.badge.plus")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(3.0 / 4.0, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color(.separator), lineWidth: 0.5),
        )
    }

    private func loadThumbnail() async {
        guard let identifier = item?.itemIdentifier else {
            thumbnail = nil
            return
        }
        thumbnail = await thumbnailCache.image(for: identifier)
    }
}
