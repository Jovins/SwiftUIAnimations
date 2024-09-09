import UIKit

final class TBToolsCollectionViewCell: UICollectionViewCell {
    private let iconImageView: UIImageView = UIImageView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        return label
    }()
    private var toolWidth = 70
    private var model: TBToolsModel?
    private var titlePadding = 4

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        [iconImageView, titleLabel].forEach(contentView.addSubview)
        iconImageView.snp.makeConstraints {
            $0.size.equalTo(toolWidth)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview()
        }
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(iconImageView)
            $0.top.equalTo(iconImageView.snp.bottom).offset(titlePadding)
            $0.bottom.lessThanOrEqualToSuperview()
        }
    }

    func setup(model: TBToolsModel, color: UIColor) {
        self.model = model
        if let title = TBToolsDataManager.ToolsModelType(rawValue: model.type)?.title {
            titleLabel.attributedText = title.attributedText(.mulishLink4, alignment: .center)
        }

        if let url = URL(string: model.icon) {
            iconImageView.sd_setImage(with: url) {[weak self] image, _, _, _ in
                guard let self else { return }
                self.iconImageView.image = image?.withRenderingMode(.alwaysTemplate)
            }
            iconImageView.tintColor = color
        }
    }
}
