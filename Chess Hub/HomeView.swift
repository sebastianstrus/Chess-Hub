import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dataProvider: PuzzleDataProvider
    @State private var headerAppeared = false
    @State private var greeting = ""

    var body: some View {
        NavigationStack {
            ZStack {
                DS.Colors.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Hero header
                        HeroHeaderView(greeting: greeting)
                            .padding(.bottom, DS.Spacing.xl)

                        // Stats row
                        StatsRowView()
                            .padding(.horizontal, DS.Spacing.lg)
                            .padding(.bottom, DS.Spacing.xl)

                        // Category section
                        VStack(alignment: .leading, spacing: DS.Spacing.md) {
                            SectionHeader(title: "Puzzle Categories", subtitle: "Choose your challenge")
                                .padding(.horizontal, DS.Spacing.lg)

                            CategoryGridView()
                                .padding(.horizontal, DS.Spacing.lg)
                        }
                        .padding(.bottom, DS.Spacing.xl)

                        // Quick pick section
                        VStack(alignment: .leading, spacing: DS.Spacing.md) {
                            SectionHeader(title: "Quick Challenge", subtitle: "Puzzle of the day")
                                .padding(.horizontal, DS.Spacing.lg)

                            DailyPuzzleCard()
                                .padding(.horizontal, DS.Spacing.lg)
                        }
                        .padding(.bottom, DS.Spacing.xxxl)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear { updateGreeting() }
    }

    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: greeting = "Good morning"
        case 12..<17: greeting = "Good afternoon"
        default: greeting = "Good evening"
        }
    }
}

// MARK: - Hero Header

struct HeroHeaderView: View {
    let greeting: String
    @State private var appeared = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background gradient
            LinearGradient(
                colors: [DS.Colors.surfaceElevated, DS.Colors.background],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 220)
            .overlay(
                ChessBoardPattern()
                    .opacity(0.05)
            )
            .clipped()

            // Gold accent line at top
            VStack {
                LinearGradient(
                    colors: [DS.Colors.goldLight.opacity(0.8), DS.Colors.gold.opacity(0.3), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 2)
                Spacer()
            }

            // Content
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text(greeting)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(DS.Colors.textTertiary)
                        .tracking(1)
                        .textCase(.uppercase)

                    Text("Chess Hub")
                        .font(.system(size: 38, weight: .bold, design: .serif))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [DS.Colors.textPrimary, DS.Colors.textSecondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("Train your tactical vision")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(DS.Colors.textTertiary)
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(DS.Colors.gold.opacity(0.1))
                        .frame(width: 72, height: 72)
                        .overlay(Circle().strokeBorder(DS.Colors.gold.opacity(0.3), lineWidth: 1))

                    Text("♚")
                        .font(.system(size: 40))
                        .foregroundColor(DS.Colors.gold)
                        .shadow(color: DS.Colors.gold.opacity(0.4), radius: 8)
                }
            }
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.bottom, DS.Spacing.lg)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) { appeared = true }
        }
    }
}

// MARK: - Stats Row

struct StatsRowView: View {
    @EnvironmentObject var dataProvider: PuzzleDataProvider

    var totalPuzzles: Int {
        PuzzleCategory.allCases.filter { $0 != .favorites }.reduce(0) { $0 + dataProvider.puzzleCount(for: $1) }
    }

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            StatPill(value: "\(totalPuzzles)", label: "Puzzles", icon: "square.grid.2x2.fill")
            StatPill(value: "\(dataProvider.puzzleCount(for: .favorites))", label: "Saved", icon: "heart.fill")
            StatPill(value: "5", label: "Categories", icon: "list.bullet")
        }
    }
}

struct StatPill: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundColor(DS.Colors.gold)
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(DS.Colors.textPrimary)
            }
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(DS.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DS.Spacing.md)
        .background(DS.Colors.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.md).strokeBorder(DS.Colors.border, lineWidth: 1))
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 20, weight: .semibold, design: .serif))
                .foregroundColor(DS.Colors.textPrimary)
            Text(subtitle)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(DS.Colors.textTertiary)
                .tracking(0.5)
        }
    }
}

// MARK: - Category Grid

struct CategoryGridView: View {
    @EnvironmentObject var dataProvider: PuzzleDataProvider

    let categories: [PuzzleCategory] = [.mateIn1, .mateIn2, .mateIn3, .mateIn4, .selfmate]

    let columns = [
        GridItem(.flexible(), spacing: DS.Spacing.md),
        GridItem(.flexible(), spacing: DS.Spacing.md)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: DS.Spacing.md) {
            ForEach(Array(categories.enumerated()), id: \.element) { index, category in
                NavigationLink(destination: PuzzleListView(category: category)) {
                    CategoryCard(
                        category: category,
                        count: dataProvider.puzzleCount(for: category),
                        index: index
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Category Card

struct CategoryCard: View {
    let category: PuzzleCategory
    let count: Int
    let index: Int

    @State private var appeared = false
    @State private var isPressed = false

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background
            RoundedRectangle(cornerRadius: DS.Radius.lg)
                .fill(DS.Colors.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.lg)
                        .fill(
                            LinearGradient(
                                colors: [category.gradient[0].opacity(0.15), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.lg)
                        .strokeBorder(
                            LinearGradient(
                                colors: [category.gradient[0].opacity(0.4), category.gradient[1].opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )

            // Chess piece in corner
            VStack {
                HStack {
                    Spacer()
                    Text(chessPiece(for: category))
                        .font(.system(size: 48))
                        .foregroundColor(category.gradient[0].opacity(0.2))
                        .rotationEffect(.degrees(-10))
                        .offset(x: 8, y: -8)
                }
                Spacer()
            }

            // Content
            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: DS.Radius.sm)
                        .fill(
                            LinearGradient(colors: category.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 36, height: 36)

                    Image(systemName: category.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(category.rawValue)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(DS.Colors.textPrimary)

                    Text("\(count) puzzle\(count == 1 ? "" : "s")")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(DS.Colors.textTertiary)
                }
            }
            .padding(DS.Spacing.md)
        }
        .frame(height: 130)
        .scaleEffect(isPressed ? 0.96 : 1)
        .scaleEffect(appeared ? 1 : 0.9)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(Double(index) * 0.08)) {
                appeared = true
            }
        }
        .onTapGesture { /* handled by NavigationLink */ }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }

    private func chessPiece(for category: PuzzleCategory) -> String {
        switch category {
        case .mateIn1: return "♙"
        case .mateIn2: return "♘"
        case .mateIn3: return "♗"
        case .mateIn4: return "♖"
        case .selfmate: return "♛"
        case .favorites: return "♚"
        }
    }
}

// MARK: - Daily Puzzle Card

struct DailyPuzzleCard: View {
    @EnvironmentObject var dataProvider: PuzzleDataProvider

    var puzzle: ChessPuzzle? {
        dataProvider.puzzles(for: .mateIn1).first
    }

    var body: some View {
        if let puzzle = puzzle {
            NavigationLink(destination: PuzzleDetailView(puzzle: puzzle)) {
                HStack(spacing: DS.Spacing.md) {
                    // Puzzle thumbnail placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: DS.Radius.md)
                            .fill(DS.Colors.surface)
                            .frame(width: 80, height: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: DS.Radius.md)
                                    .strokeBorder(DS.Colors.border, lineWidth: 1)
                            )

                        // Placeholder chess board
                        MiniChessBoard()
                            .frame(width: 64, height: 64)
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                    }

                    VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                        HStack {
                            Text("DAILY PUZZLE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(DS.Colors.gold)
                                .tracking(1.5)

                            Spacer()

                            DifficultyBadge(difficulty: puzzle.difficulty)
                        }

                        Text(puzzle.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(DS.Colors.textPrimary)

                        Text(puzzle.category.rawValue)
                            .font(.system(size: 13))
                            .foregroundColor(DS.Colors.textTertiary)
                    }

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(DS.Colors.textTertiary)
                }
                .padding(DS.Spacing.md)
                .background(DS.Colors.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.lg)
                        .strokeBorder(DS.Colors.border, lineWidth: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.lg)
                        .strokeBorder(DS.Colors.gold.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Mini Chess Board

struct MiniChessBoard: View {
    private let squares = 8
    var body: some View {
        GeometryReader { geo in
            let size = geo.size.width / CGFloat(squares)
            VStack(spacing: 0) {
                ForEach(0..<squares, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<squares, id: \.self) { col in
                            Rectangle()
                                .fill((row + col).isMultiple(of: 2) ? DS.Colors.pieceLight : DS.Colors.pieceDark)
                                .frame(width: size, height: size)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Difficulty Badge

struct DifficultyBadge: View {
    let difficulty: ChessPuzzle.DifficultyLevel

    var color: Color {
        switch difficulty {
        case .easy: return DS.Colors.success
        case .medium: return DS.Colors.gold
        case .hard: return Color(hex: "#E07040")
        case .grandmaster: return DS.Colors.danger
        }
    }

    var body: some View {
        Text(difficulty.rawValue)
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
            .overlay(Capsule().strokeBorder(color.opacity(0.4), lineWidth: 1))
    }
}
