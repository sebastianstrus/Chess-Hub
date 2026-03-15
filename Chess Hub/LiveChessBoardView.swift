import SwiftUI
import ChessKit

// MARK: - LiveChessBoardView
//
// Library: chesskit-app/chesskit-swift
// SPM:     https://github.com/chesskit-app/chesskit-swift
//
// Square is an ENUM with cases .a1 … .h8 (not a struct with a string init).
// Piece.Color and Piece.Kind are NESTED types inside Piece.
// board.position.pieces(for:) returns [Piece] as a PROPERTY (not a function call).
// Square has no `.description` — use rank/file properties or allSquares index math.

// MARK: - Square helpers
// Square is an enum; we map to/from (file: 0-7, rank: 0-7) via its index.

extension Square {
    /// 0-based file index (a=0 … h=7)
    var fileIndex: Int { Square.allCases.firstIndex(of: self)! % 8 }
    /// 0-based rank index (1=0 … 8=7)
    var rankIndex: Int { Square.allCases.firstIndex(of: self)! / 8 }

    /// Build a Square from 0-based file and rank indices.
    static func from(fileIndex: Int, rankIndex: Int) -> Square {
        Square.allCases[rankIndex * 8 + fileIndex]
    }

    /// Algebraic notation string e.g. "e2"
    var algebraic: String {
        let files = ["a","b","c","d","e","f","g","h"]
        return "\(files[fileIndex])\(rankIndex + 1)"
    }

    /// Init from algebraic string e.g. "e2". Returns nil on bad input.
    static func from(_ notation: String) -> Square? {
        let files = ["a","b","c","d","e","f","g","h"]
        guard notation.count == 2,
              let fileIdx = files.firstIndex(of: String(notation.prefix(1))),
              let rank    = Int(String(notation.suffix(1))),
              (1...8).contains(rank) else { return nil }
        return from(fileIndex: fileIdx, rankIndex: rank - 1)
    }
}

// MARK: - ChessBoardState

@Observable
final class ChessBoardState {
    var board: Board
    var selectedSquare: Square? = nil
    var legalDestinations: [Square] = []
    var lastMoveFrom: Square? = nil
    var lastMoveTo:   Square? = nil
    var draggingFrom: Square? = nil
    var isDragging:   Bool = false
    var opponentMoved: Bool = false
    var wrongFlash:   Bool = false
    var solutionIndex: Int = 0

    init(fen: String) {
        if let position = Position(fen: fen) {
            self.board = Board(position: position)
        } else {
            self.board = Board()
        }
    }

    // MARK: Board queries

    func allPieces() -> [Piece] {
        board.position.pieces
    }

    func piece(at square: Square) -> Piece? {
        board.position.piece(at: square)
    }

    func legalSquares(from square: Square) -> [Square] {
        board.legalMoves(forPieceAt: square)
    }

    // MARK: Mutations

    func move(from: Square, to: Square) {
        board.move(pieceAt: from, to: to)
    }

    // MARK: UCI parsing

    /// Parse "e2e4" or "e7e8q" → (from, to). Ignores promotion char (board handles it).
    func parseUCI(_ uci: String) -> (from: Square, to: Square)? {
        guard uci.count >= 4 else { return nil }
        let chars   = Array(uci)
        let fromStr = String(chars[0...1])
        let toStr   = String(chars[2...3])
        guard let from = Square.from(fromStr),
              let to   = Square.from(toStr) else { return nil }
        return (from, to)
    }
}

// MARK: - LiveChessBoardView

struct LiveChessBoardView: View {

    let puzzle: Puzzle
    let onMoveResult: (Bool) -> Void

    @State private var state: ChessBoardState
    @State private var boardFlipped: Bool
    @State private var dragLocation: CGPoint = .zero

    init(puzzle: Puzzle, onMoveResult: @escaping (Bool) -> Void) {
        self.puzzle       = puzzle
        self.onMoveResult = onMoveResult
        _state        = State(initialValue: ChessBoardState(fen: puzzle.fen))
        _boardFlipped = State(initialValue: !puzzle.playerIsWhite)
    }

    var body: some View {
        GeometryReader { geo in
            let size   = min(geo.size.width, geo.size.height)
            let sqSize = size / 8

            ZStack(alignment: .topLeading) {
                boardLayer(sqSize: sqSize)
                legalMoveLayer(sqSize: sqSize)
                pieceLayer(sqSize: sqSize)

                // Floating dragged piece
                if state.isDragging,
                   let from  = state.draggingFrom,
                   let piece = state.piece(at: from) {
                    pieceView(piece, sqSize: sqSize)
                        .scaleEffect(1.18)
                        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)
                        .position(dragLocation)
                        .allowsHitTesting(false)
                }

                // Wrong-move red flash
                if state.wrongFlash {
                    Color.red.opacity(0.18)
                        .frame(width: size, height: size)
                        .allowsHitTesting(false)
                }
            }
            .frame(width: size, height: size)
            .gesture(
                DragGesture(minimumDistance: 4, coordinateSpace: .local)
                    .onChanged { v in onDragChanged(v, sqSize: sqSize) }
                    .onEnded   { v in onDragEnded(v,   sqSize: sqSize) }
            )
            .contentShape(Rectangle())
            .onTapGesture(coordinateSpace: .local) { loc in
                onTap(loc, sqSize: sqSize)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .overlay(alignment: .topTrailing) { flipButton }
        .onAppear { setupPuzzle() }
    }

    // MARK: - Board layer

    @ViewBuilder
    private func boardLayer(sqSize: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            ForEach(0..<64, id: \.self) { idx in
                let row = idx / 8
                let col = idx % 8
                let sq  = displaySquare(row: row, col: col)
                Rectangle()
                    .fill(squareColor(row: row, col: col, sq: sq))
                    .frame(width: sqSize, height: sqSize)
                    .position(x: CGFloat(col) * sqSize + sqSize / 2,
                              y: CGFloat(row) * sqSize + sqSize / 2)
            }
            coordinateLabels(sqSize: sqSize)
        }
    }

    @ViewBuilder
    private func coordinateLabels(sqSize: CGFloat) -> some View {
        let fileLabels = boardFlipped
            ? ["h","g","f","e","d","c","b","a"]
            : ["a","b","c","d","e","f","g","h"]

        ZStack(alignment: .topLeading) {
            ForEach(0..<8, id: \.self) { row in
                let rank  = boardFlipped ? "\(row + 1)" : "\(8 - row)"
                Text(rank)
                    .font(.system(size: sqSize * 0.20, weight: .bold))
                    .foregroundColor(labelColor(row: row, col: 0))
                    .position(x: sqSize * 0.15,
                              y: CGFloat(row) * sqSize + sqSize * 0.18)
            }
            ForEach(0..<8, id: \.self) { col in
                Text(fileLabels[col])
                    .font(.system(size: sqSize * 0.20, weight: .bold))
                    .foregroundColor(labelColor(row: 7, col: col))
                    .position(x: CGFloat(col) * sqSize + sqSize * 0.85,
                              y: 7 * sqSize + sqSize * 0.82)
            }
        }
    }

    private func labelColor(row: Int, col: Int) -> Color {
        ((row + col).isMultiple(of: 2) ? DS.Colors.pieceDark : DS.Colors.pieceLight).opacity(0.6)
    }

    // MARK: - Legal move indicators

    @ViewBuilder
    private func legalMoveLayer(sqSize: CGFloat) -> some View {
        ForEach(0..<state.legalDestinations.count, id: \.self) { i in
            let dest       = state.legalDestinations[i]
            let (row, col) = displayRowCol(dest)
            let isCapture  = state.piece(at: dest) != nil
            Group {
                if isCapture {
                    Circle()
                        .strokeBorder(DS.Colors.gold.opacity(0.75), lineWidth: sqSize * 0.10)
                        .frame(width: sqSize * 0.92, height: sqSize * 0.92)
                } else {
                    Circle()
                        .fill(DS.Colors.gold.opacity(0.45))
                        .frame(width: sqSize * 0.30, height: sqSize * 0.30)
                }
            }
            .position(x: CGFloat(col) * sqSize + sqSize / 2,
                      y: CGFloat(row) * sqSize + sqSize / 2)
            .allowsHitTesting(false)
        }
    }

    // MARK: - Piece layer

    @ViewBuilder
    private func pieceLayer(sqSize: CGFloat) -> some View {
        let pieces = state.allPieces()
        ForEach(0..<pieces.count, id: \.self) { i in
            let piece      = pieces[i]
            let (row, col) = displayRowCol(piece.square)
            let isGhost    = state.isDragging && state.draggingFrom == piece.square
            pieceView(piece, sqSize: sqSize)
                .opacity(isGhost ? 0.20 : 1.0)
                .position(x: CGFloat(col) * sqSize + sqSize / 2,
                          y: CGFloat(row) * sqSize + sqSize / 2)
                .animation(.spring(response: 0.25, dampingFraction: 0.8), value: piece.square)
        }
    }

    /// Renders a piece using the cburnett SVG piece set from lichess.
    /// Files must be added to the Xcode project with names: wK, wQ, wR, wB, wN, wP,
    ///                                                       bK, bQ, bR, bB, bN, bP
    /// Download from: https://github.com/lichess-org/lila/tree/master/public/piece/cburnett
    @ViewBuilder
    private func pieceView(_ piece: Piece, sqSize: CGFloat) -> some View {
        let name = pieceImageName(piece)
        Image(name)
            .resizable()
            .scaledToFit()
            .frame(width: sqSize * 0.88, height: sqSize * 0.88)
            .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
    }

    // MARK: - Flip button

    private var flipButton: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { boardFlipped.toggle() }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(DS.Colors.textSecondary)
                .padding(8)
                .background(DS.Colors.surfaceElevated.opacity(0.9))
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(DS.Colors.border, lineWidth: 1))
        }
        .padding(6)
    }

    // MARK: - Gesture handlers

    private func onDragChanged(_ v: DragGesture.Value, sqSize: CGFloat) {
        if !state.isDragging {
            let sq = displaySquare(point: v.startLocation, sqSize: sqSize)
            guard let piece = state.piece(at: sq), isPlayerPiece(piece) else { return }
            state.isDragging        = true
            state.draggingFrom      = sq
            state.selectedSquare    = sq
            state.legalDestinations = state.legalSquares(from: sq)
        }
        dragLocation = v.location
    }

    private func onDragEnded(_ v: DragGesture.Value, sqSize: CGFloat) {
        defer { state.isDragging = false; state.draggingFrom = nil; dragLocation = .zero }
        guard let from = state.draggingFrom else { return }
        let to = displaySquare(point: v.location, sqSize: sqSize)
        tryMove(from: from, to: to)
    }

    private func onTap(_ loc: CGPoint, sqSize: CGFloat) {
        let tapped = displaySquare(point: loc, sqSize: sqSize)
        if let sel = state.selectedSquare {
            if state.legalDestinations.contains(tapped) {
                tryMove(from: sel, to: tapped)
            } else if let piece = state.piece(at: tapped), isPlayerPiece(piece) {
                state.selectedSquare    = tapped
                state.legalDestinations = state.legalSquares(from: tapped)
            } else {
                state.selectedSquare    = nil
                state.legalDestinations = []
            }
        } else if let piece = state.piece(at: tapped), isPlayerPiece(piece) {
            state.selectedSquare    = tapped
            state.legalDestinations = state.legalSquares(from: tapped)
        }
    }

    // MARK: - Move logic

    private func tryMove(from: Square, to: Square) {
        state.selectedSquare    = nil
        state.legalDestinations = []

        guard state.solutionIndex < puzzle.playerMoves.count else { return }
        let expected = puzzle.playerMoves[state.solutionIndex]
        guard let (expFrom, expTo) = state.parseUCI(expected) else { return }

        if from == expFrom && to == expTo {
            state.move(from: from, to: to)
            state.lastMoveFrom   = from
            state.lastMoveTo     = to
            state.solutionIndex += 1
            onMoveResult(true)

            if state.solutionIndex < puzzle.playerMoves.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                    playOpponentResponse()
                }
            }
        } else {
            withAnimation(.easeIn(duration: 0.08))             { state.wrongFlash = true  }
            withAnimation(.easeOut(duration: 0.4).delay(0.08)) { state.wrongFlash = false }
            onMoveResult(false)
        }
    }

    private func playOpponentResponse() {
        guard state.solutionIndex < puzzle.playerMoves.count else { return }
        let uci = puzzle.playerMoves[state.solutionIndex]
        guard let (from, to) = state.parseUCI(uci) else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            state.move(from: from, to: to)
            state.lastMoveFrom = from
            state.lastMoveTo   = to
        }
        state.solutionIndex += 1
    }

    // MARK: - Setup

    private func setupPuzzle() {
        boardFlipped          = !puzzle.playerIsWhite
        state.solutionIndex   = 0
        state.opponentMoved   = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            let uci = puzzle.opponentFirstMove
            guard let (from, to) = state.parseUCI(uci) else { return }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                state.move(from: from, to: to)
                state.lastMoveFrom  = from
                state.lastMoveTo    = to
                state.opponentMoved = true
            }
        }
    }

    // MARK: - Helpers

    private func isPlayerPiece(_ piece: Piece) -> Bool {
        guard state.opponentMoved else { return false }
        let playerColor: Piece.Color = puzzle.playerIsWhite ? .white : .black
        return piece.color == playerColor
    }

    // MARK: - Coordinate conversion

    /// Display (row, col) → Square, accounting for board flip.
    /// Row 0 = top of screen. Col 0 = left of screen.
    private func displaySquare(row: Int, col: Int) -> Square {
        let fileIdx = boardFlipped ? (7 - col) : col
        let rankIdx = boardFlipped ? row        : (7 - row)
        return Square.from(fileIndex: fileIdx, rankIndex: rankIdx)
    }

    /// CGPoint → Square.
    private func displaySquare(point: CGPoint, sqSize: CGFloat) -> Square {
        let col = max(0, min(7, Int(point.x / sqSize)))
        let row = max(0, min(7, Int(point.y / sqSize)))
        return displaySquare(row: row, col: col)
    }

    /// Square → display (row, col), accounting for board flip.
    private func displayRowCol(_ square: Square) -> (row: Int, col: Int) {
        let fileIdx = square.fileIndex
        let rankIdx = square.rankIndex
        let col = boardFlipped ? (7 - fileIdx) : fileIdx
        let row = boardFlipped ? rankIdx        : (7 - rankIdx)
        return (row, col)
    }

    private func squareColor(row: Int, col: Int, sq: Square) -> Color {
        let isLight = (row + col).isMultiple(of: 2)
        let base    = isLight ? DS.Colors.pieceLight : DS.Colors.pieceDark
        if sq == state.selectedSquare                          { return DS.Colors.gold.opacity(0.55) }
        if sq == state.lastMoveFrom || sq == state.lastMoveTo  { return DS.Colors.gold.opacity(0.28) }
        return base
    }

    // MARK: - Piece image names (cburnett SVG set)
    // Naming: color prefix (w/b) + piece letter (K/Q/R/B/N/P)

    private func pieceImageName(_ piece: Piece) -> String {
        let color = piece.color == .white ? "w" : "b"
        let kind: String
        switch piece.kind {
        case .king:   kind = "K"
        case .queen:  kind = "Q"
        case .rook:   kind = "R"
        case .bishop: kind = "B"
        case .knight: kind = "N"
        case .pawn:   kind = "P"
        default:      kind = "P"
        }
        return "\(color)\(kind)"
    }
}
