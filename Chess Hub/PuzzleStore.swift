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
    private(set) var recentlySolvedIDs: [String] = []
    
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
    
    var recentlySolved: [Puzzle] {
        let puzzleDict = Dictionary(uniqueKeysWithValues: puzzles.map { ($0.id, $0) })
        return recentlySolvedIDs.prefix(20).compactMap { puzzleDict[$0] }
    }
    
    func nextPuzzle(after currentPuzzle: Puzzle, in theme: PuzzleTheme?) -> Puzzle? {
        guard let theme = theme else { return nil }
        
        let puzzlesInTheme = puzzles(forTheme: theme)
        guard let currentIndex = puzzlesInTheme.firstIndex(where: { $0.id == currentPuzzle.id }) else {
            return puzzlesInTheme.first
        }
        
        // Find next unsolved puzzle in the list
        let remainingPuzzles = puzzlesInTheme.suffix(from: currentIndex + 1)
        if let nextUnsolved = remainingPuzzles.first(where: { !solvedIDs.contains($0.id) }) {
            return nextUnsolved
        }
        
        // If no unsolved puzzles after current, wrap to beginning
        return puzzlesInTheme.first(where: { !solvedIDs.contains($0.id) })
    }

    func isSolved(_ id: String) -> Bool { solvedIDs.contains(id) }
    func isFavorite(_ id: String) -> Bool { favoriteIDs.contains(id) }

    // MARK: - Mutations

    func markSolved(_ id: String) {
        solvedIDs.insert(id)
        
        // Remove if already in list (to avoid duplicates)
        recentlySolvedIDs.removeAll { $0 == id }
        // Add to beginning of list
        recentlySolvedIDs.insert(id, at: 0)
        // Keep only last 100 (we show 20, but store more for safety)
        if recentlySolvedIDs.count > 100 {
            recentlySolvedIDs = Array(recentlySolvedIDs.prefix(100))
        }
        
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
    private let recentlySolvedKey = "recentlySolvedPuzzleIDs"

    private func saveProgress() {
        UserDefaults.standard.set(Array(solvedIDs), forKey: solvedKey)
        UserDefaults.standard.set(recentlySolvedIDs, forKey: recentlySolvedKey)
    }

    private func loadProgress() {
        solvedIDs   = Set(UserDefaults.standard.stringArray(forKey: solvedKey) ?? [])
        favoriteIDs = Set(UserDefaults.standard.stringArray(forKey: favoritesKey) ?? [])
        recentlySolvedIDs = UserDefaults.standard.stringArray(forKey: recentlySolvedKey) ?? []
    }

    private func saveFavorites() {
        UserDefaults.standard.set(Array(favoriteIDs), forKey: favoritesKey)
    }
}
