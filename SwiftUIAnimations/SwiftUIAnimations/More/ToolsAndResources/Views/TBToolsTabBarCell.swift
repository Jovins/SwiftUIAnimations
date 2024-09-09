import UIKit

final class TBToolsTabBarCell: UICollectionViewCell {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        return label
    }()
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .Navy
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
        backgroundColor = .Beige
        [titleLabel, indicatorView].forEach(contentView.addSubview)
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        indicatorView.snp.makeConstraints {
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(2)
        }
    }

    func setup(title: String, selected: Bool) {
        indicatorView.isHidden = !selected
        titleLabel.attributedText = title.attributedText(.mulishLink4, alignment: .center)
    }
}
