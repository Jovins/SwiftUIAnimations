import Foundation

private var tapAreaKey: UIEdgeInsets = .zero

extension NamespaceWrapper where T: UIButton {
    func expandTouchingArea(_ tapArea: UIEdgeInsets) {
        objc_setAssociatedObject(wrappedValue, &tapAreaKey, tapArea, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

extension UIButton {
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let area = objc_getAssociatedObject(self, &tapAreaKey) as? UIEdgeInsets ?? .zero

        let expandRect = CGRect.init(x: bounds.minX - area.left, y: bounds.minY - area.top, width: bounds.width + area.left + area.right, height: bounds.height + area.top + area.bottom)

        if expandRect.equalTo(bounds) {
            return super.point(inside: point, with: event)
        } else {
            return expandRect.contains(point)
        }
    }
}
