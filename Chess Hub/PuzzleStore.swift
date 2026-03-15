import Foundation
import Observation

// MARK: - PuzzleStore

@Observable
class PuzzleStore {

    // MARK: State
    private(set) var puzzles: [Puzzle] = []
    private(set) var isLoading = true

    private(set) var solvedIDs: Set<String> = []
    private(set) var favoriteIDs: Set<String> = []

    // MARK: Init
    init() {
        load()
        loadProgress()
    }

    // MARK: - Queries

    func puzzles(forTheme theme: PuzzleTheme) -> [Puzzle] {
        if theme == .favorites {
            return puzzles.filter { favoriteIDs.contains($0.id) }
        }
        return puzzles.filter { $0.themes.contains(theme.lichessKey) }
    }

    func count(forTheme theme: PuzzleTheme) -> Int {
        puzzles(forTheme: theme).count
    }

    func isSolved(_ id: String) -> Bool { solvedIDs.contains(id) }
    func isFavorite(_ id: String) -> Bool { favoriteIDs.contains(id) }

    // MARK: - Mutations

    func markSolved(_ id: String) {
        solvedIDs.insert(id)
        saveProgress()
    }

    func toggleFavorite(_ id: String) {
        if favoriteIDs.contains(id) {
            favoriteIDs.remove(id)
        } else {
            favoriteIDs.insert(id)
        }
        saveFavorites()
    }

    // MARK: - Stats

    var totalSolved: Int { solvedIDs.count }
    var totalFavorites: Int { favoriteIDs.count }

    // MARK: - Load JSON

    private func load() {
        guard let url = Bundle.main.url(forResource: "puzzles", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            isLoading = false
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            let decoded = (try? JSONDecoder().decode([Puzzle].self, from: data)) ?? []
            DispatchQueue.main.async {
                self.puzzles = decoded
                self.isLoading = false
            }
        }
    }

    // MARK: - Persistence

    private let solvedKey   = "solvedPuzzleIDs"
    private let favoritesKey = "favoritePuzzleIDs"

    private func saveProgress() {
        UserDefaults.standard.set(Array(solvedIDs), forKey: solvedKey)
    }

    private func loadProgress() {
        solvedIDs   = Set(UserDefaults.standard.stringArray(forKey: solvedKey) ?? [])
        favoriteIDs = Set(UserDefaults.standard.stringArray(forKey: favoritesKey) ?? [])
    }

    private func saveFavorites() {
        UserDefaults.standard.set(Array(favoriteIDs), forKey: favoritesKey)
    }
}
