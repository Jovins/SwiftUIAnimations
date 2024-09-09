import UIKit

final class TBPhotoDownloadFailHeaderView: UICollectionReusableView {

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = TBIconList.caution.image(color: .validationRed)
        return imageView
    }()
    private let tipsLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "The following photos could not be downloaded".attributedText(.mulishLink2, foregroundColor: .validationRed)
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        [iconImageView, tipsLabel].forEach(addSubview)
        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.size.equalTo(CGSize(width: 24, height: 24))
            $0.top.equalTo(tipsLabel).offset(2)
        }
        tipsLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(4)
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }

}
