import UIKit

struct TBFeedingToolbarItem {
    var title: String
    var size: CGSize
    var iconImage: UIImage?
    var style: TBFeedingToolbarItemStyle = .fullScreen
}

extension TBFeedingToolbarItem {
    enum TBFeedingToolbarItemStyle {
        case height(height: CGFloat)
        case fullScreen
    }
}
