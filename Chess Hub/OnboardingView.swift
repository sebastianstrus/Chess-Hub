import SwiftUI

// MARK: - Onboarding Page Model

struct OnboardingPage: Identifiable {
    let id = UUID()
    let piece: String
    let title: String
    let subtitle: String
    let description: String
    let accentColor: Color
    let features: [String]
}

// MARK: - Onboarding View

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isAnimating = false

    let pages: [OnboardingPage] = [
        OnboardingPage(
            piece: "♔",
            title: "Welcome to\nChess Hub",
            subtitle: "Your Tactical Training Ground",
            description: "Sharpen your chess mind with hundreds of carefully curated puzzles across all skill levels.",
            accentColor: DS.Colors.gold,
            features: ["500+ hand-picked puzzles", "5 difficulty categories", "Track your progress"]
        ),
        OnboardingPage(
            piece: "♞",
            title: "Train Like\na Grandmaster",
            subtitle: "Structured Puzzle Categories",
            description: "From instant mate-in-one shots to complex four-move combinations. Every puzzle teaches you a new pattern.",
            accentColor: Color(hex: "#A0B8D0"),
            features: ["Mate in 1–4 challenges", "Special Selfmate puzzles", "Step-by-step solutions"]
        ),
        OnboardingPage(
            piece: "♛",
            title: "Build Your\nFavorites",
            subtitle: "Save & Revisit Anytime",
            description: "Heart the puzzles you love most. Return to difficult positions until you've truly mastered them.",
            accentColor: Color(hex: "#E07080"),
            features: ["Unlimited favorites", "Quick access collection", "Never lose a puzzle"]
        )
    ]

    var body: some View {
        ZStack {
            DS.Colors.background.ignoresSafeArea()
            ChessBoardPattern()
                .opacity(0.04)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button(action: complete) {
                        Text("Skip")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(DS.Colors.textTertiary)
                            .padding(.horizontal, DS.Spacing.md)
                            .padding(.vertical, DS.Spacing.sm)
                            .background(DS.Colors.surfaceElevated)
                            .clipShape(Capsule())
                            .overlay(Capsule().strokeBorder(DS.Colors.border, lineWidth: 1))
                    }
                    .opacity(currentPage < pages.count - 1 ? 1 : 0)
                }
                .padding(.horizontal, DS.Spacing.lg)
                .padding(.top, DS.Spacing.lg)

                // Pages
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentPage)

                // Bottom controls
                VStack(spacing: DS.Spacing.xl) {
                    // Page indicators
                    HStack(spacing: DS.Spacing.sm) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPage ? pages[currentPage].accentColor : DS.Colors.border)
                                .frame(width: index == currentPage ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
                        }
                    }

                    // CTA Button
                    Button(action: advance) {
                        HStack(spacing: DS.Spacing.sm) {
                            Text(currentPage == pages.count - 1 ? "Start Solving" : "Continue")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(DS.Colors.background)

                            Image(systemName: currentPage == pages.count - 1 ? "checkmark" : "arrow.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(DS.Colors.background)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [pages[currentPage].accentColor, pages[currentPage].accentColor.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.full))
                        .shadow(color: pages[currentPage].accentColor.opacity(0.4), radius: 16, x: 0, y: 6)
                    }
                    .padding(.horizontal, DS.Spacing.lg)
                    .animation(.easeInOut(duration: 0.3), value: currentPage)
                }
                .padding(.bottom, DS.Spacing.xxl)
            }
        }
    }

    private func advance() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            if currentPage < pages.count - 1 {
                currentPage += 1
            } else {
                complete()
            }
        }
    }

    private func complete() {
        appState.hasSeenOnboarding = true
    }
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Piece display
            ZStack {
                // Outer ring
                Circle()
                    .strokeBorder(page.accentColor.opacity(0.15), lineWidth: 1)
                    .frame(width: 200, height: 200)

                // Inner glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [page.accentColor.opacity(0.15), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 180, height: 180)

                // Piece
                ZStack {
                    Circle()
                        .fill(DS.Colors.surfaceElevated)
                        .frame(width: 130, height: 130)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [page.accentColor.opacity(0.6), page.accentColor.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(color: page.accentColor.opacity(0.3), radius: 24, x: 0, y: 8)

                    Text(page.piece)
                        .font(.system(size: 68))
                        .foregroundColor(page.accentColor)
                        .shadow(color: page.accentColor.opacity(0.5), radius: 8)
                }
            }
            .scaleEffect(appeared ? 1 : 0.8)
            .opacity(appeared ? 1 : 0)

            Spacer().frame(height: DS.Spacing.xxl)

            // Text content
            VStack(spacing: DS.Spacing.md) {
                Text(page.title)
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundColor(DS.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Text(page.subtitle)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(page.accentColor)
                    .tracking(2)
                    .textCase(.uppercase)

                Text(page.description)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(DS.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, DS.Spacing.xl)
                    .padding(.top, DS.Spacing.xs)
            }
            .offset(y: appeared ? 0 : 20)
            .opacity(appeared ? 1 : 0)

            Spacer().frame(height: DS.Spacing.xl)

            // Feature pills
            VStack(spacing: DS.Spacing.sm) {
                ForEach(Array(page.features.enumerated()), id: \.offset) { index, feature in
                    HStack(spacing: DS.Spacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(page.accentColor)

                        Text(feature)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(DS.Colors.textSecondary)

                        Spacer()
                    }
                    .padding(.horizontal, DS.Spacing.lg)
                    .padding(.vertical, 10)
                    .background(DS.Colors.surfaceElevated)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Radius.md)
                            .strokeBorder(DS.Colors.border, lineWidth: 1)
                    )
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 10)
                    .animation(.easeOut(duration: 0.4).delay(0.2 + Double(index) * 0.08), value: appeared)
                }
            }
            .padding(.horizontal, DS.Spacing.lg)

            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appeared = true
            }
        }
        .onDisappear { appeared = false }
    }
}
