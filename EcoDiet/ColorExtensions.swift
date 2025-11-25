import SwiftUI

// MARK: - EcoDiet Brand Colors
extension Color {
    static let ecoDietGreen = Color(hexString: "2F6B3F")!
    static let ecoDietSecondaryGreen = Color(hexString: "63A96E")!
    static let ecoDietOrange = Color(hexString: "F4A259")!
    static let ecoDietSand = Color(hexString: "F5ECD9")!
    static let ecoDietForest = Color(hexString: "1F2E1F")!
    
    init?(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - ShapeStyle Extension for EcoDiet Colors
extension ShapeStyle where Self == Color {
    static var ecoDietGreen: Color { Color.ecoDietGreen }
    static var ecoDietSecondaryGreen: Color { Color.ecoDietSecondaryGreen }
    static var ecoDietOrange: Color { Color.ecoDietOrange }
    static var ecoDietSand: Color { Color.ecoDietSand }
    static var ecoDietForest: Color { Color.ecoDietForest }
}
