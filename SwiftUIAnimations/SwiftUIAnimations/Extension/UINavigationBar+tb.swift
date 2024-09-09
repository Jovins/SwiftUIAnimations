import UIKit

extension UINavigationBar {

    private var hairlineImageView: UIImageView? {
        return hairlineImageView(in: self)
    }

    private func hairlineImageView(in view: UIView) -> UIImageView? {
        guard let imageView = view as? UIImageView, imageView.bounds.height <= 1.0 else {
            for subview in view.subviews {
                if let imageView = self.hairlineImageView(in: subview) {
                    return imageView
                }
            }
            return nil
        }
        return imageView
    }

    func hideBottomHairline() {
        hairlineImageView?.isHidden = true
    }

    func showBottomHairline() {
        hairlineImageView?.isHidden = false
    }
}
