import SwiftUI

struct MainTabView: View {
    @Environment(PuzzleStore.self) private var store

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }

            PuzzleLibraryView()
                .tabItem { Label("Puzzles", systemImage: "square.grid.2x2.fill") }

            FavoritesView()
                .tabItem { Label("Favorites", systemImage: "heart.fill") }
        }
        .tint(DS.Colors.gold)
        .preferredColorScheme(.dark)
        .onAppear { configureTabBar() }
    }

    private func configureTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(DS.Colors.surface)
        let normal   = UIColor(DS.Colors.textTertiary)
        let selected = UIColor(DS.Colors.gold)
        appearance.stackedLayoutAppearance.normal.iconColor   = normal
        appearance.stackedLayoutAppearance.normal.titleTextAttributes   = [.foregroundColor: normal]
        appearance.stackedLayoutAppearance.selected.iconColor = selected
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selected]
        UITabBar.appearance().standardAppearance    = appearance
        UITabBar.appearance().scrollEdgeAppearance  = appearance
    }
}
