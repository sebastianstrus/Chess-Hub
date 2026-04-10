import SwiftUI

struct PuzzleListView: View {
    @Environment(PuzzleStore.self) private var store
    let theme: PuzzleTheme
    
    @State private var showFilterSheet = false

    var puzzles: [Puzzle] { store.puzzles(forTheme: theme) }

    var body: some View {
        ZStack {
            DS.Colors.background.ignoresSafeArea()
            if puzzles.isEmpty {
                EmptyStateView(message: "No puzzles found for \(theme.rawValue) with current filter.")
            } else {
                ScrollView(showsIndicators: false) {
                    CategoryBannerView(theme: theme, count: puzzles.count)
                        .padding(.bottom, DS.Spacing.sm)
                    
                    // Rating filter button
                    RatingFilterButton(currentFilter: store.ratingFilter) {
                        showFilterSheet = true
                    }
                    .padding(.horizontal, DS.Spacing.lg)
                    .padding(.bottom, DS.Spacing.lg)

                    LazyVStack(spacing: DS.Spacing.md) {
                        ForEach(Array(puzzles.enumerated()), id: \.element.id) { index, puzzle in
                            NavigationLink(destination: PuzzleSolverView(puzzle: puzzle, theme: theme)) {
                                PuzzleRowCard(puzzle: puzzle, index: index)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, DS.Spacing.lg).padding(.bottom, DS.Spacing.xxxl)
                }
            }
        }
        .navigationTitle(theme.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showFilterSheet) {
            RatingFilterSheet()
                .environment(store)
                .presentationDetents([.height(450)])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Category Banner
struct CategoryBannerView: View {
    let theme: PuzzleTheme; let count: Int
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: [theme.gradient[0].opacity(0.25), DS.Colors.background],
                           startPoint: .top, endPoint: .bottom).frame(height: 160)
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                    HStack(spacing: DS.Spacing.sm) {
                        Image(systemName: theme.icon).font(.system(size: 14, weight: .semibold))
                            .foregroundColor(theme.gradient[0])
                        Text(theme.difficulty.uppercased()).font(.system(size: 11, weight: .bold))
                            .foregroundColor(theme.gradient[0]).tracking(1.5)
                    }
                    Text(theme.rawValue).font(.system(size: 30, weight: .bold, design: .serif))
                        .foregroundColor(DS.Colors.textPrimary)
                    Text(theme.description).font(.system(size: 13))
                        .foregroundColor(DS.Colors.textSecondary).lineLimit(2)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("\(count)").font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(theme.gradient[0].opacity(0.4))
                    Text("puzzles").font(.system(size: 12)).foregroundColor(DS.Colors.textTertiary).offset(y: -8)
                }
            }
            .padding(.horizontal, DS.Spacing.lg).padding(.bottom, DS.Spacing.lg)
        }
    }
}

// MARK: - Puzzle Row Card
struct PuzzleRowCard: View {
    @Environment(PuzzleStore.self) private var store
    let puzzle: Puzzle; let index: Int
    @State private var appeared = false

    var isFav: Bool { store.isFavorite(puzzle.id) }
    var isSolved: Bool { store.isSolved(puzzle.id) }

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            // Index number
            ZStack {
                RoundedRectangle(cornerRadius: DS.Radius.sm).fill(DS.Colors.surface).frame(width: 44, height: 44)
                    .overlay(RoundedRectangle(cornerRadius: DS.Radius.sm).strokeBorder(DS.Colors.border, lineWidth: 1))
                if isSolved {
                    Image(systemName: "checkmark").font(.system(size: 14, weight: .bold))
                        .foregroundColor(DS.Colors.success)
                } else {
                    Text("#\(index + 1)").font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(DS.Colors.textTertiary)
                }
            }

            // Mini board thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: DS.Radius.sm).fill(DS.Colors.surface).frame(width: 56, height: 56)
                    .overlay(RoundedRectangle(cornerRadius: DS.Radius.sm).strokeBorder(DS.Colors.border, lineWidth: 1))
                MiniChessBoard().frame(width: 44, height: 44).clipShape(RoundedRectangle(cornerRadius: 3))
            }

            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text("Puzzle #\(puzzle.id)").font(.system(size: 15, weight: .semibold))
                    .foregroundColor(DS.Colors.textPrimary)
                    .fixedSize(horizontal: true, vertical: false)
                RatingBadge(rating: puzzle.rating)
                Text("\(puzzle.playerMoves.count) move\(puzzle.playerMoves.count == 1 ? "" : "s")")
                    .font(.system(size: 12)).foregroundColor(DS.Colors.textTertiary)
            }
            .layoutPriority(1)
            Spacer()

            // Favorite toggle
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { store.toggleFavorite(puzzle.id) }
            } label: {
                Image(systemName: isFav ? "heart.fill" : "heart").font(.system(size: 17))
                    .foregroundColor(isFav ? DS.Colors.danger : DS.Colors.textTertiary)
            }

            Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold))
                .foregroundColor(DS.Colors.textTertiary)
        }
        .padding(DS.Spacing.md).background(DS.Colors.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.lg).strokeBorder(
            isSolved ? DS.Colors.success.opacity(0.25) : DS.Colors.border, lineWidth: 1))
        .opacity(appeared ? 1 : 0).offset(x: appeared ? 0 : -20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(Double(min(index, 20)) * 0.04)) { appeared = true }
        }
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    let message: String
    var body: some View {
        VStack(spacing: DS.Spacing.lg) {
            Spacer()
            ZStack {
                Circle().fill(DS.Colors.surfaceElevated).frame(width: 100, height: 100)
                    .overlay(Circle().strokeBorder(DS.Colors.border, lineWidth: 1))
                Image(systemName: "square.grid.2x2").font(.system(size: 40)).foregroundColor(DS.Colors.textTertiary)
            }
            Text(message).font(.system(size: 15)).foregroundColor(DS.Colors.textTertiary)
                .multilineTextAlignment(.center).padding(.horizontal, DS.Spacing.xl)
            Spacer()
        }
    }
}
// MARK: - Rating Filter Button
struct RatingFilterButton: View {
    let currentFilter: RatingRange
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Spacing.sm) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 14, weight: .semibold))
                Text("Rating: \(currentFilter.rawValue)")
                    .font(.system(size: 14, weight: .medium))
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(currentFilter == .all ? DS.Colors.textSecondary : DS.Colors.gold)
            .padding(.horizontal, DS.Spacing.md)
            .padding(.vertical, DS.Spacing.sm)
            .background(DS.Colors.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.md)
                    .strokeBorder(currentFilter == .all ? DS.Colors.border : DS.Colors.gold.opacity(0.4), lineWidth: 1)
            )
        }
    }
}

// MARK: - Rating Filter Sheet
struct RatingFilterSheet: View {
    @Environment(PuzzleStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                DS.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: DS.Spacing.sm) {
                        ForEach(RatingRange.allCases) { range in
                            RatingRangeCard(
                                range: range,
                                isSelected: store.ratingFilter == range
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    store.ratingFilter = range
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    dismiss()
                                }
                            }
                        }
                    }
                    .padding(DS.Spacing.lg)
                }
            }
            .navigationTitle("Filter by Rating")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(DS.Colors.gold)
                }
            }
        }
    }
}

// MARK: - Rating Range Card
struct RatingRangeCard: View {
    let range: RatingRange
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: DS.Radius.sm)
                        .fill(isSelected ? DS.Colors.gold.opacity(0.15) : DS.Colors.surface)
                        .frame(width: 44, height: 44)
                    Image(systemName: range.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isSelected ? DS.Colors.gold : DS.Colors.textSecondary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(range.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DS.Colors.textPrimary)
                    Text(range == .all ? "Show all puzzles" : "Rating \(range.rawValue)")
                        .font(.system(size: 13))
                        .foregroundColor(DS.Colors.textTertiary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(DS.Colors.gold)
                }
            }
            .padding(DS.Spacing.md)
            .background(DS.Colors.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.lg)
                    .strokeBorder(isSelected ? DS.Colors.gold.opacity(0.4) : DS.Colors.border, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

