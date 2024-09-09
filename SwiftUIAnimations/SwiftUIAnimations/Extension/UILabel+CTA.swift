import Foundation

extension UILabel {
    func applyPrimaryCTAStyle () {
        backgroundColor = .Navy
        layer.borderColor = UIColor.Navy.cgColor
        borderWidth = 2.0
    }

    func applySecondaryCTAStyle () {
        backgroundColor = .clear
        layer.borderColor = UIColor.Navy.cgColor
        borderWidth = 2.0
    }
}
