import UIKit

protocol TBPhotoAddPhotoCellDelegate: class {
    func addPhotoCellDidClickAddPhotoButton()
}

final class TBPhotoAddPhotoCell: UICollectionViewCell {
    weak var delegate: TBPhotoAddPhotoCellDelegate?
    private lazy var backgroundButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.lapis100
        button.addTarget(self, action: #selector(addPhotoButtonAction), for: .touchUpInside)
        return button
    }()
    private let layoutGuide: UILayoutGuide = {
        UILayoutGuide()
    }()
    private let addImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "Photo plugs")?.withTintColor(.CornFlower)
        return imageView
    }()
    private let addPhotoLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Add Photo".attributedText(.mulishLink2)
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
        contentView.addSubview(backgroundButton)
        contentView.addLayoutGuide(layoutGuide)
        contentView.addSubview(addImageView)
        contentView.addSubview(addPhotoLabel)
        backgroundButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(UIDevice.width)
        }
        addImageView.snp.makeConstraints { make in
            make.centerX.top.equalTo(layoutGuide)
        }
        addPhotoLabel.snp.makeConstraints { make in
            make.centerX.bottom.equalTo(layoutGuide)
            make.top.equalTo(addImageView.snp.bottom).offset(13)
            make.height.equalTo(24)
        }
        layoutGuide.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    @objc func addPhotoButtonAction() {
        self.delegate?.addPhotoCellDidClickAddPhotoButton()
    }
}
