import SwiftUI

struct PuzzleLibraryView: View {
    @EnvironmentObject var dataProvider: PuzzleDataProvider
    @State private var searchText = ""

    let categories: [PuzzleCategory] = [.mateIn1, .mateIn2, .mateIn3, .mateIn4, .selfmate]

    var body: some View {
        NavigationStack {
            ZStack {
                DS.Colors.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: DS.Spacing.lg) {
                        // Search bar
                        SearchBar(text: $searchText)
                            .padding(.horizontal, DS.Spacing.lg)
                            .padding(.top, DS.Spacing.md)

                        // Category list
                        LazyVStack(spacing: DS.Spacing.md) {
                            ForEach(categories) { category in
                                NavigationLink(destination: PuzzleListView(category: category)) {
                                    CategoryListRow(category: category, count: dataProvider.puzzleCount(for: category))
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
}

// MARK: - Search Bar

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: DS.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15))
                .foregroundColor(DS.Colors.textTertiary)

            TextField("Search puzzles…", text: $text)
                .font(.system(size: 15))
                .foregroundColor(DS.Colors.textPrimary)
                .tint(DS.Colors.gold)

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundColor(DS.Colors.textTertiary)
                }
            }
        }
        .padding(.horizontal, DS.Spacing.md)
        .frame(height: 44)
        .background(DS.Colors.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.full))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.full)
                .strokeBorder(DS.Colors.border, lineWidth: 1)
        )
    }
}

// MARK: - Category List Row

struct CategoryListRow: View {
    let category: PuzzleCategory
    let count: Int

    @State private var appeared = false

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: DS.Radius.md)
                    .fill(
                        LinearGradient(
                            colors: category.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)
                    .shadow(color: category.gradient[0].opacity(0.4), radius: 8, x: 0, y: 4)

                Image(systemName: category.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
            }

            // Text
            VStack(alignment: .leading, spacing: 3) {
                Text(category.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DS.Colors.textPrimary)

                Text(category.description)
                    .font(.system(size: 13))
                    .foregroundColor(DS.Colors.textTertiary)
                    .lineLimit(1)
            }

            Spacer()

            // Count + chevron
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(count)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(category.gradient[0])

                HStack(spacing: 2) {
                    Text(category.difficulty)
                        .font(.system(size: 11))
                        .foregroundColor(DS.Colors.textTertiary)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(DS.Colors.textTertiary)
                }
            }
        }
        .padding(DS.Spacing.md)
        .background(DS.Colors.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.lg)
                .strokeBorder(DS.Colors.border, lineWidth: 1)
        )
    }
}
