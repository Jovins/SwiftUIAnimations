import UIKit
import FullStory

final class TBPhotoBrowserPhotoCell: UICollectionViewCell {
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        FS.mask(views: imageView)
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    private func setupUI() {
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupCell(urlString: String) {
        imageView.sd_setImage(with: URL(string: urlString), placeholderImage: nil, options: .retryFailed)
    }
}
