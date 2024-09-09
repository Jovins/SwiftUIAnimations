import UIKit

extension TBNursingModel {
    enum Side: Codable {
        case left
        case right

        var normalTitle: String {
            switch self {
            case .left:
                return "Left"
            case .right:
                return "Right"
            }
        }
    }
}

final class TBNursingModel: NSObject, Codable, TBFeedingTrackerModelProtocol {
    let id: String
    var startTime: Date
    var savedTime: Date?
    var updatedTime: Date
    var note: String?
    var lastBreast: Side?
    var leftBreast: TBBreastModel = TBBreastModel()
    var rightBreast: TBBreastModel = TBBreastModel()
    var archived: Bool
    var item: String? { "Nursing" }
    var type: FeedingTrackerToolType { .nursing }

    override init() {
        self.id = UUID().uuidString
        self.startTime = Date()
        self.updatedTime = Date()
        self.archived = false
        super.init()
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.startTime = try container.decode(Date.self, forKey: .startTime)
        self.savedTime = try container.decodeIfPresent(Date.self, forKey: .savedTime)
        self.updatedTime = try container.decode(Date.self, forKey: .updatedTime)
        self.note = try container.decodeIfPresent(String.self, forKey: .note)
        self.lastBreast = try container.decodeIfPresent(TBNursingModel.Side.self, forKey: .lastBreast)
        self.leftBreast = try container.decode(TBBreastModel.self, forKey: .leftBreast)
        self.rightBreast = try container.decode(TBBreastModel.self, forKey: .rightBreast)
        self.archived = try container.decodeIfPresent(Bool.self, forKey: .archived) ?? false
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let model = object as? TBNursingModel else { return false }
        return startTime.deleteMilliseconds() == model.startTime.deleteMilliseconds() &&
                note == model.note &&
                lastBreast == model.lastBreast &&
                leftBreast.duration == model.leftBreast.duration &&
                leftBreast.isBreasting == model.leftBreast.isBreasting &&
                rightBreast.duration == model.rightBreast.duration &&
                rightBreast.isBreasting == model.rightBreast.isBreasting &&
                archived == model.archived
    }

    func update(by model: TBNursingModel) {
        self.startTime = model.startTime
        self.updatedTime = Date()
        self.savedTime = model.savedTime
        self.note = model.note
        self.lastBreast = model.lastBreast
        self.leftBreast.duration = model.leftBreast.duration
        self.leftBreast.isBreasting = model.leftBreast.isBreasting
        self.rightBreast.duration = model.rightBreast.duration
        self.rightBreast.isBreasting = model.rightBreast.isBreasting
        self.archived = model.archived
    }
}

final class TBBreastModel: NSObject, Codable {
    var duration: Int = 0
    var isBreasting: Bool = false
}
