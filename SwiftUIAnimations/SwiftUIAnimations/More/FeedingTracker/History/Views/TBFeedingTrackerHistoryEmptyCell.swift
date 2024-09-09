import UIKit

final class TBFeedingTrackerHistoryEmptyCell: UITableViewCell {

    private let titleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(12)
        }
        titleLabel.attributedText = "No history".attributedText(.mulishBody4, foregroundColor: .DarkGray600)
    }
}
