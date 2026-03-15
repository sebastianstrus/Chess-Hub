import SwiftUI

// MARK: - Puzzle Category

enum PuzzleCategory: String, CaseIterable, Identifiable, Codable {
    case mateIn1 = "Mate in 1"
    case mateIn2 = "Mate in 2"
    case mateIn3 = "Mate in 3"
    case mateIn4 = "Mate in 4"
    case selfmate = "Selfmate"
    case favorites = "Favorites"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .mateIn1: return "bolt.fill"
        case .mateIn2: return "2.circle.fill"
        case .mateIn3: return "3.circle.fill"
        case .mateIn4: return "4.circle.fill"
        case .selfmate: return "arrow.uturn.backward.circle.fill"
        case .favorites: return "heart.fill"
        }
    }

    var gradient: [Color] {
        switch self {
        case .mateIn1: return [Color(hex: "#E8C96A"), Color(hex: "#8A6830")]
        case .mateIn2: return [Color(hex: "#C0A96A"), Color(hex: "#8A6E30")]
        case .mateIn3: return [Color(hex: "#A0B8D0"), Color(hex: "#5A7A9A")]
        case .mateIn4: return [Color(hex: "#9A8FC0"), Color(hex: "#5A4A8A")]
        case .selfmate: return [Color(hex: "#C08080"), Color(hex: "#8A4040")]
        case .favorites: return [Color(hex: "#E07080"), Color(hex: "#A03050")]
        }
    }

    var difficulty: String {
        switch self {
        case .mateIn1: return "Beginner"
        case .mateIn2: return "Intermediate"
        case .mateIn3: return "Advanced"
        case .mateIn4: return "Expert"
        case .selfmate: return "Special"
        case .favorites: return "Your picks"
        }
    }

    var description: String {
        switch self {
        case .mateIn1: return "Find the move that delivers checkmate immediately."
        case .mateIn2: return "Two-move combinations leading to checkmate."
        case .mateIn3: return "Calculate three moves ahead to force mate."
        case .mateIn4: return "Deep tactical sequences ending in checkmate."
        case .selfmate: return "Force your opponent to give checkmate."
        case .favorites: return "Puzzles you've marked as favorites."
        }
    }
}

// MARK: - Puzzle Model

struct ChessPuzzle: Identifiable, Codable, Equatable {
    let id: UUID
    let imageName: String
    let solution: String
    let category: PuzzleCategory
    let title: String
    let difficulty: DifficultyLevel

    enum DifficultyLevel: String, Codable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
        case grandmaster = "GM Level"
    }

    static func == (lhs: ChessPuzzle, rhs: ChessPuzzle) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.replacingOccurrences(of: "#", with: ""))
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
