import Foundation

// MARK: - Puzzle (Lichess format)

struct Puzzle: Codable, Identifiable, Equatable {
    let id: String
    let fen: String
    let moves: [String]   // UCI: ["d5e3", "f2e3", ...]
    let rating: Int
    let popularity: Int
    let themes: [String]
    let gameUrl: String

    // moves[0] = opponent's move played automatically to set up the position
    // moves[1...] = alternating player / opponent moves; player plays odd indices (1,3,5…)
    var opponentFirstMove: String { moves[0] }
    var playerMoves: [String] { Array(moves.dropFirst()) }

    // Convenience: is it White or Black to move after opponentFirstMove?
    // The FEN side-to-move tells whose turn it is BEFORE the opponent's setup move.
    var playerIsWhite: Bool {
        // FEN field 2 is the active color
        let parts = fen.split(separator: " ")
        guard parts.count > 1 else { return true }
        // After opponent plays their move the side flips
        return parts[1] == "b"   // if FEN says black to move, opponent is black → player is white
    }

    static func == (lhs: Puzzle, rhs: Puzzle) -> Bool { lhs.id == rhs.id }
}
