import Foundation

private var actionKey: Int8 = 0

extension UIView: NamespaceWrappable {}
extension NamespaceWrapper where T: UIView {
    func addTapGestureRecognizer(action: (() -> Void)?) {
        wrappedValue.tapAction = action
        wrappedValue.isUserInteractionEnabled = true
        let selector = #selector(wrappedValue.handleTap)
        let recognizer = UITapGestureRecognizer(target: wrappedValue, action: selector)
        wrappedValue.addGestureRecognizer(recognizer)
    }

    func addRoundedCorners(byRoundingCorners corners: UIRectCorner, cornerRadii: CGSize) {
        let line = UIBezierPath(roundedRect: wrappedValue.bounds, byRoundingCorners: corners, cornerRadii: cornerRadii)
        let layer = CAShapeLayer()
        layer.path = line.cgPath
        wrappedValue.layer.mask = layer
    }
}

extension UIView {
    typealias Action = (() -> Void)

    var tapAction: Action? {
        get {
            return objc_getAssociatedObject(self, &actionKey) as? Action
        }
        set {
            guard let value = newValue else { return }
            objc_setAssociatedObject(self, &actionKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

    @objc func handleTap(sender: UITapGestureRecognizer) {
        tapAction?()
    }
}
