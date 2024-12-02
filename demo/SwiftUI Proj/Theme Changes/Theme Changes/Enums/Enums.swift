import Foundation
import SwiftUI

enum Theme: String, CaseIterable {
    case system = "System"
    case light  = "Light"
    case dark   = "Dark"

    func color(_ scheme: ColorScheme) -> Color {
        switch self {
        case .system:
            return scheme == .dark ? .moon : .sun
        case .light:
            return .sun
        case .dark:
            return .moon
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
