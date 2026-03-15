import SwiftUI

struct HomeView: View {
    @Environment(PuzzleStore.self) private var store
    @State private var greeting = ""

    var body: some View {
        NavigationStack {
            ZStack {
                DS.Colors.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        HeroHeaderView(greeting: greeting)
                            .padding(.bottom, DS.Spacing.xl)

                        StatsRowView()
                            .padding(.horizontal, DS.Spacing.lg)
                            .padding(.bottom, DS.Spacing.xl)

                        VStack(alignment: .leading, spacing: DS.Spacing.md) {
                            SectionHeader(title: "Featured Categories", subtitle: "Choose your challenge")
                                .padding(.horizontal, DS.Spacing.lg)
                            CategoryGridView()
                                .padding(.horizontal, DS.Spacing.lg)
                        }
                        .padding(.bottom, DS.Spacing.xl)

                        VStack(alignment: .leading, spacing: DS.Spacing.md) {
                            SectionHeader(title: "Quick Challenge", subtitle: "Jump right in")
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
            LinearGradient(colors: [DS.Colors.surfaceElevated, DS.Colors.background],
                           startPoint: .top, endPoint: .bottom)
                .frame(height: 220)
                .overlay(ChessBoardPattern().opacity(0.05))
                .clipped()

            VStack {
                LinearGradient(colors: [DS.Colors.goldLight.opacity(0.8), DS.Colors.gold.opacity(0.3), .clear],
                               startPoint: .leading, endPoint: .trailing)
                    .frame(height: 2)
                Spacer()
            }

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text(greeting)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(DS.Colors.textTertiary)
                        .tracking(1).textCase(.uppercase)
                    Text("Chess Hub")
                        .font(.system(size: 38, weight: .bold, design: .serif))
                        .foregroundStyle(LinearGradient(
                            colors: [DS.Colors.textPrimary, DS.Colors.textSecondary],
                            startPoint: .topLeading, endPoint: .bottomTrailing))
                    Text("Train your tactical vision")
                        .font(.system(size: 14)).foregroundColor(DS.Colors.textTertiary)
                }
                Spacer()
                ZStack {
                    Circle().fill(DS.Colors.gold.opacity(0.1)).frame(width: 72, height: 72)
                        .overlay(Circle().strokeBorder(DS.Colors.gold.opacity(0.3), lineWidth: 1))
                    Text("♚").font(.system(size: 40)).foregroundColor(DS.Colors.gold)
                        .shadow(color: DS.Colors.gold.opacity(0.4), radius: 8)
                }
            }
            .padding(.horizontal, DS.Spacing.lg).padding(.bottom, DS.Spacing.lg)
            .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 10)
        }
        .onAppear { withAnimation(.easeOut(duration: 0.5).delay(0.1)) { appeared = true } }
    }
}

// MARK: - Stats Row
struct StatsRowView: View {
    @Environment(PuzzleStore.self) private var store

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            StatPill(value: "\(store.puzzles.count)", label: "Puzzles",   icon: "square.grid.2x2.fill")
            StatPill(value: "\(store.totalSolved)",   label: "Solved",    icon: "checkmark.circle.fill")
            StatPill(value: "\(store.totalFavorites)",label: "Saved",     icon: "heart.fill")
        }
    }
}

struct StatPill: View {
    let value: String; let label: String; let icon: String
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 10)).foregroundColor(DS.Colors.gold)
                Text(value).font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(DS.Colors.textPrimary)
            }
            Text(label).font(.system(size: 11, weight: .medium)).foregroundColor(DS.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, DS.Spacing.md)
        .background(DS.Colors.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.md).strokeBorder(DS.Colors.border, lineWidth: 1))
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String; let subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.system(size: 20, weight: .semibold, design: .serif))
                .foregroundColor(DS.Colors.textPrimary)
            Text(subtitle).font(.system(size: 12, weight: .medium))
                .foregroundColor(DS.Colors.textTertiary).tracking(0.5)
        }
    }
}

// MARK: - Category Grid
struct CategoryGridView: View {
    @Environment(PuzzleStore.self) private var store
    let columns = [GridItem(.flexible(), spacing: DS.Spacing.md), GridItem(.flexible(), spacing: DS.Spacing.md)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: DS.Spacing.md) {
            ForEach(Array(PuzzleTheme.featured.enumerated()), id: \.element) { index, theme in
                NavigationLink(destination: PuzzleListView(theme: theme)) {
                    CategoryCard(theme: theme, count: store.count(forTheme: theme), index: index)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct CategoryCard: View {
    let theme: PuzzleTheme; let count: Int; let index: Int
    @State private var appeared = false

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: DS.Radius.lg).fill(DS.Colors.surfaceElevated)
                .overlay(RoundedRectangle(cornerRadius: DS.Radius.lg).fill(
                    LinearGradient(colors: [theme.gradient[0].opacity(0.15), .clear],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)))
                .overlay(RoundedRectangle(cornerRadius: DS.Radius.lg).strokeBorder(
                    LinearGradient(colors: [theme.gradient[0].opacity(0.4), theme.gradient[1].opacity(0.1)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))

            // Decorative piece
            VStack { HStack { Spacer()
                Text(decorativePiece).font(.system(size: 48))
                    .foregroundColor(theme.gradient[0].opacity(0.15))
                    .rotationEffect(.degrees(-10)).offset(x: 8, y: -8)
            }; Spacer() }

            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: DS.Radius.sm)
                        .fill(LinearGradient(colors: theme.gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 36, height: 36)
                    Image(systemName: theme.icon).font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(theme.rawValue).font(.system(size: 15, weight: .semibold)).foregroundColor(DS.Colors.textPrimary)
                    Text("\(count) puzzle\(count == 1 ? "" : "s")").font(.system(size: 12, weight: .medium))
                        .foregroundColor(DS.Colors.textTertiary)
                }
            }.padding(DS.Spacing.md)
        }
        .frame(height: 130)
        .scaleEffect(appeared ? 1 : 0.9).opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(Double(index) * 0.07)) { appeared = true }
        }
    }

    private var decorativePiece: String {
        ["♙","♘","♗","♖","♛","♚","♟","♞"][index % 8]
    }
}

// MARK: - Daily Puzzle Card
struct DailyPuzzleCard: View {
    @Environment(PuzzleStore.self) private var store

    var puzzle: Puzzle? { store.puzzles.first }

    var body: some View {
        if let puzzle = puzzle {
            NavigationLink(destination: PuzzleSolverView(puzzle: puzzle)) {
                HStack(spacing: DS.Spacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: DS.Radius.md)
                            .fill(DS.Colors.surface).frame(width: 72, height: 72)
                            .overlay(RoundedRectangle(cornerRadius: DS.Radius.md).strokeBorder(DS.Colors.border, lineWidth: 1))
                        MiniChessBoard().frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                        Text("DAILY PUZZLE").font(.system(size: 10, weight: .bold))
                            .foregroundColor(DS.Colors.gold).tracking(1.5)
                        Text("Puzzle #\(puzzle.id)").font(.system(size: 16, weight: .semibold))
                            .foregroundColor(DS.Colors.textPrimary)
                        Text("Rating \(puzzle.rating)").font(.system(size: 13))
                            .foregroundColor(DS.Colors.textTertiary)
                    }
                    Spacer()
                    RatingBadge(rating: puzzle.rating)
                    Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold))
                        .foregroundColor(DS.Colors.textTertiary)
                }
                .padding(DS.Spacing.md)
                .background(DS.Colors.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                .overlay(RoundedRectangle(cornerRadius: DS.Radius.lg).strokeBorder(DS.Colors.gold.opacity(0.25), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Shared UI Components

struct MiniChessBoard: View {
    var body: some View {
        GeometryReader { geo in
            let sq = geo.size.width / 8
            VStack(spacing: 0) {
                ForEach(0..<8, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<8, id: \.self) { col in
                            Rectangle()
                                .fill((row + col).isMultiple(of: 2) ? DS.Colors.pieceLight : DS.Colors.pieceDark)
                                .frame(width: sq, height: sq)
                        }
                    }
                }
            }
        }
    }
}

struct RatingBadge: View {
    let rating: Int
    var body: some View {
        Text(rating.difficultyLabel)
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(rating.difficultyColor)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(rating.difficultyColor.opacity(0.15))
            .clipShape(Capsule())
            .overlay(Capsule().strokeBorder(rating.difficultyColor.opacity(0.4), lineWidth: 1))
    }
}

struct ChessBoardPattern: View {
    private let squares = 12
    var body: some View {
        GeometryReader { geo in
            let size = geo.size.width / CGFloat(squares)
            VStack(spacing: 0) {
                ForEach(0..<squares, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<squares, id: \.self) { col in
                            Rectangle()
                                .fill((row + col).isMultiple(of: 2) ? Color.white : Color.clear)
                                .frame(width: size, height: size)
                        }
                    }
                }
            }
        }
    }
}
