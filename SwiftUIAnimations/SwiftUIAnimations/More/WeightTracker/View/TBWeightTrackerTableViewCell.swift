import UIKit
import SnapKit

protocol TBWeightTrackerTableViewCellDelegate: AnyObject {
    func editAction(model: TBWeightTrackerModel)
    func unarchiveAction(model: TBWeightTrackerModel)
}

extension TBWeightTrackerTableViewCellDelegate {
    func unarchiveAction(model: TBWeightTrackerModel) {}
}

final class TBWeightTrackerTableViewCell: UITableViewCell {
    let containerView: UIView = UIView()
    private let dateLabel: UILabel = UILabel()
    private let weekLabel: UILabel = UILabel()
    private let weightLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        return label
    }()
    private let gainedLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        return label
    }()
    private let editButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(TBIconList.edit.image(sizeOption: .small), for: .normal)
        button.tb.expandTouchingArea(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        return button
    }()
    private let unarchiveButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "tray.and.arrow.up"), for: .normal)
        button.tb.expandTouchingArea(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        return button
    }()
    private var model: TBWeightTrackerModel?
    weak var delegate: TBWeightTrackerTableViewCellDelegate?

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
        [dateLabel, weekLabel, weightLabel, gainedLabel, editButton, unarchiveButton].forEach(containerView.addSubview)
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        containerView.addSubview(stackView)
        [dateLabel, weekLabel, weightLabel, gainedLabel].forEach(stackView.addArrangedSubview)
        containerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(56)
        }
        stackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(4)
            $0.trailing.equalToSuperview().inset(36)
        }
        dateLabel.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 78, height: 24))
        }
        weekLabel.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 44, height: 24))
        }
        weightLabel.snp.makeConstraints {
            $0.width.equalTo(62)
        }
        gainedLabel.snp.makeConstraints {
            $0.width.equalTo(70)
        }
        editButton.snp.makeConstraints {
            $0.centerY.equalTo(dateLabel)
            $0.size.equalTo(16)
            $0.leading.equalTo(gainedLabel.snp.trailing).offset(8)
        }
        unarchiveButton.snp.makeConstraints {
            $0.edges.equalTo(editButton)
        }
        editButton.addTarget(self, action: #selector(editAction(sender:)), for: .touchUpInside)
        unarchiveButton.addTarget(self, action: #selector(didTapUnarchiveAction(sender:)), for: .touchUpInside)
    }

    func setup(model: TBWeightTrackerModel, previousModel: TBWeightTrackerModel?, showArchiveData: Bool = false) {
        self.model = model
        dateLabel.attributedText = model.calendarDate.convertToMMDDYY().attributedText(.mulishBody2)
        weekLabel.attributedText = "\(Int(model.week))".attributedText(.mulishBody2, alignment: .center)
        weightLabel.attributedText = "\(model.weightString) \(model.unitType)".attributedText(.mulishBody2, alignment: .center)
        if let previousModel = previousModel {
            let diff = model.weight - previousModel.weight
            let numberFormatter = NumberFormatter()
            numberFormatter.maximumFractionDigits = 1
            var diffString = numberFormatter.string(from: fabs(diff) as NSNumber) ?? fabs(diff).keepFractionDigits(digit: 1)
            diffString = diff >= 0 ? "+ \(diffString)" : "- \(diffString)"
            gainedLabel.attributedText = "\(diffString) \(model.unitType)".attributedText(.mulishBody2, alignment: .center)
        } else {
            gainedLabel.attributedText = "---".attributedText(.mulishBody2, alignment: .center)
        }
        editButton.isHidden = showArchiveData
        if showArchiveData {
            unarchiveButton.isHidden = !model.archived
        } else {
            unarchiveButton.isHidden = true
        }
    }

    @objc private func editAction(sender: UIButton) {
        guard let delegate = delegate,
              let model = model else {
            return
        }
        delegate.editAction(model: model)
    }

    @objc private func didTapUnarchiveAction(sender: UIButton) {
        guard let delegate = delegate,
              let model = model else {
            return
        }
        model.archived = false
        delegate.unarchiveAction(model: model)
    }
}
