import UIKit

protocol TBFeedingTrackerRecordHeaderViewDelegate: AnyObject {
    func didTapViewHistory()
}

final class TBFeedingTrackerRecordHeaderView: UITableViewHeaderFooterView {

    weak var delegate: TBFeedingTrackerRecordHeaderViewDelegate?
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Today".attributedText(.mulishLink4)
        return label
    }()
    private let viewHistoryLabel: UILabel = UILabel()
    private let viewHistoryIcon: UIImageView = UIImageView(image: TBIconList.caretRight.image(sizeOption: .small))
    private let viewHistoryControl: UIControl = UIControl()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.backgroundColor = .Blush
        [titleLabel, viewHistoryLabel, viewHistoryIcon, viewHistoryControl].forEach(contentView.addSubview)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
        viewHistoryLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(viewHistoryIcon.snp.leading).offset(-4)
        }
        viewHistoryIcon.snp.makeConstraints {
            $0.size.equalTo(16)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
        }
        viewHistoryControl.snp.makeConstraints {
            $0.leading.top.bottom.equalTo(viewHistoryLabel)
            $0.trailing.equalTo(viewHistoryIcon)
        }
        viewHistoryControl.addTarget(self, action: #selector(didTapViewHistory(sender:)), for: .touchUpInside)
    }

    @objc private func didTapViewHistory(sender: UIControl) {
        delegate?.didTapViewHistory()
    }

    func setup(title: String, displayViewHistory: Bool) {
        viewHistoryLabel.attributedText = title.attributedText(.mulishLink4, additionalAttrsArray: [(title, [.underlineStyle: NSUnderlineStyle.single.rawValue])])
        [viewHistoryIcon, viewHistoryLabel, viewHistoryControl].forEach({$0.isHidden = !displayViewHistory})
    }
}
