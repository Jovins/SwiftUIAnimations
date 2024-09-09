import UIKit
import SnapKit

final class TBFeedingToolbarIconCell: UICollectionViewCell {

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private let titleLabel: UILabel = UILabel()
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .Navy
        view.isHidden = true
        return view
    }()
    private var indicatorViewWidthConstraint: Constraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        [iconImageView, titleLabel, indicatorView].forEach(contentView.addSubview)
        iconImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(10)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(24)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        indicatorView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.height.equalTo(2)
            indicatorViewWidthConstraint = $0.width.equalTo(0).constraint
        }
    }

    func setup(item: TBFeedingToolbarItem, selected: Bool) {
        iconImageView.image = item.iconImage
        titleLabel.attributedText = item.title.attributedText(.mulishBody3)
        indicatorView.isHidden = !selected
        indicatorViewWidthConstraint?.update(offset: item.size.width + 8)
    }
}
