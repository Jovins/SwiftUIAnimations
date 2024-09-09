import UIKit

final class TBAmountModel: NSObject, Codable {

    let type: TBAmountType
    private var _amount: CGFloat
    var amount: CGFloat {
        get {
            getAmount()
        }
        set {
            setAmount(amount: newValue)
        }
    }

    init(type: TBAmountType) {
        self.type = type
        self._amount = 0
        super.init()
    }

    private func setAmount(amount: CGFloat) {
        if UserDefaults.standard.isMetricUnit {
            _amount = amount
        } else {
            _amount = CGFloat((Float(amount) / type.maxOZ) * type.maxML)
        }
    }

    private func getAmount() -> CGFloat {
        if UserDefaults.standard.isMetricUnit {
            return roundToNearestHalf(number: _amount, spacing: type.spacingML)
        } else {
            let value = CGFloat((Float(_amount) / type.maxML) * type.maxOZ)
            return roundToNearestHalf(number: value, spacing: type.spacingOZ)
        }
    }

    private func roundToNearestHalf(number: Double, spacing: Double) -> Double {
        let roundedValue = round(number / spacing) * spacing
        return roundedValue
    }
}

extension TBAmountModel {
    enum TBAmountType: Codable {
        case bottle
        case pump

        var maxOZ: Float {
            switch self {
            case .bottle:
                return 12
            case .pump:
                return 12
            }
        }

        var maxML: Float {
            switch self {
            case .bottle:
                return 350
            case .pump:
                return 360
            }
        }

        var spacingOZ: Double {
            return 0.5
        }

        var spacingML: Double {
            return 10
        }
    }
}
