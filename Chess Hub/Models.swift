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
