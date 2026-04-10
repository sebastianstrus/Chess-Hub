import SwiftUI

struct PuzzleLibraryView: View {
    @Environment(PuzzleStore.self) private var store
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                DS.Colors.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: DS.Spacing.lg) {
                        SearchBar(text: $searchText)
                            .padding(.horizontal, DS.Spacing.lg)
                            .padding(.top, DS.Spacing.md)

                        LazyVStack(spacing: DS.Spacing.md) {
                            ForEach(filteredThemes) { theme in
                                NavigationLink(destination: PuzzleListView(theme: theme)) {
                                    CategoryListRow(theme: theme, count: store.totalCount(forTheme: theme))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, DS.Spacing.lg)
                        .padding(.bottom, DS.Spacing.xxxl)
                    }
                }
            }
            .navigationTitle("Puzzles")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var filteredThemes: [PuzzleTheme] {
        guard !searchText.isEmpty else { return PuzzleTheme.browsable }
        return PuzzleTheme.browsable.filter {
            $0.rawValue.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    var body: some View {
        HStack(spacing: DS.Spacing.sm) {
            Image(systemName: "magnifyingglass").font(.system(size: 15))
                .foregroundColor(DS.Colors.textTertiary)
            TextField("Search categories…", text: $text)
                .font(.system(size: 15)).foregroundColor(DS.Colors.textPrimary).tint(DS.Colors.gold)
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 15))
                        .foregroundColor(DS.Colors.textTertiary)
                }
            }
        }
        .padding(.horizontal, DS.Spacing.md).frame(height: 44)
        .background(DS.Colors.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.full))
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.full).strokeBorder(DS.Colors.border, lineWidth: 1))
    }
}

// MARK: - Category List Row
struct CategoryListRow: View {
    let theme: PuzzleTheme; let count: Int

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: DS.Radius.md)
                    .fill(LinearGradient(colors: theme.gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 52, height: 52)
                    .shadow(color: theme.gradient[0].opacity(0.4), radius: 8, x: 0, y: 4)
                Image(systemName: theme.icon).font(.system(size: 22, weight: .semibold)).foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(theme.rawValue).font(.system(size: 16, weight: .semibold)).foregroundColor(DS.Colors.textPrimary)
                Text(theme.description).font(.system(size: 13)).foregroundColor(DS.Colors.textTertiary).lineLimit(1)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(count)").font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(theme.gradient[0])
                HStack(spacing: 2) {
                    Text(theme.difficulty).font(.system(size: 11)).foregroundColor(DS.Colors.textTertiary)
                    Image(systemName: "chevron.right").font(.system(size: 10, weight: .semibold))
                        .foregroundColor(DS.Colors.textTertiary)
                }
            }
        }
        .padding(DS.Spacing.md).background(DS.Colors.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.lg).strokeBorder(DS.Colors.border, lineWidth: 1))
    }
}
