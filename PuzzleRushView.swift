import SwiftUI
import Foundation

// MARK: - Puzzle Rush Manager

@Observable
class PuzzleRushManager {
    private(set) var gameState: GameState = .idle
    private(set) var currentPuzzle: Puzzle?
    private(set) var score: Int = 0
    private(set) var livesRemaining: Int = 3
    private(set) var timeRemaining: TimeInterval = 180 // 3 minutes
    private(set) var puzzleQueue: [Puzzle] = []
    
    private var timer: Timer?
    private let puzzleStore: PuzzleStore
    
    enum GameState {
        case idle
        case playing
        case gameOver
    }
    
    struct HighScore: Codable, Identifiable {
        let id: UUID
        let score: Int
        let date: Date
        
        init(score: Int) {
            self.id = UUID()
            self.score = score
            self.date = Date()
        }
    }
    
    init(puzzleStore: PuzzleStore) {
        self.puzzleStore = puzzleStore
    }
    
    func startGame() {
        // Reset game state
        score = 0
        livesRemaining = 3
        timeRemaining = 180
        gameState = .playing
        
        // Prepare puzzle queue with random puzzles
        puzzleQueue = puzzleStore.puzzles.shuffled()
        
        // Load first puzzle
        loadNextPuzzle()
        
        // Start timer
        startTimer()
    }
    
    func endGame() {
        stopTimer()
        gameState = .gameOver
        saveHighScore()
    }
    
    func resetGame() {
        stopTimer()
        gameState = .idle
        currentPuzzle = nil
        score = 0
        livesRemaining = 3
        timeRemaining = 180
        puzzleQueue = []
    }
    
    func handlePuzzleSolved(correct: Bool) {
        if correct {
            score += 1
            loadNextPuzzle()
        } else {
            livesRemaining -= 1
            if livesRemaining <= 0 {
                endGame()
            } else {
                loadNextPuzzle()
            }
        }
    }
    
    private func loadNextPuzzle() {
        guard !puzzleQueue.isEmpty else {
            // Refill queue if empty
            puzzleQueue = puzzleStore.puzzles.shuffled()
            return
        }
        currentPuzzle = puzzleQueue.removeFirst()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.timeRemaining -= 0.1
            if self.timeRemaining <= 0 {
                self.endGame()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - High Scores
    
    private let highScoresKey = "puzzleRushHighScores"
    private let maxHighScores = 10
    
    var highScores: [HighScore] {
        guard let data = UserDefaults.standard.data(forKey: highScoresKey),
              let scores = try? JSONDecoder().decode([HighScore].self, from: data) else {
            return []
        }
        return scores.sorted { $0.score > $1.score }
    }
    
    private func saveHighScore() {
        var scores = highScores
        scores.append(HighScore(score: score))
        scores.sort { $0.score > $1.score }
        
        // Keep only top scores
        if scores.count > maxHighScores {
            scores = Array(scores.prefix(maxHighScores))
        }
        
        if let data = try? JSONEncoder().encode(scores) {
            UserDefaults.standard.set(data, forKey: highScoresKey)
        }
    }
    
    var isNewHighScore: Bool {
        let scores = highScores
        return scores.isEmpty || score > (scores.last?.score ?? 0) || scores.count < maxHighScores
    }
}

// MARK: - Puzzle Rush View

struct PuzzleRushView: View {
    @Environment(PuzzleStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var manager: PuzzleRushManager
    @State private var showLeaderboard = false
    
    init(store: PuzzleStore) {
        _manager = State(initialValue: PuzzleRushManager(puzzleStore: store))
    }
    
    var body: some View {
        ZStack {
            DS.Colors.background.ignoresSafeArea()
            
            switch manager.gameState {
            case .idle:
                idleView
            case .playing:
                playingView
            case .gameOver:
                gameOverView
            }
        }
        .navigationTitle("Puzzle Rush")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showLeaderboard = true
                } label: {
                    Image(systemName: "list.number")
                        .foregroundColor(DS.Colors.gold)
                }
            }
        }
        .sheet(isPresented: $showLeaderboard) {
            LeaderboardView(manager: manager)
        }
        .onDisappear {
            // Reset game when navigating away
            if manager.gameState != .idle {
                manager.resetGame()
            }
        }
    }
    
    // MARK: - Idle View
    
    private var idleView: some View {
        ScrollView {
            VStack(spacing: DS.Spacing.xl) {
                Spacer().frame(height: DS.Spacing.xl)
                
                // Icon
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [DS.Colors.gold.opacity(0.2), DS.Colors.gold.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 120, height: 120)
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 56))
                        .foregroundColor(DS.Colors.gold)
                }
                
                VStack(spacing: DS.Spacing.sm) {
                    Text("Puzzle Rush")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundColor(DS.Colors.textPrimary)
                    Text("Time Attack Challenge")
                        .font(.system(size: 16))
                        .foregroundColor(DS.Colors.textSecondary)
                }
                
                // Rules
                VStack(spacing: DS.Spacing.md) {
                    RuleCard(
                        icon: "clock.fill",
                        title: "3 Minutes",
                        description: "Solve as many puzzles as you can"
                    )
                    RuleCard(
                        icon: "heart.fill",
                        title: "3 Lives",
                        description: "Three wrong moves and you're out"
                    )
                    RuleCard(
                        icon: "trophy.fill",
                        title: "High Score",
                        description: "Beat your personal best"
                    )
                }
                .padding(.horizontal, DS.Spacing.lg)
                
                // Start Button
                Button {
                    manager.startGame()
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Start Rush")
                            .fontWeight(.semibold)
                    }
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DS.Spacing.md)
                    .background(
                        LinearGradient(
                            colors: [DS.Colors.gold, DS.Colors.goldDark],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                }
                .padding(.horizontal, DS.Spacing.lg)
                .padding(.top, DS.Spacing.lg)
                
                Spacer()
            }
        }
    }
    
    // MARK: - Playing View
    
    private var playingView: some View {
        VStack(spacing: 0) {
            // Stats Header
            statsHeader
                .padding(.horizontal, DS.Spacing.lg)
                .padding(.top, DS.Spacing.md)
                .padding(.bottom, DS.Spacing.lg)
            
            // Puzzle Board
            if let puzzle = manager.currentPuzzle {
                ScrollView {
                    VStack(spacing: DS.Spacing.lg) {
                        LiveChessBoardView(puzzle: puzzle) { correct in
                            manager.handlePuzzleSolved(correct: correct)
                        }
                        .id(puzzle.id)
                        .padding(.horizontal, DS.Spacing.lg)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                        .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 8)
                        
                        // Puzzle info
                        HStack {
                            Text("Puzzle #\(puzzle.id)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(DS.Colors.textSecondary)
                            Spacer()
                            RatingBadge(rating: puzzle.rating)
                        }
                        .padding(.horizontal, DS.Spacing.lg)
                        .padding(.bottom, DS.Spacing.xxxl)
                    }
                }
            }
        }
    }
    
    private var statsHeader: some View {
        HStack(spacing: DS.Spacing.md) {
            // Timer
            VStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 16))
                    .foregroundColor(manager.timeRemaining < 30 ? DS.Colors.danger : DS.Colors.gold)
                Text(formatTime(manager.timeRemaining))
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(manager.timeRemaining < 30 ? DS.Colors.danger : DS.Colors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Spacing.md)
            .background(DS.Colors.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.md)
                    .strokeBorder(manager.timeRemaining < 30 ? DS.Colors.danger.opacity(0.3) : DS.Colors.border, lineWidth: 1)
            )
            
            // Score
            VStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(DS.Colors.success)
                Text("\(manager.score)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(DS.Colors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Spacing.md)
            .background(DS.Colors.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            .overlay(RoundedRectangle(cornerRadius: DS.Radius.md).strokeBorder(DS.Colors.border, lineWidth: 1))
            
            // Lives
            VStack(spacing: 4) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 16))
                    .foregroundColor(DS.Colors.danger)
                Text("\(manager.livesRemaining)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(DS.Colors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Spacing.md)
            .background(DS.Colors.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            .overlay(RoundedRectangle(cornerRadius: DS.Radius.md).strokeBorder(DS.Colors.border, lineWidth: 1))
        }
    }
    
    // MARK: - Game Over View
    
    private var gameOverView: some View {
        ScrollView {
            VStack(spacing: DS.Spacing.xl) {
                Spacer().frame(height: DS.Spacing.xl)
                
                // Result Icon
                ZStack {
                    Circle()
                        .fill(manager.isNewHighScore ? DS.Colors.gold.opacity(0.15) : DS.Colors.textTertiary.opacity(0.1))
                        .frame(width: 120, height: 120)
                    Image(systemName: manager.isNewHighScore ? "trophy.fill" : "flag.checkered")
                        .font(.system(size: 56))
                        .foregroundColor(manager.isNewHighScore ? DS.Colors.gold : DS.Colors.textSecondary)
                }
                
                VStack(spacing: DS.Spacing.sm) {
                    Text(manager.isNewHighScore ? "New High Score!" : "Game Over")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundColor(DS.Colors.textPrimary)
                    Text("You solved \(manager.score) puzzle\(manager.score == 1 ? "" : "s")")
                        .font(.system(size: 16))
                        .foregroundColor(DS.Colors.textSecondary)
                }
                
                // Score Card
                VStack(spacing: DS.Spacing.md) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("FINAL SCORE")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(DS.Colors.textTertiary)
                                .tracking(1.2)
                            Text("\(manager.score)")
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .foregroundColor(DS.Colors.gold)
                        }
                        Spacer()
                        if manager.isNewHighScore {
                            Image(systemName: "star.fill")
                                .font(.system(size: 32))
                                .foregroundColor(DS.Colors.gold)
                        }
                    }
                }
                .padding(DS.Spacing.lg)
                .background(DS.Colors.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.lg)
                        .strokeBorder(manager.isNewHighScore ? DS.Colors.gold.opacity(0.4) : DS.Colors.border, lineWidth: 1.5)
                )
                .padding(.horizontal, DS.Spacing.lg)
                
                // Buttons
                VStack(spacing: DS.Spacing.md) {
                    Button {
                        manager.startGame()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Play Again")
                                .fontWeight(.semibold)
                        }
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DS.Spacing.md)
                        .background(DS.Colors.gold)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                    }
                    
                    Button {
                        showLeaderboard = true
                    } label: {
                        HStack {
                            Image(systemName: "list.number")
                            Text("View Leaderboard")
                                .fontWeight(.semibold)
                        }
                        .font(.system(size: 16))
                        .foregroundColor(DS.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DS.Spacing.md)
                        .background(DS.Colors.surfaceElevated)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: DS.Radius.md)
                                .strokeBorder(DS.Colors.border, lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, DS.Spacing.lg)
                
                Spacer()
            }
        }
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: - Rule Card

struct RuleCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            ZStack {
                Circle()
                    .fill(DS.Colors.gold.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(DS.Colors.gold)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DS.Colors.textPrimary)
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(DS.Colors.textSecondary)
            }
            Spacer()
        }
        .padding(DS.Spacing.md)
        .background(DS.Colors.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.md).strokeBorder(DS.Colors.border, lineWidth: 1))
    }
}

// MARK: - Leaderboard View

struct LeaderboardView: View {
    @Environment(\.dismiss) private var dismiss
    let manager: PuzzleRushManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                DS.Colors.background.ignoresSafeArea()
                
                if manager.highScores.isEmpty {
                    emptyState
                } else {
                    leaderboardList
                }
            }
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(DS.Colors.gold)
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: DS.Spacing.lg) {
            Image(systemName: "list.number")
                .font(.system(size: 56))
                .foregroundColor(DS.Colors.textTertiary)
            Text("No High Scores Yet")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(DS.Colors.textPrimary)
            Text("Play Puzzle Rush to set your first score")
                .font(.system(size: 14))
                .foregroundColor(DS.Colors.textSecondary)
        }
    }
    
    private var leaderboardList: some View {
        ScrollView {
            VStack(spacing: DS.Spacing.sm) {
                ForEach(Array(manager.highScores.enumerated()), id: \.element.id) { index, score in
                    LeaderboardRow(rank: index + 1, score: score)
                }
            }
            .padding(DS.Spacing.lg)
        }
    }
}

struct LeaderboardRow: View {
    let rank: Int
    let score: PuzzleRushManager.HighScore
    
    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            // Rank
            ZStack {
                if rank <= 3 {
                    Circle()
                        .fill(rankColor.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: rank == 1 ? "trophy.fill" : "medal.fill")
                        .font(.system(size: 18))
                        .foregroundColor(rankColor)
                } else {
                    Text("\(rank)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(DS.Colors.textTertiary)
                        .frame(width: 40)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(score.score) puzzles")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DS.Colors.textPrimary)
                Text(formatDate(score.date))
                    .font(.system(size: 13))
                    .foregroundColor(DS.Colors.textTertiary)
            }
            
            Spacer()
        }
        .padding(DS.Spacing.md)
        .background(DS.Colors.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.md)
                .strokeBorder(rank <= 3 ? rankColor.opacity(0.3) : DS.Colors.border, lineWidth: 1)
        )
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return DS.Colors.gold
        case 2: return Color(hex: "#C0C0C0")
        case 3: return Color(hex: "#CD7F32")
        default: return DS.Colors.textTertiary
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
