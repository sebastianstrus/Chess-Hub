import SwiftUI
import Combine

// MARK: - Data Provider

class PuzzleDataProvider: ObservableObject {

    static let shared = PuzzleDataProvider()

    @Published private(set) var allPuzzles: [ChessPuzzle] = []
    @Published private(set) var favoriteIDs: Set<UUID> = [] {
        didSet { saveFavorites() }
    }

    private let favoritesKey = "favoritesPuzzleIDs"

    init() {
        loadSamplePuzzles()
        loadFavorites()
    }

    // MARK: - Public API

    func puzzles(for category: PuzzleCategory) -> [ChessPuzzle] {
        if category == .favorites {
            return allPuzzles.filter { favoriteIDs.contains($0.id) }
        }
        return allPuzzles.filter { $0.category == category }
    }

    func isFavorite(_ puzzle: ChessPuzzle) -> Bool {
        favoriteIDs.contains(puzzle.id)
    }

    func toggleFavorite(_ puzzle: ChessPuzzle) {
        if favoriteIDs.contains(puzzle.id) {
            favoriteIDs.remove(puzzle.id)
        } else {
            favoriteIDs.insert(puzzle.id)
        }
    }

    func puzzleCount(for category: PuzzleCategory) -> Int {
        puzzles(for: category).count
    }

    // MARK: - Persistence

    private func saveFavorites() {
        let ids = favoriteIDs.map { $0.uuidString }
        UserDefaults.standard.set(ids, forKey: favoritesKey)
    }

    private func loadFavorites() {
        guard let ids = UserDefaults.standard.stringArray(forKey: favoritesKey) else { return }
        favoriteIDs = Set(ids.compactMap { UUID(uuidString: $0) })
    }

    // MARK: - Sample Data
    // Replace imageName strings with your actual asset names.
    // The solution field accepts standard algebraic or descriptive notation.

    private func loadSamplePuzzles() {
        allPuzzles = [
            // Mate in 1
            ChessPuzzle(id: UUID(), imageName: "puzzle_m1_001", solution: "1. Qh7#", category: .mateIn1, title: "Scholar's Finish", difficulty: .easy),
            ChessPuzzle(id: UUID(), imageName: "puzzle_m1_002", solution: "1. Rg8#", category: .mateIn1, title: "Back Rank Blow", difficulty: .easy),
            ChessPuzzle(id: UUID(), imageName: "puzzle_m1_003", solution: "1. Nf7#", category: .mateIn1, title: "Knight's Kiss", difficulty: .easy),
            ChessPuzzle(id: UUID(), imageName: "puzzle_m1_004", solution: "1. Bxh7#", category: .mateIn1, title: "Bishop's Diagonal", difficulty: .easy),
            ChessPuzzle(id: UUID(), imageName: "puzzle_m1_005", solution: "1. Qxg7#", category: .mateIn1, title: "Queen's Strike", difficulty: .medium),

            // Mate in 2
            ChessPuzzle(id: UUID(), imageName: "puzzle_m2_001", solution: "1. Qh5+ Kd8 2. Qf7#", category: .mateIn2, title: "Double Check", difficulty: .easy),
            ChessPuzzle(id: UUID(), imageName: "puzzle_m2_002", solution: "1. Nf6+ gxf6 2. Qg3#", category: .mateIn2, title: "Sacrifice & Mate", difficulty: .medium),
            ChessPuzzle(id: UUID(), imageName: "puzzle_m2_003", solution: "1. Rxh7+ Kxh7 2. Qh5#", category: .mateIn2, title: "Rook Deflection", difficulty: .medium),
            ChessPuzzle(id: UUID(), imageName: "puzzle_m2_004", solution: "1. Bg5+ f6 2. Bxf6#", category: .mateIn2, title: "Pin & Punish", difficulty: .medium),
            ChessPuzzle(id: UUID(), imageName: "puzzle_m2_005", solution: "1. Qd8+ Rxd8 2. Rxd8#", category: .mateIn2, title: "Opera Style", difficulty: .hard),

            // Mate in 3
            ChessPuzzle(id: UUID(), imageName: "puzzle_m3_001", solution: "1. Qxh7+ Kxh7 2. Rh3+ Kg8 3. Rh8#", category: .mateIn3, title: "Corridor Mate", difficulty: .medium),
            ChessPuzzle(id: UUID(), imageName: "puzzle_m3_002", solution: "1. Nxe6+ fxe6 2. Qh5+ g6 3. Qxg6#", category: .mateIn3, title: "Knight Sacrifice", difficulty: .hard),
            ChessPuzzle(id: UUID(), imageName: "puzzle_m3_003", solution: "1. Rxg7+ Kxg7 2. Rg1+ Kh8 3. Qg8#", category: .mateIn3, title: "Rook & Queen", difficulty: .hard),
            ChessPuzzle(id: UUID(), imageName: "puzzle_m3_004", solution: "1. Qxf7+ Rxf7 2. Re8+ Rf8 3. Rxf8#", category: .mateIn3, title: "Queen Sacrifice", difficulty: .hard),
            ChessPuzzle(id: UUID(), imageName: "puzzle_m3_005", solution: "1. Bg6+ hxg6 2. Qh3+ Kg8 3. Qh8#", category: .mateIn3, title: "Bishop's Gift", difficulty: .grandmaster),

            // Mate in 4
            ChessPuzzle(id: UUID(), imageName: "puzzle_m4_001", solution: "1. Nf5 gxf5 2. Qg3+ Kh8 3. Bxf6+ Rxf6 4. Qg8#", category: .mateIn4, title: "Evergreen Echo", difficulty: .hard),
            ChessPuzzle(id: UUID(), imageName: "puzzle_m4_002", solution: "1. Rxh6 gxh6 2. Qg8+ Kxg8 3. Rg1+ Kh8 4. Rg8#", category: .mateIn4, title: "Four-Move Fury", difficulty: .hard),
            ChessPuzzle(id: UUID(), imageName: "puzzle_m4_003", solution: "1. Qxh7+ Kxh7 2. Rh5+ Kg8 3. Ng6 fxg6 4. Rh8#", category: .mateIn4, title: "Pilgrimage", difficulty: .grandmaster),
            ChessPuzzle(id: UUID(), imageName: "puzzle_m4_004", solution: "1. Rxe6 fxe6 2. Qh5+ Ke7 3. Qxe5+ Kf7 4. Qf6#", category: .mateIn4, title: "The Deep Hunt", difficulty: .grandmaster),
            ChessPuzzle(id: UUID(), imageName: "puzzle_m4_005", solution: "1. Bg5 Qxg5 2. Nh6+ Kh8 3. Qxf7 Rxf7 4. Nxf7#", category: .mateIn4, title: "Immortal Pattern", difficulty: .grandmaster),

            // Selfmate
            ChessPuzzle(id: UUID(), imageName: "puzzle_sm_001", solution: "1. Qg6+ hxg6 2. hxg6+ Kh8 3. g7+ Kg8 4. g8=Q#", category: .selfmate, title: "Forced Humiliation", difficulty: .hard),
            ChessPuzzle(id: UUID(), imageName: "puzzle_sm_002", solution: "1. Rh8+ Kxh8 2. Qh1+ Kg8 3. Qh7#", category: .selfmate, title: "Reverse Psychology", difficulty: .hard),
            ChessPuzzle(id: UUID(), imageName: "puzzle_sm_003", solution: "1. Nd5 cxd5 2. Bb5+ axb5 3. Qxa8#", category: .selfmate, title: "Paradox King", difficulty: .grandmaster),
        ]
    }
}
