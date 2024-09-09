extension UISegmentedControl {
    @objc public func setDefaultStyle(textFont: UIFont) {
        tintColor = UIColor.GlobalTextPrimary
        self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.GlobalTextPrimary as Any, NSAttributedString.Key.font: textFont as Any], for: .normal)
        self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.GlobalTextSecondary, NSAttributedString.Key.font: textFont as Any], for: .selected)
        layer.cornerRadius = 2
        layer.masksToBounds = true
        let normalTintColorImage = UIImage(solidColor: UIColor.GlobalTextSecondary, size: CGSize.init(width: 27.0, height: 27.0))
        let selectTintColorImage = UIImage(solidColor: UIColor.GlobalTextPrimary, size: CGSize.init(width: 27.0, height: 27.0))
        self.setBackgroundImage(normalTintColorImage, for: .normal, barMetrics: .default)
        self.setBackgroundImage(selectTintColorImage, for: .selected, barMetrics: .default)
        layer.borderColor = UIColor.GlobalTextPrimary.cgColor
        layer.borderWidth = 1
    }
}
