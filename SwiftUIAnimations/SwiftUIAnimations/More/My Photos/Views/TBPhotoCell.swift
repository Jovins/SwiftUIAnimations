import UIKit

final class TBPhotoCell: UICollectionViewCell {

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.borderColor = .Blush
        imageView.borderWidth = 1
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
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func setup(photoModel: TBPhotoModel) {
        guard let urlString = photoModel.variantURLs?.medium,
              let url = URL(string: urlString) else { return }
        imageView.sd_setImage(with: url)
    }

}
