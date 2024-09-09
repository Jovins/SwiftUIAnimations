import UIKit

final class TBToolsResourcePageSectionHeader: UICollectionReusableView {
    private let titleLabel: UILabel = UILabel()
    private let cutoffLine: UIView = {
        let view = UIView()
        view.backgroundColor = .DarkGray300
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
        [titleLabel, cutoffLine].forEach(addSubview)
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalToSuperview()
        }
        cutoffLine.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.height.equalTo(1)
        }
    }

    func setTitle(_ title: String) {
        titleLabel.attributedText = title.attributedText(.mulishBody3, foregroundColor: .GlobalTextPrimary)
    }
}
