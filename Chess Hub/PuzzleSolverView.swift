import SwiftUI
import ChessKit

// MARK: - Puzzle Solver View

struct PuzzleSolverView: View {
    @Environment(PuzzleStore.self) private var store
    let puzzle: Puzzle

    @State private var solveState: SolveState = .playing
    @State private var moveHistory: [MoveResult] = []
    @State private var boardID = UUID()   // force board reset on retry
    @State private var appeared = false

    enum SolveState {
        case playing
        case solved
        case failed
    }

    struct MoveResult: Identifiable {
        let id = UUID()
        let moveIndex: Int
        let correct: Bool
    }

    var isFav: Bool { store.isFavorite(puzzle.id) }

    var body: some View {
        ZStack {
            DS.Colors.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: DS.Spacing.lg) {

                    // Status banner
                    statusBanner
                        .padding(.horizontal, DS.Spacing.lg)
                        .padding(.top, DS.Spacing.md)

                    // Board
                    LiveChessBoardView(puzzle: puzzle) { correct in
                        handleMoveResult(correct: correct)
                    }
                    .id(boardID)
                    .padding(.horizontal, DS.Spacing.lg)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Radius.lg)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [DS.Colors.goldLight.opacity(0.4), DS.Colors.goldDark.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                            .padding(.horizontal, DS.Spacing.lg)
                    )
                    .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 8)

                    // Puzzle info & controls
                    puzzleInfoPanel
                        .padding(.horizontal, DS.Spacing.lg)

                    // Move progress
                    moveProgressView
                        .padding(.horizontal, DS.Spacing.lg)

                    // Themes
                    themesRow
                        .padding(.horizontal, DS.Spacing.lg)
                        .padding(.bottom, DS.Spacing.xxxl)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 1) {
                    Text("Puzzle #\(puzzle.id)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(DS.Colors.textSecondary)
                    Text("Rating \(puzzle.rating)")
                        .font(.system(size: 10))
                        .foregroundColor(DS.Colors.textTertiary)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.toggleFavorite(puzzle.id)
                } label: {
                    Image(systemName: isFav ? "heart.fill" : "heart")
                        .foregroundColor(isFav ? DS.Colors.danger : DS.Colors.textSecondary)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(0.1)) { appeared = true }
        }
    }

    // MARK: - Status Banner

    @ViewBuilder
    private var statusBanner: some View {
        switch solveState {
        case .playing:
            HStack(spacing: DS.Spacing.sm) {
                Image(systemName: puzzle.playerIsWhite ? "circle.fill" : "circle")
                    .font(.system(size: 14))
                    .foregroundColor(puzzle.playerIsWhite ? .white : DS.Colors.textTertiary)
                Text(puzzle.playerIsWhite ? "White to move" : "Black to move")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DS.Colors.textPrimary)
                Spacer()
                Text("Find the best continuation")
                    .font(.system(size: 12))
                    .foregroundColor(DS.Colors.textTertiary)
            }
            .padding(DS.Spacing.md)
            .background(DS.Colors.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            .overlay(RoundedRectangle(cornerRadius: DS.Radius.md).strokeBorder(DS.Colors.border, lineWidth: 1))

        case .solved:
            HStack(spacing: DS.Spacing.sm) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(DS.Colors.success)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Puzzle Solved!")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(DS.Colors.success)
                    Text("Excellent calculation")
                        .font(.system(size: 12))
                        .foregroundColor(DS.Colors.textTertiary)
                }
                Spacer()
                Button("Retry") { resetPuzzle() }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(DS.Colors.textSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(DS.Colors.surfaceElevated)
                    .clipShape(Capsule())
                    .overlay(Capsule().strokeBorder(DS.Colors.border, lineWidth: 1))
            }
            .padding(DS.Spacing.md)
            .background(DS.Colors.success.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            .overlay(RoundedRectangle(cornerRadius: DS.Radius.md).strokeBorder(DS.Colors.success.opacity(0.3), lineWidth: 1))
            .transition(.asymmetric(insertion: .scale(scale: 0.95).combined(with: .opacity), removal: .opacity))

        case .failed:
            HStack(spacing: DS.Spacing.sm) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(DS.Colors.danger)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Incorrect Move")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(DS.Colors.danger)
                    Text("Study the position and try again")
                        .font(.system(size: 12))
                        .foregroundColor(DS.Colors.textTertiary)
                }
                Spacer()
                Button("Retry") { resetPuzzle() }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(DS.Colors.textSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(DS.Colors.surfaceElevated)
                    .clipShape(Capsule())
                    .overlay(Capsule().strokeBorder(DS.Colors.border, lineWidth: 1))
            }
            .padding(DS.Spacing.md)
            .background(DS.Colors.danger.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            .overlay(RoundedRectangle(cornerRadius: DS.Radius.md).strokeBorder(DS.Colors.danger.opacity(0.3), lineWidth: 1))
            .transition(.asymmetric(insertion: .scale(scale: 0.95).combined(with: .opacity), removal: .opacity))
        }
    }

    // MARK: - Puzzle Info Panel

    private var puzzleInfoPanel: some View {
        HStack(spacing: DS.Spacing.md) {
            // Rating
            VStack(spacing: 2) {
                Text("\(puzzle.rating)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(puzzle.rating.difficultyColor)
                Text("Rating")
                    .font(.system(size: 11))
                    .foregroundColor(DS.Colors.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Spacing.md)
            .background(DS.Colors.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            .overlay(RoundedRectangle(cornerRadius: DS.Radius.md).strokeBorder(DS.Colors.border, lineWidth: 1))

            // Moves to find
            VStack(spacing: 2) {
                Text("\(puzzle.playerMoves.count)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(DS.Colors.gold)
                Text("Moves")
                    .font(.system(size: 11))
                    .foregroundColor(DS.Colors.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Spacing.md)
            .background(DS.Colors.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            .overlay(RoundedRectangle(cornerRadius: DS.Radius.md).strokeBorder(DS.Colors.border, lineWidth: 1))

            // Popularity
            VStack(spacing: 2) {
                Text("\(puzzle.popularity)%")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(DS.Colors.textPrimary)
                Text("Popularity")
                    .font(.system(size: 11))
                    .foregroundColor(DS.Colors.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Spacing.md)
            .background(DS.Colors.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            .overlay(RoundedRectangle(cornerRadius: DS.Radius.md).strokeBorder(DS.Colors.border, lineWidth: 1))
        }
    }

    // MARK: - Move Progress

    @ViewBuilder
    private var moveProgressView: some View {
        let playerMoveCount = puzzle.playerMoves.filter { _ in true }.count
        let movesCompleted = moveHistory.filter { $0.correct }.count

        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            HStack {
                Text("Progress")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(DS.Colors.textSecondary)
                Spacer()
                Text("\(movesCompleted) / \((playerMoveCount + 1) / 2)")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(DS.Colors.textTertiary)
            }

            HStack(spacing: DS.Spacing.xs) {
                // Each dot = one player move in the solution
                ForEach(0..<((playerMoveCount + 1) / 2), id: \.self) { i in
                    let correctMoves = moveHistory.filter { $0.correct }.count
                    Capsule()
                        .fill(i < correctMoves ? DS.Colors.success : DS.Colors.border)
                        .frame(height: 6)
                        .animation(.spring(response: 0.3), value: correctMoves)
                }
            }
        }
        .padding(DS.Spacing.md)
        .background(DS.Colors.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.md).strokeBorder(DS.Colors.border, lineWidth: 1))
    }

    // MARK: - Themes Row

    private var themesRow: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text("Themes")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(DS.Colors.textSecondary)

            FlowLayout(spacing: DS.Spacing.sm) {
                ForEach(puzzle.themes, id: \.self) { theme in
                    Text(theme.camelCaseToWords())
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(DS.Colors.textTertiary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(DS.Colors.surfaceElevated)
                        .clipShape(Capsule())
                        .overlay(Capsule().strokeBorder(DS.Colors.border, lineWidth: 1))
                }
            }
        }
        .padding(DS.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DS.Colors.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.md).strokeBorder(DS.Colors.border, lineWidth: 1))
    }

    // MARK: - Logic

    private func handleMoveResult(correct: Bool) {
        let idx = moveHistory.count
        withAnimation(.spring(response: 0.3)) {
            moveHistory.append(MoveResult(moveIndex: idx, correct: correct))
        }

        if correct {
            // Count how many player moves we need (every other move starting from index 0 of playerMoves)
            let totalPlayerMoves = (puzzle.playerMoves.count + 1) / 2
            let correctCount = moveHistory.filter { $0.correct }.count
            if correctCount >= totalPlayerMoves {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.6)) {
                    solveState = .solved
                }
                store.markSolved(puzzle.id)
            }
        } else {
            withAnimation(.spring(response: 0.3)) {
                solveState = .failed
            }
        }
    }

    private func resetPuzzle() {
        withAnimation(.easeInOut(duration: 0.3)) {
            solveState = .playing
            moveHistory = []
            boardID = UUID()
        }
    }
}

// MARK: - FlowLayout (wrapping HStack)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var height: CGFloat = 0
        var x: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width && x > 0 {
                height += rowHeight + spacing
                x = 0
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        height += rowHeight
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX && x > bounds.minX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

// MARK: - String helpers

extension String {
    func camelCaseToWords() -> String {
        unicodeScalars.reduce("") { result, scalar in
            if CharacterSet.uppercaseLetters.contains(scalar) && !result.isEmpty {
                return result + " " + String(scalar)
            }
            return result + String(scalar)
        }
        .capitalized
    }
}
