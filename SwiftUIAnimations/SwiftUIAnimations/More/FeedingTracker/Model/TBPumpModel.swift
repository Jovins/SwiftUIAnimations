import UIKit

final class TBPumpModel: NSObject, Codable, TBFeedingTrackerModelProtocol {

    let id: String
    var leftAmountModel: TBAmountModel
    var rightAmountModel: TBAmountModel
    var lastSide: TBNursingModel.Side?
    var note: String?
    var startTime: Date
    var savedTime: Date?
    var archived: Bool
    var item: String? { "Pump" }
    var type: FeedingTrackerToolType { .pumping }

    init(startTime: Date) {
        self.id = UUID().uuidString
        self.startTime = startTime
        self.leftAmountModel = TBAmountModel(type: .pump)
        self.rightAmountModel = TBAmountModel(type: .pump)
        self.archived = false
        super.init()
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.leftAmountModel = try container.decode(TBAmountModel.self, forKey: .leftAmountModel)
        self.rightAmountModel = try container.decode(TBAmountModel.self, forKey: .rightAmountModel)
        self.lastSide = try container.decodeIfPresent(TBNursingModel.Side.self, forKey: .lastSide)
        self.note = try container.decodeIfPresent(String.self, forKey: .note)
        self.startTime = try container.decode(Date.self, forKey: .startTime)
        self.savedTime = try container.decodeIfPresent(Date.self, forKey: .savedTime)
        self.archived = try container.decodeIfPresent(Bool.self, forKey: .archived) ?? false
    }

    func update(by model: TBPumpModel) {
        self.leftAmountModel.amount = model.leftAmountModel.amount
        self.rightAmountModel.amount = model.rightAmountModel.amount
        self.lastSide = model.lastSide
        self.note = model.note
        self.startTime = model.startTime
        self.savedTime = model.savedTime
        self.archived = model.archived
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let model = object as? TBPumpModel else { return false }
        return leftAmountModel.amount == model.leftAmountModel.amount &&
        rightAmountModel.amount == model.rightAmountModel.amount &&
        lastSide == model.lastSide &&
        note == model.note &&
        startTime == model.startTime &&
        savedTime == model.savedTime &&
        archived == model.archived
    }
}
