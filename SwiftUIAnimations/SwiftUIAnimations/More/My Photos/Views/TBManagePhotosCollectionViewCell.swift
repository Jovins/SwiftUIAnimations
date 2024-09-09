import UIKit
import FullStory
final class TBManagePhotosCollectionViewCell: UICollectionViewCell {

    var isSelecting: Bool = false {
        didSet {
            checkBox.isSelected = isSelecting
        }
    }

    let photoImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = .DarkGray200
        return view
    }()

    private let checkBox: TBCheckBox = {
        let checkBox = TBCheckBox()
        checkBox.disableType = .normal
        checkBox.isUserInteractionEnabled = false
        checkBox.isHidden = true
        return checkBox
    }()

    private let loadingHUD: TBLoadingHUD = {
        let load = TBLoadingHUD()
        load.backgroundColor = .clear
        load.isHidden = true
        return load
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        checkBox.isSelected = false
    }

    private func setupUI() {
        backgroundColor = .GlobalBackgroundPrimary
        borderWidth = 1
        borderColor = .floralwhite200
        layer.shadowColor = UIColor.black(alpha: 0.15).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 1
        layer.shadowRadius = 0
        [photoImageView, checkBox].forEach(contentView.addSubview)
        photoImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        checkBox.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview().inset(4)
            $0.size.equalTo(24)
        }

        FS.mask(views: photoImageView)
    }

    func setupPhoto(photo: TBPhotoModel, isEditState: Bool) {
        checkBox.isHidden = !isEditState
        loadingHUD.show(view: contentView)
        if let urlString = photo.variantURLs?.medium,
           let url = URL(string: urlString) {
            photoImageView.sd_setImage(with: url, placeholderImage: nil, options: SDWebImageOptions(rawValue: 0)) { [weak self] (_, error, _, _) in
                guard let self = self else { return }
                self.loadingHUD.dismiss()
                if error == nil {
                    self.layer.shadowRadius = 2
                }
            }
        }
    }
}
