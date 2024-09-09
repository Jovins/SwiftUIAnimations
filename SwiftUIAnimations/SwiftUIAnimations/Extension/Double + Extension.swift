import Foundation

extension Double {

    func keepFractionDigits(digit: Int = 0) -> String {
        return String(format: "%.\(digit)f", self)
    }
}
