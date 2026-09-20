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
                ForEach(Array($drafts.enumerated()), id: \.element.id) { index, $draft in
                    let unlocked = index == 0 || drafts[index - 1].beforeItem != nil
                    AddPairDraftCard(draft: $draft, thumbnailCache: thumbnailCache)
                        .disabled(!unlocked)
                        .opacity(unlocked ? 1 : 0.4)
                        .containerRelativeFrame(.horizontal)
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
        VStack(spacing: 8) {
            HStack(spacing: 0) {
                Text(String(localized: "addpair_label_before"))
                    .frame(maxWidth: .infinity)
                Text(String(localized: "addpair_label_after"))
                    .frame(maxWidth: .infinity)
                    .opacity(draft.beforeItem == nil ? 0.4 : 1)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)

            Color.clear
                .aspectRatio(1.8, contentMode: .fit)
                .overlay {
                    HStack(spacing: 0) {
                        AddPairSlot(item: $draft.beforeItem, thumbnailCache: thumbnailCache)

                        Rectangle()
                            .fill(Color(uiColor: .separator).opacity(0.5))
                            .frame(width: 1)

                        AddPairSlot(item: $draft.afterItem, thumbnailCache: thumbnailCache)
                            .disabled(draft.beforeItem == nil)
                            .opacity(draft.beforeItem == nil ? 0.4 : 1)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color(.separator), lineWidth: 0.5),
                )
        }
    }
}

private struct AddPairSlot: View {
    @Binding var item: PhotosPickerItem?
    let thumbnailCache: PhotoLibraryThumbnailCache

    @State private var thumbnail: UIImage?
    @State private var isLoading = false

    var body: some View {
        let thumbnail = thumbnail
        let isLoading = isLoading
        PhotosPicker(
            selection: $item,
            matching: .images,
            photoLibrary: .shared(),
        ) {
            Rectangle()
                .fill(Color(.secondarySystemGroupedBackground))
                .overlay {
                    if let thumbnail {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .scaledToFill()
                    } else if isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.secondary)
                    } else {
                        Image(systemName: "photo.badge.plus")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                }
                .clipped()
        }
        .task(id: item) { await loadThumbnail() }
    }

    private func loadThumbnail() async {
        guard let identifier = item?.itemIdentifier else {
            thumbnail = nil
            return
        }
        isLoading = true
        thumbnail = await thumbnailCache.image(for: identifier)
        isLoading = false
    }
}
