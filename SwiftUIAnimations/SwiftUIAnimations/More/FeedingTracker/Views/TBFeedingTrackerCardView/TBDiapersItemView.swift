import UIKit

final class TBDiapersItemView: UIView {

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "x0".attributedText(.mulishBody4)
        return label
    }()

    init(diaperName: String) {
        super.init(frame: .zero)
        heightConstraint.constant = 24
        widthConstraint.constant = 46
        [imageView, titleLabel].forEach(addSubview)
        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(8)
            $0.centerY.equalTo(imageView)
        }
        imageView.image = UIImage.imageWithTintColor(named: "Diapers_" + diaperName, color: .Navy)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with title: String) {
        titleLabel.attributedText = title.attributedText(.mulishBody4)
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
