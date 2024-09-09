import UIKit

protocol TBFeedingTodayRecordCellDelegate: AnyObject {
    func recordCell(_ cell: TBFeedingTodayRecordCell, didTapEdit model: Any)
}

final class TBFeedingTodayRecordCell: UITableViewCell {

    weak var delegate: TBFeedingTodayRecordCellDelegate?
    private let iconBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .Aqua
        view.cornerRadius = 20
        return view
    }()
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let titleAndTimeLabel = UILabel()
    private let detailLabel = UILabel()
    private let totalLabel = UILabel()
    private let notesLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    private let editButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "edit_feeding"), for: .normal)
        button.tb.expandTouchingArea(TBIconList.SizeOption.normal.tapArea)
        return button
    }()
    private let bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = .DarkGray200
        return view
    }()
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleAndTimeLabel, totalLabel, notesLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 4
        return stackView
    }()
    private var model: Any?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        editButton.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
        [iconBackgroundView, stackView, editButton, bottomLine].forEach(contentView.addSubview)
        iconBackgroundView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.size.equalTo(40)
            $0.centerY.equalToSuperview()
        }
        iconBackgroundView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(24)
        }
        stackView.snp.makeConstraints {
            $0.leading.equalTo(iconBackgroundView.snp.trailing).offset(16)
            $0.trailing.equalTo(editButton.snp.leading).offset(-2)
            $0.top.bottom.equalToSuperview().inset(21)
        }
        editButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
            $0.size.equalTo(24)
        }
        bottomLine.snp.makeConstraints {
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
    }

    private func updateLayoutConstraintIfNeed() {
        guard let model else { return }
        switch model {
        case is TBDiapersModel:
            updateDiapersLayoutIfNeed()
        default:
            updateRecordCellLayoutIfNeed()
        }
    }

    private func updateRecordCellLayoutIfNeed() {
        stackView.arrangedSubviews.forEach({ $0.removeFromSuperview()})
        stackView.addArrangedSubview(titleAndTimeLabel)
        stackView.addArrangedSubview(detailLabel)

        if !totalLabel.isHidden {
            stackView.addArrangedSubview(totalLabel)
        }

        if !notesLabel.isHidden {
            stackView.addArrangedSubview(notesLabel)
        }

        stackView.snp.remakeConstraints {
            $0.leading.equalTo(iconBackgroundView.snp.trailing).offset(16)
            $0.trailing.equalTo(editButton.snp.leading).offset(-2)
            $0.top.bottom.equalToSuperview().inset(20)
        }
    }

    private func updateDiapersLayoutIfNeed() {
        guard let diapersModel = model as? TBDiapersModel else { return }
        stackView.arrangedSubviews.forEach({ $0.removeFromSuperview()})
        stackView.addArrangedSubview(titleAndTimeLabel)
        var inset: CGFloat = 31.5
        if !notesLabel.isHidden {
            stackView.addArrangedSubview(notesLabel)
            inset = 21
            let notesWidth: CGFloat = diapersModel.note?.attributedText(.mulishBody4)?.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 17),
                                                                                                     options: .usesLineFragmentOrigin, context: nil).width ?? 0
            if UIScreen.width - 122 < notesWidth {
                inset = 20
            }
        }
        stackView.snp.remakeConstraints {
            $0.leading.equalTo(iconBackgroundView.snp.trailing).offset(16)
            $0.trailing.equalTo(editButton.snp.leading).offset(-2)
            $0.top.bottom.equalToSuperview().inset(inset)
        }
    }

    func setupData(model: Any) {
        self.model = model
        switch model {
        case let model as TBNursingModel:
            setupNursingModel(model: model)
        case let model as TBDiapersModel:
            setupDiapersModel(model: model)
        case let model as TBBottleModel:
            setupBottleModel(model: model)
        case let model as TBPumpModel:
            setupPumpModel(model: model)
        default:
            break
        }
        updateLayoutConstraintIfNeed()
    }

    private func setupNursingModel(model: TBNursingModel?) {
        guard let model else { return }
        iconImageView.image = model.type.iconImage

        let time = model.startTime.convertTohhmma().lowercased() ?? ""
        let titleAndTime = "Nursing - \(time)"
        titleAndTimeLabel.attributedText = titleAndTime.attributedText(.mulishLink4)

        let details: String = TBFeedingTrackerRecordHelper.getNursingDetails(nursingModel: model)
        detailLabel.isHidden = details.isEmpty
        detailLabel.attributedText = details.attributedText(.mulishBody4, foregroundColor: .DarkGray600)

        let totalTimeString = TBFeedingTrackerRecordHelper.getTotalNursingTime(nursingModel: model)
        totalLabel.isHidden = totalTimeString.isEmpty
        totalLabel.attributedText = "Total Time: \(totalTimeString)".attributedText(.mulishBody4, foregroundColor: .DarkGray600)

        let noteString = model.note ?? ""
        notesLabel.isHidden = noteString.isEmpty
        notesLabel.attributedText = noteString.attributedText(.mulishBody4, foregroundColor: .DarkGray600)
    }

    private func setupDiapersModel(model: TBDiapersModel?) {
        guard let model else { return }
        iconImageView.image = model.type.iconImage
        detailLabel.isHidden = true
        if let name = model.diaperName {
            let startTimeString = model.startTime.convertTohhmma().lowercased()
            titleAndTimeLabel.attributedText = "\(name) - \(startTimeString)".attributedText(.mulishLink4)
        }

        let noteString = model.note ?? ""
        notesLabel.isHidden = noteString.isEmpty
        notesLabel.attributedText = noteString.attributedText(.mulishBody4, foregroundColor: .DarkGray600)
    }

    private func setupBottleModel(model: TBBottleModel?) {
        guard let model else { return }
        iconImageView.image = model.type.iconImage
        detailLabel.isHidden = false
        let startTimeString = model.startTime.convertTohhmma().lowercased()
        titleAndTimeLabel.attributedText = "Bottle - \(startTimeString)".attributedText(.mulishLink4)

        let amountString = TBFeedingTrackerRecordHelper.getBottleDetails(bottleModel: model)
        detailLabel.attributedText = amountString.attributedText(.mulishBody4, foregroundColor: .DarkGray600)
        let noteString = model.note ?? ""
        notesLabel.isHidden = noteString.isEmpty
        notesLabel.attributedText = noteString.attributedText(.mulishBody4, foregroundColor: .DarkGray600)
    }

    private func setupPumpModel(model: TBPumpModel?) {
        guard let model else { return }
        iconImageView.image = model.type.iconImage
        detailLabel.isHidden = false
        let startTimeString = model.startTime.convertTohhmma().lowercased()
        titleAndTimeLabel.attributedText = "Pump - \(startTimeString)".attributedText(.mulishLink4)

        let amountString = TBFeedingTrackerRecordHelper.getPumpDetails(pumpModel: model)
        detailLabel.attributedText = amountString.attributedText(.mulishBody4, foregroundColor: .DarkGray600)

        let totalOutputString = TBFeedingTrackerRecordHelper.getTotalPumpOutput(pumpModel: model)
        totalLabel.isHidden = totalOutputString.isEmpty
        totalLabel.attributedText = "Total Output: \(totalOutputString)".attributedText(.mulishBody4, foregroundColor: .DarkGray600)

        let noteString = model.note ?? ""
        notesLabel.isHidden = noteString.isEmpty
        notesLabel.attributedText = noteString.attributedText(.mulishBody4, foregroundColor: .DarkGray600)
    }

    @objc private func didTapEditButton() {
        guard let model else { return }
        delegate?.recordCell(self, didTapEdit: model)
    }
}
