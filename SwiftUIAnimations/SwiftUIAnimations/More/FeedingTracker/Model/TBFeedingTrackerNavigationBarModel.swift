import Foundation

struct TBFeedingTrackerNavigationBarModel {

    let type: NavigationButtonType
    var action: Selector?
}

extension TBFeedingTrackerNavigationBarModel {

    enum NavigationButtonType: Int {
        case share = 0
        case setting
        case help
        case back
        case close

        var image: UIImage? {
            switch self {
            case .share:
                return TBIconList.share.image()
            case .setting:
                return TBIconList.settings.image()
            case .help:
                return TBIconList.question.image()
            case .back:
                return TBIconList.caretLeft.image(sizeOption: .normal)
            case .close:
                return TBIconList.close.image(sizeOption: .normal)
            }
        }
    }

}
