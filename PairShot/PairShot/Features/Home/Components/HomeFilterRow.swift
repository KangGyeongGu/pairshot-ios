import SwiftUI

struct HomeFilterRow: View {
    @Binding var contentMode: HomeContentMode
    @Binding var sortOrder: HomeSortOrder
    let onModeChange: (HomeContentMode) -> Void
    let onSortOrderChange: (HomeSortOrder) -> Void

    @Environment(\.isEnabled) private var isEnabled
    @Namespace private var segmentNamespace

    var body: some View {
        Group {
            if #available(iOS 26.0, *) {
                GlassEffectContainer(spacing: 12) {
                    row
                }
            } else {
                row
            }
        }
        .opacity(isEnabled ? 1 : 0.4)
    }

    private var row: some View {
        HStack(spacing: 12) {
            modeToggle
                .frame(maxWidth: 220)
                .modifier(HomeFilterControlGlass(shape: AnyShape(Capsule())))
            Spacer()
            sortMenu
                .modifier(HomeFilterControlGlass(shape: AnyShape(Circle())))
        }
    }

    private var modeToggle: some View {
        HStack(spacing: 0) {
            modeButton(.pairs, title: String(localized: "home_filter_all"))
            modeButton(.albums, title: String(localized: "home_filter_album"))
        }
        .padding(4)
    }

    private var sortMenu: some View {
        Menu {
            Picker(String(localized: "common_sort_label"), selection: sortBinding) {
                Text(String(localized: "common_label_sort_descending")).tag(HomeSortOrder.newest)
                Text(String(localized: "common_label_sort_ascending")).tag(HomeSortOrder.oldest)
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .font(.subheadline.weight(.semibold))
                .frame(width: 40, height: 40)
                .contentShape(Circle())
        }
        .accessibilityLabel(String(localized: "common_sort_label"))
    }

    private var sortBinding: Binding<HomeSortOrder> {
        Binding(
            get: { sortOrder },
            set: { newValue in
                onSortOrderChange(newValue)
            },
        )
    }

    private var segmentHighlight: some View {
        Capsule()
            .fill(Color.primary.opacity(0.12))
            .matchedGeometryEffect(id: "segmentHighlight", in: segmentNamespace)
    }

    private func modeButton(_ mode: HomeContentMode, title: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                onModeChange(mode)
            }
        } label: {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(contentMode == mode ? Color.primary : Color.secondary)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity)
                .background {
                    if contentMode == mode {
                        segmentHighlight
                    }
                }
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(contentMode == mode ? [.isSelected] : [])
    }
}

private struct HomeFilterControlGlass: ViewModifier {
    let shape: AnyShape

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular.interactive(), in: shape)
        } else {
            content.background(.ultraThinMaterial, in: shape)
        }
    }
}
