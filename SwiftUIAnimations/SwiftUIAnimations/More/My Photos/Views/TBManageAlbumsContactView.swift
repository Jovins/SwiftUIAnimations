import UIKit

final class TBManageAlbumsContactView: UIView {

    static let contactUsHeight: CGFloat = UIDevice.isPad() ? 128 : 64
    var showShadow: Bool = false {
        didSet {
            guard showShadow != oldValue else { return }
            layer.shadowColor = showShadow ? UIColor.rgb155_155_155.withAlphaComponent(0.25).cgColor : UIColor.clear.cgColor
        }
    }
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Some of your photos are not showing?".attributedText(.mulishBody3, alignment: .center)
        return label
    }()

    private let contactCTA: UIButton = {
        let button = UIButton()
        button.setAttributedTitle("Contact Us".attributedText(.mulishLink3, additionalAttrsArray: [("Contact Us", [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])]), for: .normal)
        button.backgroundColor = .clear
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .Beige
        layer.shadowColor = UIColor.clear.cgColor
        layer.shadowOffset = CGSize(width: 0, height: -2)
        layer.shadowOpacity = 1
        layer.shadowRadius = 6
        heightConstraint.constant = TBManageAlbumsContactView.contactUsHeight
        widthConstraint.constant = UIScreen.width
        [titleLabel, contactCTA].forEach(addSubview)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(UIDevice.isPad() ? 40 : 8)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        contactCTA.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp_bottom).offset(8)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(CGSize(width: 80, height: 20))
        }
        contactCTA.addTarget(self, action: #selector(didTapContactAction), for: .touchUpInside)
    }

    @objc private func didTapContactAction() {
        AppRouter.shared.navigator.push("thebump://contact-support")
    }

    private lazy var heightConstraint: NSLayoutConstraint = {
        let heightConstraint = heightAnchor.constraint(equalToConstant: 0)
        heightConstraint.isActive = true
        return heightConstraint
    }()

    private lazy var widthConstraint: NSLayoutConstraint = {
        let widthConstraint = widthAnchor.constraint(equalToConstant: 0)
        widthConstraint.isActive = true
        return widthConstraint
    }()
}
