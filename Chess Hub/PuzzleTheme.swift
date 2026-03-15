import SwiftUI

// MARK: - PuzzleTheme
// Maps the app's UI categories to Lichess theme tag strings.
// Add / remove cases freely — just keep lichessKey in sync.

enum PuzzleTheme: String, CaseIterable, Identifiable {

    // Checkmate themes
    case mateIn1        = "Mate in 1"
    case mateIn2        = "Mate in 2"
    case mateIn3        = "Mate in 3"
    case mateIn4        = "Mate in 4"

    // Tactical motifs
    case fork           = "Fork"
    case pin            = "Pin"
    case skewer         = "Skewer"
    case discoveredAttack = "Discovered Attack"
    case sacrifice      = "Sacrifice"
    case backRankMate   = "Back Rank Mate"
    case hangingPiece   = "Hanging Piece"
    case deflection     = "Deflection"
    case decoy          = "Decoy"
    case endgame        = "Endgame"

    // Special
    case favorites      = "Favorites"

    var id: String { rawValue }

    /// The exact string used in Lichess theme tags
    var lichessKey: String {
        switch self {
        case .mateIn1:          return "mateIn1"
        case .mateIn2:          return "mateIn2"
        case .mateIn3:          return "mateIn3"
        case .mateIn4:          return "mateIn4"
        case .fork:             return "fork"
        case .pin:              return "pin"
        case .skewer:           return "skewer"
        case .discoveredAttack: return "discoveredAttack"
        case .sacrifice:        return "sacrifice"
        case .backRankMate:     return "backRankMate"
        case .hangingPiece:     return "hangingPiece"
        case .deflection:       return "deflection"
        case .decoy:            return "decoy"
        case .endgame:          return "endgame"
        case .favorites:        return ""
        }
    }

    var icon: String {
        switch self {
        case .mateIn1:          return "bolt.fill"
        case .mateIn2:          return "2.circle.fill"
        case .mateIn3:          return "3.circle.fill"
        case .mateIn4:          return "4.circle.fill"
        case .fork:             return "arrow.triangle.branch"
        case .pin:              return "pin.fill"
        case .skewer:           return "arrow.right.to.line"
        case .discoveredAttack: return "eye.fill"
        case .sacrifice:        return "flame.fill"
        case .backRankMate:     return "arrow.down.to.line"
        case .hangingPiece:     return "exclamationmark.triangle.fill"
        case .deflection:       return "arrow.uturn.right"
        case .decoy:            return "target"
        case .endgame:          return "flag.fill"
        case .favorites:        return "heart.fill"
        }
    }

    var gradient: [Color] {
        switch self {
        case .mateIn1:          return [Color(hex: "#E8C96A"), Color(hex: "#8A6830")]
        case .mateIn2:          return [Color(hex: "#D4A853"), Color(hex: "#8A6020")]
        case .mateIn3:          return [Color(hex: "#A0B8D0"), Color(hex: "#5A7A9A")]
        case .mateIn4:          return [Color(hex: "#9A8FC0"), Color(hex: "#5A4A8A")]
        case .fork:             return [Color(hex: "#7EC88A"), Color(hex: "#3A7A48")]
        case .pin:              return [Color(hex: "#E09060"), Color(hex: "#904020")]
        case .skewer:           return [Color(hex: "#60B0D0"), Color(hex: "#2A6888")]
        case .discoveredAttack: return [Color(hex: "#D080C0"), Color(hex: "#804080")]
        case .sacrifice:        return [Color(hex: "#E06060"), Color(hex: "#902020")]
        case .backRankMate:     return [Color(hex: "#C0D070"), Color(hex: "#708030")]
        case .hangingPiece:     return [Color(hex: "#E0A040"), Color(hex: "#906000")]
        case .deflection:       return [Color(hex: "#80C0B0"), Color(hex: "#307868")]
        case .decoy:            return [Color(hex: "#B090D0"), Color(hex: "#604890")]
        case .endgame:          return [Color(hex: "#90A8C0"), Color(hex: "#486078")]
        case .favorites:        return [Color(hex: "#E07080"), Color(hex: "#A03050")]
        }
    }

    var difficulty: String {
        switch self {
        case .mateIn1:          return "Beginner"
        case .mateIn2:          return "Intermediate"
        case .mateIn3:          return "Advanced"
        case .mateIn4:          return "Expert"
        case .backRankMate:     return "Beginner"
        case .hangingPiece:     return "Beginner"
        case .fork:             return "Intermediate"
        case .pin:              return "Intermediate"
        case .deflection:       return "Intermediate"
        case .decoy:            return "Intermediate"
        case .sacrifice:        return "Advanced"
        case .skewer:           return "Advanced"
        case .discoveredAttack: return "Advanced"
        case .endgame:          return "Variable"
        case .favorites:        return "Your picks"
        }
    }

    var description: String {
        switch self {
        case .mateIn1:          return "Find the single move that delivers checkmate."
        case .mateIn2:          return "Two-move combinations leading to checkmate."
        case .mateIn3:          return "Calculate three moves ahead to force mate."
        case .mateIn4:          return "Deep four-move sequences ending in checkmate."
        case .fork:             return "Attack two pieces simultaneously with one move."
        case .pin:              return "Restrict a piece that shields a more valuable one."
        case .skewer:           return "Attack a valuable piece forcing it to expose another."
        case .discoveredAttack: return "Unmask a hidden attack by moving a blocking piece."
        case .sacrifice:        return "Give up material to gain a decisive advantage."
        case .backRankMate:     return "Exploit a king trapped on the back rank."
        case .hangingPiece:     return "Capture an undefended piece."
        case .deflection:       return "Lure a defending piece away from its duty."
        case .decoy:            return "Drag a piece to a square where it can be exploited."
        case .endgame:          return "Convert a technical advantage in the endgame."
        case .favorites:        return "Puzzles you've marked as favorites."
        }
    }

    /// Categories shown in the Home grid (curated subset)
    static var featured: [PuzzleTheme] {
        [.mateIn1, .mateIn2, .mateIn3, .mateIn4, .fork, .pin, .sacrifice, .backRankMate]
    }

    /// All browsable categories (excludes .favorites which has its own tab)
    static var browsable: [PuzzleTheme] {
        allCases.filter { $0 != .favorites }
    }
}
