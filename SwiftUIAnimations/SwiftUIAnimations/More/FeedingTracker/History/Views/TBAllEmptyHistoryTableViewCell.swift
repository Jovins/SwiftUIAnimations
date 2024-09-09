import UIKit

final class TBAllEmptyHistoryTableViewCell: UITableViewCell {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "No history".attributedText(.mulishBody4, foregroundColor: .DarkGray600)
        return label
    }()
    private let feedingTrackerView: TBFeedingTrackerCardView = {
        let view = TBFeedingTrackerCardView()
        view.isFirstOpen = false
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        [titleLabel, feedingTrackerView].forEach(contentView.addSubview)
        titleLabel.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(17)
        }
        feedingTrackerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(322)
        }
    }

    func setupData() {
        feedingTrackerView.dataSources = TBFeedingTrackerSettingHelper.shared.getSettingModels().filter({ $0.isVisible })
    }
}
