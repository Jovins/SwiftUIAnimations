import Foundation
import UIKit
import SnapKit

final class TBToddlerAlbumHeaderView: UICollectionReusableView {
    private let titleLabel: UILabel = UILabel()
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .DarkGray500
        return view
    }()
    private var topConstraint: Constraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        [titleLabel, lineView].forEach(addSubview)
        titleLabel.snp.makeConstraints {
            topConstraint = $0.top.equalToSuperview().constraint
            $0.leading.equalToSuperview()
            $0.height.equalTo(18)
        }
        lineView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.trailing.equalToSuperview()
            $0.leading.equalTo(titleLabel.snp.trailing).offset(12)
            $0.centerY.equalTo(titleLabel)
        }
    }

    func setup(model: TBPhotosModel?, updateTopConstraint: CGFloat?) {
        guard let year = model?.year else { return }
        let yearString = "Year".pluralize(with: year)
        titleLabel.attributedText = "\(year) \(yearString) Old".attributedText(.mulishBody4)
        if let updateTopConstraint = updateTopConstraint {
            topConstraint?.update(inset: updateTopConstraint)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        topConstraint?.update(inset: 0)
    }
}

final class TBCollectionViewEmptyHeaderFooterView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
