import SwiftUI

struct PuzzleListView: View {
    @EnvironmentObject var dataProvider: PuzzleDataProvider
    let category: PuzzleCategory

    var puzzles: [ChessPuzzle] {
        dataProvider.puzzles(for: category)
    }

    var body: some View {
        ZStack {
            DS.Colors.background.ignoresSafeArea()

            if puzzles.isEmpty {
                EmptyStateView(category: category)
            } else {
                ScrollView(showsIndicators: false) {
                    // Header banner
                    CategoryBannerView(category: category, count: puzzles.count)
                        .padding(.bottom, DS.Spacing.lg)

                    LazyVStack(spacing: DS.Spacing.md) {
                        ForEach(Array(puzzles.enumerated()), id: \.element.id) { index, puzzle in
                            NavigationLink(destination: PuzzleDetailView(puzzle: puzzle)) {
                                PuzzleRowCard(puzzle: puzzle, index: index)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, DS.Spacing.lg)
                    .padding(.bottom, DS.Spacing.xxxl)
                }
            }
        }
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Category Banner

struct CategoryBannerView: View {
    let category: PuzzleCategory
    let count: Int

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [category.gradient[0].opacity(0.25), DS.Colors.background],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 160)

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                    HStack(spacing: DS.Spacing.sm) {
                        Image(systemName: category.icon)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(category.gradient[0])
                        Text(category.difficulty.uppercased())
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(category.gradient[0])
                            .tracking(1.5)
                    }

                    Text(category.rawValue)
                        .font(.system(size: 30, weight: .bold, design: .serif))
                        .foregroundColor(DS.Colors.textPrimary)

                    Text(category.description)
                        .font(.system(size: 13))
                        .foregroundColor(DS.Colors.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("\(count)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(category.gradient[0].opacity(0.4))
                    Text("puzzles")
                        .font(.system(size: 12))
                        .foregroundColor(DS.Colors.textTertiary)
                        .offset(y: -8)
                }
            }
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.bottom, DS.Spacing.lg)
        }
    }
}

// MARK: - Puzzle Row Card

struct PuzzleRowCard: View {
    @EnvironmentObject var dataProvider: PuzzleDataProvider
    let puzzle: ChessPuzzle
    let index: Int

    @State private var appeared = false

    var isFav: Bool { dataProvider.isFavorite(puzzle) }

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            // Puzzle number
            ZStack {
                RoundedRectangle(cornerRadius: DS.Radius.sm)
                    .fill(DS.Colors.surface)
                    .frame(width: 44, height: 44)
                    .overlay(RoundedRectangle(cornerRadius: DS.Radius.sm).strokeBorder(DS.Colors.border, lineWidth: 1))

                Text("#\(index + 1)")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(DS.Colors.textTertiary)
            }

            // Image placeholder / thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: DS.Radius.sm)
                    .fill(DS.Colors.surface)
                    .frame(width: 60, height: 60)
                    .overlay(RoundedRectangle(cornerRadius: DS.Radius.sm).strokeBorder(DS.Colors.border, lineWidth: 1))

                // Shows actual image if asset exists, otherwise mini board
                if UIImage(named: puzzle.imageName) != nil {
                    Image(puzzle.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                } else {
                    MiniChessBoard()
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }

            // Details
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text(puzzle.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(DS.Colors.textPrimary)
                    .lineLimit(1)

                DifficultyBadge(difficulty: puzzle.difficulty)
            }

            Spacer()

            // Favorite button
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    dataProvider.toggleFavorite(puzzle)
                }
            } label: {
                Image(systemName: isFav ? "heart.fill" : "heart")
                    .font(.system(size: 18))
                    .foregroundColor(isFav ? DS.Colors.danger : DS.Colors.textTertiary)
                    .scaleEffect(isFav ? 1.1 : 1)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isFav)
            }
            .padding(.leading, DS.Spacing.xs)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(DS.Colors.textTertiary)
        }
        .padding(DS.Spacing.md)
        .background(DS.Colors.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.lg).strokeBorder(DS.Colors.border, lineWidth: 1))
        .opacity(appeared ? 1 : 0)
        .offset(x: appeared ? 0 : -20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(Double(index) * 0.05)) { appeared = true }
        }
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    let category: PuzzleCategory

    var body: some View {
        VStack(spacing: DS.Spacing.lg) {
            Spacer()

            ZStack {
                Circle()
                    .fill(DS.Colors.surfaceElevated)
                    .frame(width: 100, height: 100)
                    .overlay(Circle().strokeBorder(DS.Colors.border, lineWidth: 1))

                Image(systemName: category == .favorites ? "heart" : "square.grid.2x2")
                    .font(.system(size: 40))
                    .foregroundColor(DS.Colors.textTertiary)
            }

            VStack(spacing: DS.Spacing.sm) {
                Text(category == .favorites ? "No Favorites Yet" : "No Puzzles")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(DS.Colors.textPrimary)

                Text(category == .favorites
                    ? "Heart any puzzle to save it here for quick access."
                    : "Puzzles for this category will appear here.")
                    .font(.system(size: 14))
                    .foregroundColor(DS.Colors.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DS.Spacing.xl)
            }

            Spacer()
        }
    }
}
