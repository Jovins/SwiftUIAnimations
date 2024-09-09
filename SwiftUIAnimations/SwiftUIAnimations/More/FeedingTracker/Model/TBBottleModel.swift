import UIKit

final class TBBottleModel: NSObject, Codable, TBFeedingTrackerModelProtocol {

    let id: String
    var amountModel: TBAmountModel
    var startTime: Date
    var note: String?
    var savedTime: Date?
    var milkType: MilkType?
    var archived: Bool = false
    var item: String? { "Bottle" }
    var type: FeedingTrackerToolType { .bottle }

    init(startTime: Date) {
        self.id = UUID().uuidString
        self.amountModel = TBAmountModel(type: .bottle)
        self.startTime = startTime
        super.init()
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.amountModel = try container.decode(TBAmountModel.self, forKey: .amountModel)
        self.startTime = try container.decode(Date.self, forKey: .startTime)
        self.note = try container.decodeIfPresent(String.self, forKey: .note)
        self.milkType = try container.decodeIfPresent(MilkType.self, forKey: .milkType)
        self.archived = try container.decodeIfPresent(Bool.self, forKey: .archived) ?? false
    }

    func update(by model: TBBottleModel) {
        self.amountModel.amount = model.amountModel.amount
        self.startTime = model.startTime
        self.note = model.note
        self.savedTime = model.savedTime
        self.milkType = model.milkType
        self.archived = model.archived
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let model = object as? TBBottleModel else { return false }
        return amountModel.amount == model.amountModel.amount &&
        startTime.deleteMilliseconds() == model.startTime.deleteMilliseconds() &&
        note == model.note &&
        milkType == model.milkType &&
        savedTime == model.savedTime &&
        archived == model.archived
    }
}

extension TBBottleModel {
    enum MilkType: Codable {
        case breast
        case formula

        var title: String {
            switch self {
            case .breast:
                return "Breast"
            case .formula:
                return "Formula"
            }
        }
    }
}
