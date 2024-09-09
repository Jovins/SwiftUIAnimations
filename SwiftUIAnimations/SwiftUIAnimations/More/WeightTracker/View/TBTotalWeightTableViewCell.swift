import UIKit
import SnapKit

final class TBTotalWeightTableViewCell: UITableViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .Magenta
        view.cornerRadius = 4
        return view
    }()
    private let titleLabel: UILabel = UILabel()
    private let totalWeightLabel: UILabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none
        contentView.addSubview(containerView)
        [titleLabel, totalWeightLabel].forEach(containerView.addSubview)
        containerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.bottom.equalToSuperview().inset(22)
            $0.height.equalTo(72)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(24)
        }
        totalWeightLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.height.equalTo(24)
            $0.centerX.equalToSuperview()
        }
    }

    func setup(firstModel: TBWeightTrackerModel, lastModel: TBWeightTrackerModel?) {
        if let lastModel = lastModel,
           lastModel.id != firstModel.id {
            let diff = firstModel.weight - lastModel.weight
            let numberFormatter = NumberFormatter()
            numberFormatter.maximumFractionDigits = 1
            var diffString = numberFormatter.string(from: fabs(diff) as NSNumber) ?? fabs(diff).keepFractionDigits(digit: 1)
            diffString = diff >= 0 ? "+ \(diffString)" : "- \(diffString)"
            titleLabel.attributedText = "Total Weight Gain".attributedText(.mulishBody2, foregroundColor: .GlobalTextSecondary, alignment: .center)
            totalWeightLabel.attributedText = "\(diffString) \(firstModel.unitType)".attributedText(.mulishLink2, foregroundColor: .GlobalTextSecondary)
        } else {
            titleLabel.attributedText = "Current Weight".attributedText(.mulishBody2, foregroundColor: .GlobalTextSecondary, alignment: .center)
            totalWeightLabel.attributedText = "\(firstModel.weightString) \(firstModel.unitType)".attributedText(.mulishLink2, foregroundColor: .GlobalTextSecondary)
        }
    }
}
