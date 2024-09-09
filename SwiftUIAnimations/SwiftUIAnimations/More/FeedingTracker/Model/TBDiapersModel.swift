import UIKit

final class TBDiapersModel: NSObject, Codable, TBFeedingTrackerModelProtocol {

    let id: String
    var diaperName: String?
    var startTime: Date
    var note: String?
    var savedTime: Date?
    var archived: Bool = false
    var item: String? { diaperName }
    var type: FeedingTrackerToolType { .diapers }

    override init() {
        self.id = UUID().uuidString
        self.startTime = Date()
        super.init()
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.diaperName = try container.decodeIfPresent(String.self, forKey: .diaperName)
        self.startTime = try container.decode(Date.self, forKey: .startTime)
        self.note = try container.decodeIfPresent(String.self, forKey: .note)
        self.savedTime = try container.decodeIfPresent(Date.self, forKey: .savedTime)
        self.archived = try container.decodeIfPresent(Bool.self, forKey: .archived) ?? false
    }

    func update(by model: TBDiapersModel) {
        self.diaperName = model.diaperName
        self.startTime = model.startTime
        self.note = model.note
        self.savedTime = model.savedTime
        self.archived = model.archived
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let model = object as? TBDiapersModel else { return false }
        return diaperName == model.diaperName &&
               startTime.deleteMilliseconds() == model.startTime.deleteMilliseconds() &&
               note == model.note &&
               savedTime == model.savedTime &&
               archived == model.archived
    }
}
