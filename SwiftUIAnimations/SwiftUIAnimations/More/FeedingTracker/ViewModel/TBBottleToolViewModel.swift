import Foundation

final class TBBottleToolViewModel: NSObject {

    var maxValue: Float {
        if UserDefaults.standard.isMetricUnit {
            return editModel.amountModel.type.maxML
        } else {
            return editModel.amountModel.type.maxOZ
        }
    }
    var slideSpacing: Double {
        if UserDefaults.standard.isMetricUnit {
            return editModel.amountModel.type.spacingML
        } else {
            return editModel.amountModel.type.spacingOZ
        }
    }
    var defaultModel: TBBottleModel? {
        didSet {
            guard let defaultModel else { return }
            editModel.update(by: defaultModel)
        }
    }
    var editModel: TBBottleModel

    override init() {
        editModel = TBBottleModel(startTime: Date())
        super.init()
    }
}
