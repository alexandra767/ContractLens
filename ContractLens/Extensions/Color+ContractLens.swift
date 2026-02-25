import SwiftUI

extension Color {
    // MARK: - Primary Palette
    static let clNavy = Color(red: 0.1, green: 0.15, blue: 0.35)
    static let clSlate = Color(red: 0.35, green: 0.4, blue: 0.5)
    static let clSky = Color(red: 0.4, green: 0.6, blue: 0.9)

    // MARK: - Risk Colors
    static let clRiskLow = Color(red: 0.2, green: 0.7, blue: 0.4)
    static let clRiskMedium = Color(red: 0.9, green: 0.7, blue: 0.2)
    static let clRiskHigh = Color(red: 0.85, green: 0.25, blue: 0.2)

    // MARK: - Backgrounds
    static let clBackground = Color(red: 0.96, green: 0.97, blue: 0.98)
    static let clCardBackground = Color.white
}

// MARK: - ShapeStyle Extensions
// Allows using .clSky etc. in .foregroundStyle() and other ShapeStyle contexts

extension ShapeStyle where Self == Color {
    static var clNavy: Color { Color.clNavy }
    static var clSlate: Color { Color.clSlate }
    static var clSky: Color { Color.clSky }
    static var clRiskLow: Color { Color.clRiskLow }
    static var clRiskMedium: Color { Color.clRiskMedium }
    static var clRiskHigh: Color { Color.clRiskHigh }
    static var clBackground: Color { Color.clBackground }
    static var clCardBackground: Color { Color.clCardBackground }
}
