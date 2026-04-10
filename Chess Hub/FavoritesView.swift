import SwiftUI

struct FavoritesView: View {
    @Environment(PuzzleStore.self) private var store

    var favorites: [Puzzle] { store.allFavorites }

    var body: some View {
        NavigationStack {
            ZStack {
                DS.Colors.background.ignoresSafeArea()
                if favorites.isEmpty {
                    FavoritesEmptyView()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: DS.Spacing.md) {
                            HStack {
                                Text("\(favorites.count) saved puzzle\(favorites.count == 1 ? "" : "s")")
                                    .font(.system(size: 13, weight: .medium)).foregroundColor(DS.Colors.textTertiary)
                                Spacer()
                            }
                            .padding(.horizontal, DS.Spacing.lg).padding(.top, DS.Spacing.md)

                            LazyVStack(spacing: DS.Spacing.md) {
                                ForEach(Array(favorites.enumerated()), id: \.element.id) { index, puzzle in
                                    NavigationLink(destination: PuzzleSolverView(puzzle: puzzle)) {
                                        PuzzleRowCard(puzzle: puzzle, index: index)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, DS.Spacing.lg).padding(.bottom, DS.Spacing.xxxl)
                        }
                    }
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

struct FavoritesEmptyView: View {
    @State private var appeared = false
    var body: some View {
        VStack(spacing: DS.Spacing.xl) {
            Spacer()
            ZStack {
                Circle().fill(DS.Colors.danger.opacity(0.08)).frame(width: 120, height: 120)
                    .overlay(Circle().strokeBorder(DS.Colors.danger.opacity(0.2), lineWidth: 1))
                Image(systemName: "heart").font(.system(size: 48)).foregroundColor(DS.Colors.danger.opacity(0.5))
            }
            .scaleEffect(appeared ? 1 : 0.8).opacity(appeared ? 1 : 0)
            VStack(spacing: DS.Spacing.sm) {
                Text("No Favorites Yet").font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundColor(DS.Colors.textPrimary)
                Text("Tap the heart icon on any puzzle\nto save it here for quick access.")
                    .font(.system(size: 15)).foregroundColor(DS.Colors.textSecondary)
                    .multilineTextAlignment(.center).lineSpacing(4)
            }
            .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 10)
            Spacer()
        }
        .onAppear { withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) { appeared = true } }
    }
}
