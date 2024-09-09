import UIKit
import SnapKit

final class TBDiapersButtton: TBFeedingBaseButton {

    var type: TBDiapersButttonType = .Pee {
        didSet {
            updateAppearanceIfNeed()
            updateConstraintIfNeed()
        }
    }

    override var isSelected: Bool {
        didSet {
            updateAppearanceIfNeed()
        }
    }

    override var isHighlighted: Bool {
        didSet {
            updateAppearanceIfNeed()
        }
    }

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let diaperLabel: UILabel = UILabel()
    private let layoutGuide = UILayoutGuide()
    private var iconImageViewWidthConstraint: Constraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        cornerRadius = 58.5
        addLayoutGuide(layoutGuide)
        [iconImageView, diaperLabel].forEach(addSubview)
        layoutGuide.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        iconImageView.snp.makeConstraints {
            $0.top.equalTo(layoutGuide)
            $0.centerX.equalTo(layoutGuide)
            iconImageViewWidthConstraint = $0.width.equalTo(24).constraint
            $0.height.equalTo(24)
        }
        diaperLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(8)
            $0.bottom.equalTo(layoutGuide)
            $0.centerX.equalTo(layoutGuide)
        }
    }

    private func updateAppearanceIfNeed() {
        if isHighlighted {
            setBackgroundImage(UIImage(named: "breastFeeding_button_selected"), for: .normal)
            diaperLabel.attributedText = type.rawValue.attributedText(.mulishLink2, foregroundColor: .OffWhite)
            iconImageView.image = UIImage.imageWithTintColor(named: "Diapers_" + type.rawValue, color: .OffWhite)
        } else {
            setBackgroundImage(UIImage(named: "breastFeeding_button_deselected"), for: .normal)
            diaperLabel.attributedText = type.rawValue.attributedText(.mulishLink2, foregroundColor: isSelected ? .OffWhite : .Navy)
            iconImageView.image = UIImage.imageWithTintColor(named: "Diapers_" + type.rawValue, color: isSelected ? .OffWhite : .Navy)
        }
    }

    private func updateConstraintIfNeed() {
        iconImageViewWidthConstraint?.update(offset: type == .Mixed ? 32 : 24)
    }
}

extension TBDiapersButtton {
    enum TBDiapersButttonType: String {
        case Pee
        case Poo
        case Mixed
        case Dry
    }
}
