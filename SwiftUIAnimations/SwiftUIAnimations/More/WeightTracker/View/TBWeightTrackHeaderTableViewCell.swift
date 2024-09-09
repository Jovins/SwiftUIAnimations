import UIKit
import SnapKit

class TBWeightTrackHeaderTableViewCell: UITableViewCell {
    private let weightHistoryLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Weight History".attributedText(.mulishTitle4)
        return label
    }()
    private let dateTitleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Date".attributedText(.mulishBody2, foregroundColor: .DarkGray600)
        return label
    }()
    private let weekTitleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Week".attributedText(.mulishBody2, foregroundColor: .DarkGray600, alignment: .center)
        return label
    }()
    private let weightTitleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Weight".attributedText(.mulishBody2, foregroundColor: .DarkGray600, alignment: .center)
        return label
    }()
    private let gainedTitleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Gained".attributedText(.mulishBody2, foregroundColor: .DarkGray600, alignment: .center)
        return label
    }()
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .DarkGray500
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none
        [weightHistoryLabel, dateTitleLabel, weekTitleLabel, weightTitleLabel, gainedTitleLabel, lineView].forEach(contentView.addSubview)
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        contentView.addSubview(stackView)
        [dateTitleLabel, weekTitleLabel, weightTitleLabel, gainedTitleLabel].forEach(stackView.addArrangedSubview)
        stackView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(56)
        }
        weightHistoryLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(16)
            $0.height.equalTo(26)
        }
        dateTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16).constraint.deactivate()
            $0.top.equalTo(weightHistoryLabel.snp.bottom).offset(12)
            $0.size.equalTo(CGSize(width: 82, height: 24))
        }
        weekTitleLabel.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 44, height: 24))
        }
        weightTitleLabel.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 62, height: 24))
        }
        gainedTitleLabel.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 70, height: 24))
        }
        lineView.snp.makeConstraints {
            $0.top.equalTo(dateTitleLabel.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
            $0.bottom.equalToSuperview().inset(8)
        }
    }

    func hideTitle() {
        guard weightHistoryLabel.superview != nil else { return }
        weightHistoryLabel.removeFromSuperview()
        dateTitleLabel.snp.updateConstraints {
            $0.top.equalToSuperview().inset(16).constraint.activate()
            $0.top.equalTo(weightHistoryLabel.snp.bottom).offset(12).constraint.deactivate()
        }
    }
}
