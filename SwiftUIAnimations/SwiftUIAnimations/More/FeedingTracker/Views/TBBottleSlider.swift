import UIKit

final class TBBottleSlider: UISlider {
    var trackLineHeight: CGFloat = 10

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func trackRect(forBounds bound: CGRect) -> CGRect {
      return CGRect(origin: bound.origin, size: CGSize(width: bound.width, height: trackLineHeight))
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let expandedRect = bounds.insetBy(dx: -5, dy: -5)
        return expandedRect.contains(point)
    }
}
