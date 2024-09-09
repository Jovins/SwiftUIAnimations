import UIKit

final class TBMoreViewModel: NSObject {
    enum MoreMenu: Int, CaseIterable {
        case myProfile
        case bestOfTheBumpAwards
        case community
        case toolsAndResources
        case accountPreference
        case help
        case shareYourSuggestions
        case addTheBumpWidget

        var title: String {
            switch self {
            case .myProfile:
                return "My Profile"
            case .bestOfTheBumpAwards:
                return "Best of The Bump Awards"
            case .community:
                return "Community"
            case .accountPreference:
                return "Account Preferences"
            case .help:
                return "Help"
            case .toolsAndResources:
                return "Tools and Resources"
            case .shareYourSuggestions:
                return "Share Your Suggestions"
            case .addTheBumpWidget:
                return "Add The Bump Widget"
            }
        }

        var icon: TBIconList {
            switch self {
            case .myProfile:
                return TBIconList.profile
            case .bestOfTheBumpAwards:
                return TBIconList.bestofbaby
            case .community:
                return TBIconList.community
            case .accountPreference:
                return TBIconList.account
            case .help:
                return TBIconList.help
            case .toolsAndResources:
                return TBIconList.tools
            case .shareYourSuggestions:
                return TBIconList.feedback
            case .addTheBumpWidget:
                return TBIconList.widgetStar
            }
        }

        var link: String {
            switch self {
            case .myProfile:
                return "thebump://profile-dropdown"
            case .bestOfTheBumpAwards:
                return TBURLConstant.bestOfTheBumpAwards
            case .community:
                return "thebump://community/\(ScreenAnalyticsSourceType.moreMenu)"
            case .accountPreference:
                return "thebump://accountPreferences"
            case .help:
                return "thebump://contact-support"
            case .toolsAndResources:
                return "thebump://toolsAndResources"
            case .shareYourSuggestions:
                return "thebump://shareYourSuggestions"
            case .addTheBumpWidget:
                return "thebump://addTheBumpWidget"
            }
        }

        var indicatorItemType: TBNewItemIndicatorManager.IndicatorItemType {
            switch self {
            case .bestOfTheBumpAwards:
                return .bestofTheBumpAwards
            case .toolsAndResources:
                return .toolsAndResources
            case .community:
                return .community
            case .addTheBumpWidget:
                return .addTheBumpWidget
            case .accountPreference, .help, .myProfile, .shareYourSuggestions:
                return .none
            }
        }

        var shouldDisplayRightCaret: Bool {
            switch self {
            case .bestOfTheBumpAwards,
                 .community,
                 .myProfile,
                 .addTheBumpWidget:
                return false
            case .accountPreference, .help, .toolsAndResources, .shareYourSuggestions:
                return true
            }
        }
    }
}
