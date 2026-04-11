import SwiftUI

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

// MARK: - Rating → Difficulty label

extension Int {
    var difficultyLabel: String {
        switch self {
        case ..<1200: return "Beginner"
        case 1200..<1500: return "Intermediate"
        case 1500..<1800: return "Advanced"
        case 1800..<2100: return "Expert"
        default: return "GM Level"
        }
    }

    var difficultyColor: Color {
        switch self {
        case ..<1200: return DS.Colors.success
        case 1200..<1500: return DS.Colors.gold
        case 1500..<1800: return Color(hex: "#E07040")
        default: return DS.Colors.danger
        }
    }
}

// MARK: - Static Chess Board

struct StaticChessBoard: View {
    let fen: String
    let flipped: Bool
    private let pieces: [ChessPiece?]
    
    init(fen: String, flipped: Bool = false) {
        self.fen = fen
        self.flipped = flipped
        self.pieces = Self.parseFEN(fen)
    }
    
    var body: some View {
        GeometryReader { geo in
            let sq = geo.size.width / 8
            ZStack(alignment: .topLeading) {
                // Checkered background
                ForEach(0..<64, id: \.self) { idx in
                    let row = idx / 8
                    let col = idx % 8
                    Rectangle()
                        .fill((row + col).isMultiple(of: 2) ? DS.Colors.pieceLight : DS.Colors.pieceDark)
                        .frame(width: sq, height: sq)
                        .position(x: CGFloat(col) * sq + sq/2, y: CGFloat(row) * sq + sq/2)
                }
                
                // Pieces from FEN
                ForEach(Array(pieces.enumerated()), id: \.offset) { index, piece in
                    if let piece = piece {
                        let row = flipped ? (7 - index / 8) : (index / 8)
                        let col = flipped ? (7 - index % 8) : (index % 8)
                        Image(piece.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: sq * 0.88, height: sq * 0.88)
                            .position(x: CGFloat(col) * sq + sq/2, y: CGFloat(row) * sq + sq/2)
                    }
                }
            }
            .drawingGroup()
        }
    }
    
    private static func parseFEN(_ fen: String) -> [ChessPiece?] {
        let fenParts = fen.split(separator: " ")
        guard !fenParts.isEmpty else { return Array(repeating: nil, count: 64) }
        
        let rows = fenParts[0].split(separator: "/")
        var board: [ChessPiece?] = []
        
        for row in rows {
            for char in row {
                if let digit = char.wholeNumberValue {
                    board.append(contentsOf: Array(repeating: nil, count: digit))
                } else {
                    board.append(ChessPiece(from: char))
                }
            }
        }
        
        return board
    }
}

struct ChessPiece {
    let isWhite: Bool
    let type: PieceType
    
    enum PieceType {
        case pawn, knight, bishop, rook, queen, king
    }
    
    init?(from char: Character) {
        let lower = char.lowercased().first!
        guard let type = Self.charToType(lower) else { return nil }
        self.type = type
        self.isWhite = char.isUppercase
    }
    
    private static func charToType(_ char: Character) -> PieceType? {
        switch char {
        case "p": return .pawn
        case "n": return .knight
        case "b": return .bishop
        case "r": return .rook
        case "q": return .queen
        case "k": return .king
        default: return nil
        }
    }
    
    var imageName: String {
        let color = isWhite ? "w" : "b"
        let kind: String
        switch type {
        case .king: kind = "K"
        case .queen: kind = "Q"
        case .rook: kind = "R"
        case .bishop: kind = "B"
        case .knight: kind = "N"
        case .pawn: kind = "P"
        }
        return "\(color)\(kind)"
    }
}
