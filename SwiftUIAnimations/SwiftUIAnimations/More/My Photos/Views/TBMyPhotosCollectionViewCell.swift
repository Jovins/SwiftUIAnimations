import Foundation
import UIKit
import FullStory

final class TBMyPhotosCollectionViewCell: UICollectionViewCell {
    private let borderView: UIView = {
        let view = UIView()
        view.borderWidth = 1
        view.borderColor = UIColor.floralwhite200
        return view
    }()
    private let photoImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.borderWidth = 1
        view.borderColor = UIColor.floralwhite200
        view.clipsToBounds = true
        return view
    }()
    private let addImageView: UIImageView = {
        let view = UIImageView(image: TBIconList.plugs.image(sizeOption: .custom(CGSize(width: 36, height: 36)), color: .CornFlower))
        view.contentMode = .scaleToFill
        return view
    }()
    let titleLabel: UILabel = UILabel()
    private let numbersLabel: UILabel = UILabel()
    private let loadingHUD: TBLoadingHUD = {
        let load = TBLoadingHUD()
        load.backgroundColor = .clear
        load.isHidden = true
        return load
    }()
    private let addPhotoLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Add Photo".attributedText(.mulishLink4)
        return label
    }()
    private let containerView: UIView = UIView()
    private var model: TBPhotosModel?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        photoImageView.isHidden = true
        [borderView, photoImageView, containerView, titleLabel, numbersLabel].forEach(contentView.addSubview)
        [addImageView, addPhotoLabel].forEach(containerView.addSubview)
        borderView.snp.makeConstraints {
            $0.size.equalTo(106)
            $0.top.centerX.equalToSuperview()
        }
        photoImageView.snp.makeConstraints {
            $0.size.equalTo(106)
            $0.top.centerX.equalToSuperview()
        }
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
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
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(20)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(borderView.snp.bottom).offset(4)
        }
        numbersLabel.snp.makeConstraints {
            $0.height.equalTo(18)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom)
        }

        FS.mask(views: photoImageView)
    }

    func setup(photoModels: TBPhotosModel?, type: TBMyPhotosRepository.AlbumType) {
        self.model = photoModels
        switch type {
        case .pregnant:
            titleLabel.attributedText = "Week \(photoModels?.week ?? 0)".attributedText(.mulishBody3)
        case .child:
            if photoModels?.week == 0 {
                titleLabel.attributedText = "Newborn".attributedText(.mulishBody3)
            } else {
                titleLabel.attributedText = "Week \(photoModels?.week ?? 0)".attributedText(.mulishBody3)
            }
        case .toddler:
            guard let year = photoModels?.year else { break }
            if year >= 3 {
                titleLabel.attributedText = "\(year) Years Old".attributedText(.mulishBody3)
            } else {
                guard let month = photoModels?.month else { break }
                titleLabel.attributedText = "\(month) Months".attributedText(.mulishBody3)
            }
        }
        let count = photoModels?.photos.count ?? 0
        numbersLabel.attributedText = "\(count) Photo".pluralize(with: count).attributedText(.mulishBody4, foregroundColor: .DarkGray600)
        if let photoModels = photoModels,
           let photo = photoModels.photos.first,
           let urlString = photo.variantURLs?.medium,
           let url = URL(string: urlString) {
            loadingHUD.show(view: photoImageView)
            photoImageView.sd_setImage(with: url, placeholderImage: nil, options: SDWebImageOptions(rawValue: 0)) { [weak self] (_, _, _, _) in
                guard let self = self else { return }
                self.loadingHUD.dismiss()
            }
            photoImageView.isHidden = false
            containerView.isHidden = true
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.isHidden = true
        containerView.isHidden = false
        model = nil
    }
}
