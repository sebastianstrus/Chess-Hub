import SwiftUI

struct PuzzleDetailView: View {
    @EnvironmentObject var dataProvider: PuzzleDataProvider
    let puzzle: ChessPuzzle

    @State private var solutionRevealed = false
    @State private var imageScale: CGFloat = 1.0
    @State private var imageOffset: CGSize = .zero
    @State private var showCopied = false
    @State private var appeared = false

    var isFav: Bool { dataProvider.isFavorite(puzzle) }

    var body: some View {
        ZStack {
            DS.Colors.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Puzzle board image
                    PuzzleBoardView(imageName: puzzle.imageName)
                        .padding(.horizontal, DS.Spacing.lg)
                        .padding(.top, DS.Spacing.md)
                        .opacity(appeared ? 1 : 0)
                        .scaleEffect(appeared ? 1 : 0.95)

                    // Puzzle info
                    VStack(spacing: DS.Spacing.lg) {
                        // Title row
                        HStack {
                            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                                Text(puzzle.title)
                                    .font(.system(size: 24, weight: .bold, design: .serif))
                                    .foregroundColor(DS.Colors.textPrimary)

                                HStack(spacing: DS.Spacing.sm) {
                                    CategoryPill(category: puzzle.category)
                                    DifficultyBadge(difficulty: puzzle.difficulty)
                                }
                            }

                            Spacer()

                            FavoriteButton(isFavorite: isFav) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                    dataProvider.toggleFavorite(puzzle)
                                }
                            }
                        }

                        Divider()
                            .background(DS.Colors.border)

                        // Instructions
                        InstructionsBanner(category: puzzle.category)

                        // Solution section
                        SolutionSection(
                            solution: puzzle.solution,
                            isRevealed: $solutionRevealed
                        )

                        // Navigation hints
                        PuzzleTipCard()
                    }
                    .padding(.horizontal, DS.Spacing.lg)
                    .padding(.top, DS.Spacing.lg)
                    .padding(.bottom, DS.Spacing.xxxl)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(puzzle.category.rawValue)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DS.Colors.textSecondary)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        dataProvider.toggleFavorite(puzzle)
                    }
                } label: {
                    Image(systemName: isFav ? "heart.fill" : "heart")
                        .foregroundColor(isFav ? DS.Colors.danger : DS.Colors.textSecondary)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                appeared = true
            }
        }
    }
}

// MARK: - Puzzle Board View

struct PuzzleBoardView: View {
    let imageName: String
    @State private var imageScale: CGFloat = 1.0
    @State private var imageOffset: CGSize = .zero

    var body: some View {
        ZStack {
            // Frame
            RoundedRectangle(cornerRadius: DS.Radius.lg)
                .fill(DS.Colors.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.lg)
                        .strokeBorder(
                            LinearGradient(
                                colors: [DS.Colors.goldLight.opacity(0.5), DS.Colors.goldDark.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 8)
                .shadow(color: DS.Colors.gold.opacity(0.1), radius: 40, x: 0, y: 0)

            if let _ = UIImage(named: imageName) {
                // Use actual image when available
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg - 2))
                    .scaleEffect(imageScale)
                    .offset(imageOffset)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in imageScale = max(1, min(3, value)) }
                            .onEnded { _ in
                                if imageScale < 1.1 { withAnimation { imageScale = 1; imageOffset = .zero } }
                            }
                    )
            } else {
                // Placeholder full chess board
                FullChessBoard()
                    .padding(DS.Spacing.md)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            }

            // Pinch hint overlay
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Label("Pinch to zoom", systemImage: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(DS.Colors.textTertiary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.black.opacity(0.5))
                        .clipShape(Capsule())
                        .padding(DS.Spacing.sm)
                }
            }
        }
        .frame(height: UIScreen.main.bounds.width - DS.Spacing.lg * 2)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
    }
}

// MARK: - Full Chess Board

struct FullChessBoard: View {
    let files = ["a","b","c","d","e","f","g","h"]
    let ranks = ["8","7","6","5","4","3","2","1"]

    var body: some View {
        GeometryReader { geo in
            let total = min(geo.size.width, geo.size.height)
            let sq = total / 8

            ZStack {
                VStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<8, id: \.self) { col in
                                ZStack(alignment: .bottomTrailing) {
                                    Rectangle()
                                        .fill((row + col).isMultiple(of: 2) ? DS.Colors.pieceLight : DS.Colors.pieceDark)
                                        .frame(width: sq, height: sq)

                                    if col == 7 {
                                        Text(ranks[row])
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundColor((row + col).isMultiple(of: 2) ? DS.Colors.pieceDark : DS.Colors.pieceLight)
                                            .padding(2)
                                    }
                                    if row == 7 {
                                        Text(files[col])
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundColor((row + col).isMultiple(of: 2) ? DS.Colors.pieceDark : DS.Colors.pieceLight)
                                            .padding(.leading, 2)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(width: total, height: total)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
        }
    }
}

// MARK: - Category Pill

struct CategoryPill: View {
    let category: PuzzleCategory
    var body: some View {
        Text(category.rawValue)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(category.gradient[0])
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(category.gradient[0].opacity(0.12))
            .clipShape(Capsule())
            .overlay(Capsule().strokeBorder(category.gradient[0].opacity(0.35), lineWidth: 1))
    }
}

// MARK: - Favorite Button

struct FavoriteButton: View {
    let isFavorite: Bool
    let action: () -> Void
    @State private var bouncing = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) { bouncing = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { bouncing = false }
            action()
        }) {
            ZStack {
                Circle()
                    .fill(isFavorite ? DS.Colors.danger.opacity(0.15) : DS.Colors.surfaceElevated)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Circle().strokeBorder(
                            isFavorite ? DS.Colors.danger.opacity(0.4) : DS.Colors.border,
                            lineWidth: 1
                        )
                    )

                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 20))
                    .foregroundColor(isFavorite ? DS.Colors.danger : DS.Colors.textTertiary)
                    .scaleEffect(bouncing ? 1.3 : 1)
            }
        }
    }
}

// MARK: - Instructions Banner

struct InstructionsBanner: View {
    let category: PuzzleCategory

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 16))
                .foregroundColor(DS.Colors.gold)

            VStack(alignment: .leading, spacing: 2) {
                Text("Your Task")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(DS.Colors.gold)
                Text(category.description)
                    .font(.system(size: 13))
                    .foregroundColor(DS.Colors.textSecondary)
            }
        }
        .padding(DS.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DS.Colors.gold.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.md).strokeBorder(DS.Colors.gold.opacity(0.2), lineWidth: 1))
    }
}

// MARK: - Solution Section

struct SolutionSection: View {
    let solution: String
    @Binding var isRevealed: Bool
    @State private var revealProgress: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text("Solution")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(DS.Colors.textPrimary)

            ZStack {
                // Solution text (shown when revealed)
                VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                    Text(solution)
                        .font(.system(size: 17, weight: .semibold, design: .monospaced))
                        .foregroundColor(DS.Colors.textPrimary)
                        .padding(DS.Spacing.lg)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(DS.Colors.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.lg)
                        .strokeBorder(DS.Colors.success.opacity(0.3), lineWidth: 1)
                )
                .opacity(isRevealed ? 1 : 0)

                // Blur overlay (shown when hidden)
                if !isRevealed {
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            isRevealed = true
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: DS.Radius.lg)
                                .fill(DS.Colors.surfaceElevated)
                                .overlay(RoundedRectangle(cornerRadius: DS.Radius.lg).strokeBorder(DS.Colors.border, lineWidth: 1))

                            VStack(spacing: DS.Spacing.sm) {
                                ZStack {
                                    Circle()
                                        .fill(DS.Colors.surface)
                                        .frame(width: 52, height: 52)
                                        .overlay(Circle().strokeBorder(DS.Colors.gold.opacity(0.3), lineWidth: 1))
                                    Image(systemName: "eye.slash.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(DS.Colors.gold)
                                }

                                Text("Reveal Solution")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(DS.Colors.textPrimary)

                                Text("Tap when you're ready")
                                    .font(.system(size: 12))
                                    .foregroundColor(DS.Colors.textTertiary)
                            }
                            .padding(.vertical, DS.Spacing.xl)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(minHeight: 100)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isRevealed)

            if isRevealed {
                Button(action: {
                    withAnimation { isRevealed = false }
                }) {
                    Label("Hide solution", systemImage: "eye.slash")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(DS.Colors.textTertiary)
                }
                .transition(.opacity)
            }
        }
    }
}

// MARK: - Puzzle Tip Card

struct PuzzleTipCard: View {
    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(DS.Colors.textTertiary)

            Text("Study the position carefully before revealing the solution. The best players visualize multiple moves ahead.")
                .font(.system(size: 13))
                .foregroundColor(DS.Colors.textTertiary)
                .lineSpacing(4)
        }
        .padding(DS.Spacing.md)
        .background(DS.Colors.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.md).strokeBorder(DS.Colors.border, lineWidth: 1))
    }
}
