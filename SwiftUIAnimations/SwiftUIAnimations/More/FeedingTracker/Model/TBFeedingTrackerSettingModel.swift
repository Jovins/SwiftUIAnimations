import Foundation

public final class TBFeedingTrackerSettingModel: Codable {

    var type: FeedingTrackerToolType
    var isVisible: Bool
    init(type: FeedingTrackerToolType, visible: Bool = true) {
        self.type = type
        self.isVisible = visible
    }

}
