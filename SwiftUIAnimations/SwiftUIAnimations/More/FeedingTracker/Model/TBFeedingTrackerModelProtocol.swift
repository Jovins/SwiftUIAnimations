import Foundation

protocol TBFeedingTrackerModelProtocol {

    var startTime: Date { get }
    var item: String? { get }
    var note: String? { get }
    var type: FeedingTrackerToolType { get }

}
