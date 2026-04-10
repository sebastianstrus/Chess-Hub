import Foundation
import Observation

// MARK: - Rating Range

enum RatingRange: String, CaseIterable, Identifiable {
    case all = "All Levels"
    case easy = "1200-1400"
    case intermediate = "1400-1600"
    case advanced = "1600+"
    
    var id: String { rawValue }
    
    var range: ClosedRange<Int> {
        switch self {
        case .all: return 0...9999
        case .easy: return 1200...1400
        case .intermediate: return 1400...1600
        case .advanced: return 1600...9999
        }
    }
    
    func contains(_ rating: Int) -> Bool {
        range.contains(rating)
    }
    
    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .easy: return "star.fill"
        case .intermediate: return "flame"
        case .advanced: return "crown.fill"
        }
    }
}

// MARK: - PuzzleStore

@Observable
class PuzzleStore {

    // MARK: State
    private(set) var puzzles: [Puzzle] = []
    private(set) var isLoading = true

    private(set) var solvedIDs: Set<String> = []
    private(set) var favoriteIDs: Set<String> = []
    
    // Rating filter
    var ratingFilter: RatingRange = .all

    // MARK: Init
    init() {
        load()
        loadProgress()
    }

    // MARK: - Queries

    func puzzles(forTheme theme: PuzzleTheme) -> [Puzzle] {
        var filtered: [Puzzle]
        
        if theme == .favorites {
            filtered = puzzles.filter { favoriteIDs.contains($0.id) }
        } else {
            filtered = puzzles.filter { $0.themes.contains(theme.lichessKey) }
        }
        
        // Apply rating filter
        if ratingFilter != .all {
            filtered = filtered.filter { ratingFilter.contains($0.rating) }
        }
        
        return filtered
    }

    func count(forTheme theme: PuzzleTheme) -> Int {
        puzzles(forTheme: theme).count
    }
    
    func totalCount(forTheme theme: PuzzleTheme) -> Int {
        if theme == .favorites {
            return puzzles.filter { favoriteIDs.contains($0.id) }.count
        } else {
            return puzzles.filter { $0.themes.contains(theme.lichessKey) }.count
        }
    }
    
    var allFavorites: [Puzzle] {
        puzzles.filter { favoriteIDs.contains($0.id) }
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
