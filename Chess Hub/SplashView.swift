import SwiftUI

struct SplashView: View {
    @EnvironmentObject var appState: AppState
    @State private var logoScale: CGFloat = 0.7
    @State private var logoOpacity: Double = 0
    @State private var crownOpacity: Double = 0
    @State private var crownOffset: CGFloat = -20
    @State private var textOpacity: Double = 0
    @State private var textOffset: CGFloat = 10
    @State private var bgOpacity: Double = 1
    @State private var shimmerOffset: CGFloat = -200
    @State private var boardOpacity: Double = 0

    var body: some View {
        ZStack {
            // Background
            DS.Colors.background
                .ignoresSafeArea()

            // Subtle chess board pattern in background
            ChessBoardPattern()
                .opacity(boardOpacity * 0.06)
                .ignoresSafeArea()

            // Radial glow behind logo
            RadialGradient(
                colors: [DS.Colors.gold.opacity(0.15), .clear],
                center: .center,
                startRadius: 0,
                endRadius: 200
            )
            .frame(width: 400, height: 400)
            .opacity(logoOpacity)

            VStack(spacing: DS.Spacing.lg) {
                Spacer()

                // King piece icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [DS.Colors.surfaceElevated, DS.Colors.surface],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 110, height: 110)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [DS.Colors.goldLight.opacity(0.8), DS.Colors.goldDark.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(color: DS.Colors.gold.opacity(0.3), radius: 20, x: 0, y: 8)

                    Text("♚")
                        .font(.system(size: 58))
                        .foregroundColor(DS.Colors.goldLight)
                        .shadow(color: DS.Colors.gold.opacity(0.6), radius: 8, x: 0, y: 2)
                        .offset(y: crownOffset)
                        .opacity(crownOpacity)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                VStack(spacing: DS.Spacing.xs) {
                    Text("CHESS HUB")
                        .font(.system(size: 36, weight: .bold, design: .serif))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [DS.Colors.goldLight, DS.Colors.gold, DS.Colors.goldDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .tracking(6)

                    Text("MASTER EVERY PUZZLE")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(DS.Colors.textTertiary)
                        .tracking(3)
                }
                .opacity(textOpacity)
                .offset(y: textOffset)

                Spacer()

                // Loading indicator
                VStack(spacing: DS.Spacing.sm) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: DS.Colors.gold.opacity(0.6)))
                        .scaleEffect(0.8)

                    Text("Loading puzzles…")
                        .font(.system(size: 11))
                        .foregroundColor(DS.Colors.textTertiary)
                        .tracking(1)
                }
                .opacity(textOpacity)
                .padding(.bottom, DS.Spacing.xxl)
            }
        }
        .opacity(bgOpacity)
        .onAppear { runAnimation() }
    }

    private func runAnimation() {
        withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
            boardOpacity = 1
        }
        withAnimation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.3)) {
            logoScale = 1.0
            logoOpacity = 1
        }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.6)) {
            crownOpacity = 1
            crownOffset = 0
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.8)) {
            textOpacity = 1
            textOffset = 0
        }
        // Dismiss after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            withAnimation(.easeInOut(duration: 0.5)) {
                bgOpacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                appState.showSplash = false
            }
        }
    }
}

// MARK: - Chess Board Background Pattern

//struct ChessBoardPattern: View {
//    private let squares = 12
//    var body: some View {
//        GeometryReader { geo in
//            let size = geo.size.width / CGFloat(squares)
//            VStack(spacing: 0) {
//                ForEach(0..<squares, id: \.self) { row in
//                    HStack(spacing: 0) {
//                        ForEach(0..<squares, id: \.self) { col in
//                            Rectangle()
//                                .fill((row + col).isMultiple(of: 2) ? Color.white : Color.clear)
//                                .frame(width: size, height: size)
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
