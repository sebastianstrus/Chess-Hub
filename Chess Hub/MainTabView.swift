import SwiftUI

struct MainTabView: View {
    @StateObject private var dataProvider = PuzzleDataProvider.shared
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            PuzzleLibraryView()
                .tabItem {
                    Label("Puzzles", systemImage: "square.grid.2x2.fill")
                }
                .tag(1)

            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
                .tag(2)
        }
        .tint(DS.Colors.gold)
        .environmentObject(dataProvider)
        .preferredColorScheme(.dark)
        .onAppear { configureTabBar() }
    }

    private func configureTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(DS.Colors.surface)

        let normalColor = UIColor(DS.Colors.textTertiary)
        let selectedColor = UIColor(DS.Colors.gold)

        appearance.stackedLayoutAppearance.normal.iconColor = normalColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: normalColor]
        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
