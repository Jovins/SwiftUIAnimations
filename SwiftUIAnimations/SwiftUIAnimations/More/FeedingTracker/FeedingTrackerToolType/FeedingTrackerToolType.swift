import Foundation

enum FeedingTrackerToolType: Int, Codable {
    case nursing
    case bottle
    case pumping
    case diapers

    var title: String {
        switch self {
        case .nursing:
            return "Nursing"
        case .bottle:
            return "Bottle"
        case .pumping:
            return "Pumping"
        case .diapers:
            return "Diapers"
        }
    }

    var iconImage: UIImage? {
        switch self {
        case .nursing:
            return UIImage(named: "feeding_nursing")?.withRenderingMode(.alwaysTemplate).imageMaskedAndTinted(with: .GlobalIconPrimary)
        case .bottle:
            return UIImage(named: "feeding_bottle")?.withRenderingMode(.alwaysTemplate).imageMaskedAndTinted(with: .GlobalIconPrimary)
        case .pumping:
            return UIImage(named: "feeding_pumping")?.withRenderingMode(.alwaysTemplate).imageMaskedAndTinted(with: .GlobalIconPrimary)
        case .diapers:
            return UIImage(named: "feeding_diapers")?.withRenderingMode(.alwaysTemplate).imageMaskedAndTinted(with: .GlobalIconPrimary)
        }
    }
}
