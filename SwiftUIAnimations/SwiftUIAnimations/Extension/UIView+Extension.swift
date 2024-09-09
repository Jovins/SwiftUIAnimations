// MARK: IBInspectable

import UIKit
public extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    var maskedCorners: CACornerMask {
        get {
            return layer.maskedCorners
        }
        set {
            layer.maskedCorners = newValue
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue

        }
    }

    func makeDashBorderLayer(with dashColor: UIColor) {
        let dashBorder = CAShapeLayer()
        dashBorder.lineWidth = 4
        dashBorder.strokeColor = dashColor.cgColor
        dashBorder.lineDashPattern = [5, 6] as [NSNumber]
        dashBorder.frame = bounds
        dashBorder.fillColor = nil
        dashBorder.path = UIBezierPath(roundedRect: bounds, cornerRadius: 8).cgPath
        layer.addSublayer(dashBorder)
    }

    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor(cgColor: layer.borderColor ?? UIColor.clear.cgColor)
        }
        set(newValue) {
            layer.borderColor = newValue.cgColor
        }
    }

    var currentViewController: UIViewController? {
        var nextResponder: UIResponder? = self
        repeat {
            nextResponder = nextResponder?.next
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
        } while nextResponder != nil
        return nil
    }
}

extension UIView {
    func width() -> CGFloat {
        return self.frame.size.width
    }

    func height() -> CGFloat {
        return self.frame.size.height
    }

    // A "safe" call to `safeAreaInsets`
    var safeSafeAreaInsets: UIEdgeInsets {
        if frame == .zero,
            let safeAreaInset = UIApplication.shared.keyWindow?
        .safeAreaInsets {
            return safeAreaInset
        }
        return safeAreaInsets
    }
}

// MARK: Superview Traversing
extension UIView {
    public func superview<T: UIView>(of type: T.Type) -> T? {
        if let view = superview as? T {
            return view
        } else {
            return superview?.superview(of: type)
        }
    }
}

// MARK: Calculate the percentage of characters appearing on the screen
extension UIView {
    public func visibleCharactersCount(_ coverView: UIView, lineHeight: CGFloat, totalCharactersCount: Int) -> Int {
        let editViewframe = convert(bounds, to: coverView)
        let visibleHeight = coverView.safeAreaLayoutGuide.layoutFrame.maxY - editViewframe.origin.y
        let viewHeight = editViewframe.height
        guard visibleHeight > 0, viewHeight > 0, lineHeight > 0 else { return 0 }
        let percentage = visibleHeight / viewHeight
        let totalLineCount = lroundf(Float(viewHeight / lineHeight))
        guard totalLineCount > 0 else { return 0 }
        let visibleLineCount = lroundf(Float(CGFloat(totalLineCount) * percentage))
        let visibleTextCount = (totalCharactersCount / totalLineCount) * visibleLineCount
        return visibleTextCount
    }
}

// MARK: - Check whether it is inview
extension UIView {
    func isHalfInView(_ coverView: UIView, contentInset: UIEdgeInsets = .zero, type: InViewType) -> Bool {
        switch type {
        case .horizontal:
            return isHalfInViewHorizontal(coverView, contentInset: contentInset)
        case .vertical:
            return isHalfInViewVertical(coverView, contentInset: contentInset)
        case .both:
            return isHalfInViewBoth(coverView, contentInset: contentInset)
        }
    }

    private func isHalfInViewHorizontal(_ coverView: UIView, contentInset: UIEdgeInsets) -> Bool {
        guard self.frame.width > 0 else { return false }
        let convertFrame = convert(bounds, to: coverView)
        return convertFrame.midX >= coverView.bounds.minX + contentInset.left
               && convertFrame.midX <= coverView.bounds.maxX - contentInset.right
    }

    private func isHalfInViewVertical(_ coverView: UIView, contentInset: UIEdgeInsets) -> Bool {
        guard self.frame.height > 0 else { return false }
        let convertFrame = convert(bounds, to: coverView)
        return convertFrame.midY >= coverView.bounds.minY + contentInset.top
               && convertFrame.midY <= coverView.bounds.maxY - contentInset.bottom
    }

    private func isHalfInViewBoth(_ coverView: UIView, contentInset: UIEdgeInsets) -> Bool {
        return isHalfInViewHorizontal(coverView, contentInset: contentInset)
               && isHalfInViewVertical(coverView, contentInset: contentInset)
    }

    func isFullInView(_ coverView: UIView, contentInset: UIEdgeInsets = .zero, type: InViewType) -> Bool {
        switch type {
        case .horizontal:
            return isFullInViewHorizontal(coverView, contentInset: contentInset)
        case .vertical:
            return isFullInViewVertical(coverView, contentInset: contentInset)
        case .both:
            return isFullInViewBoth(coverView, contentInset: contentInset)
        }
    }

    private func isFullInViewHorizontal(_ coverView: UIView, contentInset: UIEdgeInsets) -> Bool {
        guard self.frame.width > 0 else { return false }
        let convertFrame = convert(bounds, to: coverView)
        return convertFrame.minX >= coverView.bounds.minX + contentInset.left
               && convertFrame.maxX <= coverView.bounds.maxX - contentInset.right
    }

    private func isFullInViewVertical(_ coverView: UIView, contentInset: UIEdgeInsets) -> Bool {
        guard self.frame.height > 0 else { return false }
        let convertFrame = convert(bounds, to: coverView)
        return convertFrame.minY >= coverView.bounds.minY + contentInset.top
               && convertFrame.maxY <= coverView.bounds.maxY - contentInset.bottom
    }

    private func isFullInViewBoth(_ coverView: UIView, contentInset: UIEdgeInsets) -> Bool {
        return isFullInViewHorizontal(coverView, contentInset: contentInset)
               && isFullInViewVertical(coverView, contentInset: contentInset)
    }

    enum InViewType {
        case horizontal
        case vertical
        case both
    }
}

extension UIView {
    func isFirstInView(_ coverView: UIView, contentInset: UIEdgeInsets = .zero, type: InViewType) -> Bool {
        switch type {
        case .horizontal:
            return isFirstInViewHorizontal(coverView, contentInset: contentInset)
        case .vertical:
            return isFirstInViewVertical(coverView, contentInset: contentInset)
        case .both:
            return isFirstInViewBoth(coverView, contentInset: contentInset)
        }
    }

    private func isFirstInViewHorizontal(_ coverView: UIView, contentInset: UIEdgeInsets) -> Bool {
        guard self.frame.width > 0 else { return false }
        let convertFrame = convert(bounds, to: coverView)
        return convertFrame.minX >= coverView.bounds.minX + contentInset.left
               && convertFrame.minX <= coverView.bounds.maxX - contentInset.right
    }

    private func isFirstInViewVertical(_ coverView: UIView, contentInset: UIEdgeInsets) -> Bool {
        guard self.frame.height > 0 else { return false }
        let convertFrame = convert(bounds, to: coverView)
        return convertFrame.minY >= coverView.bounds.minY + contentInset.top
               && convertFrame.minY <= coverView.bounds.maxY - contentInset.bottom
    }

    private func isFirstInViewBoth(_ coverView: UIView, contentInset: UIEdgeInsets) -> Bool {
        return isFirstInViewHorizontal(coverView, contentInset: contentInset)
               && isFirstInViewVertical(coverView, contentInset: contentInset)
    }
}

extension UIView {
    func move(direction: Direction, length: CGFloat) {
        switch direction {
        case .up:
            center.y -= length
        case .down:
            center.y += length
        case .right:
            center.x += length
        case .left:
            center.x -= length
        }
    }
}

enum Direction {
    case up
    case down
    case right
    case left
}

extension UIView {
    func applyPerkyShadow(_ isApply: Bool = true, alpha: CGFloat = 0.24) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: alpha).cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 1
        layer.shadowRadius = isApply ? 4.0 : 0.0
    }

    func applyGradientMask(frame: CGRect, colors: [CGColor], startPoint: CGPoint, endPoint: CGPoint, locations: [NSNumber]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = frame
        layer.addSublayer(gradientLayer)
        gradientLayer.colors = colors
        gradientLayer.locations = locations
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
    }

    func drawRoundedCorners(corners: UIRectCorner, size: CGSize, radius: CGFloat) {
        let bounds: CGRect = CGRect(origin: .zero, size: size)
        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [corners], cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
}

extension UIView {
    func convertToImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        self.layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
