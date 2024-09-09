import UIKit

final class TBFeedingTrackerHistoryHeaderView: UITableViewHeaderFooterView {

    private let titleLabel: UILabel = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    private func setupUI() {
        contentView.backgroundColor = .Blush
        [titleLabel].forEach(contentView.addSubview)
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupTitle(title: String?) {
        titleLabel.attributedText = title?.attributedText(.mulishLink4)
    }
}
