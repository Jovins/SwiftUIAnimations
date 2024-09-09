import UIKit

protocol TBToolsSortCollectionViewCellDelegate: AnyObject {
    func didTapToSortData()
}

final class TBToolsSortCollectionViewCell: UICollectionViewCell {

    private let sortByCTA: UIControl = {
        let button = UIControl()
        return button
    }()
    private let sortByLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Sort by:".attributedText(.mulishLink3, additionalAttrsArray: [("Sort by:", [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])])
        return label
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Most Popular".attributedText(.mulishLink3)
        return label
    }()
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Tools_sorter")
        return imageView
    }()
    weak var delegate: TBToolsSortCollectionViewCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        [sortByCTA, sortByLabel, titleLabel, iconImageView].forEach(contentView.addSubview)
        sortByLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(sortByLabel.snp.trailing).offset(4)
            $0.centerY.equalToSuperview()
        }
        iconImageView.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(4)
            $0.centerY.equalTo(titleLabel)
            $0.size.equalTo(16)
        }
        sortByCTA.snp.makeConstraints {
            $0.leading.equalTo(sortByLabel)
            $0.trailing.equalTo(iconImageView)
            $0.top.bottom.equalToSuperview()
        }
        sortByCTA.addTarget(self, action: #selector(didTapToSort), for: .touchUpInside)
    }

    @objc private func didTapToSort() {
        delegate?.didTapToSortData()
    }

    func setupTitle(title: String) {
        titleLabel.attributedText = title.attributedText(.mulishLink3)
    }
}
