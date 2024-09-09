import UIKit

final class TBManagePhotosAddCollectionViewCell: UICollectionViewCell {

    var isEditState: Bool = false {
        didSet {
            overlayView.backgroundColor = isEditState ? UIColor.DarkGray200.withAlphaComponent(0.5) : UIColor.clear
        }
    }
    private let addImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = TBIconList.plugs.image(sizeOption: .custom(CGSize(width: 36, height: 36)), color: .CornFlower)
        return imageView
    }()
    private let addPhotoLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Add Photo".attributedText(.mulishLink4)
        return label
    }()
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .GlobalBackgroundPrimary
        borderWidth = 1
        borderColor = .floralwhite200
        [addImageView, addPhotoLabel, overlayView].forEach(contentView.addSubview)
        addImageView.snp.makeConstraints {
            $0.size.equalTo(36)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(22)
        }
        addPhotoLabel.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 63, height: 18))
            $0.top.equalTo(addImageView.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }
        overlayView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
