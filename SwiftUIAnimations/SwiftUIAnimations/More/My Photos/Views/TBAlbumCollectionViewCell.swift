import UIKit
import FullStory

final class TBAlbumCollectionViewCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let photoCountLabel = UILabel()

    private let coverPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.borderWidth = 1
        imageView.borderColor = .Beige
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        [coverPhotoImageView, titleLabel,
         photoCountLabel].forEach(contentView.addSubview)
        FS.mask(views: coverPhotoImageView)

        coverPhotoImageView.snp.makeConstraints {
            $0.size.equalTo(106)
            $0.top.centerX.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(coverPhotoImageView.snp.bottom).offset(4)
            make.leading.trailing.equalTo(coverPhotoImageView)
        }

        photoCountLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.trailing.equalTo(coverPhotoImageView)
        }
    }

    func setup(_ title: String, photoCount: Int, coverPhoto: UIImage?) {
        photoCountLabel.attributedText = "\(photoCount) \("Photo".pluralize(with: photoCount))"
            .attributedText(.mulishBody4, foregroundColor: .DarkGray500, alignment: .center)
        titleLabel.attributedText = title.attributedText(.mulishLink3, foregroundColor: .DarkGray600, alignment: .center)
        coverPhotoImageView.image = coverPhoto
    }
}
