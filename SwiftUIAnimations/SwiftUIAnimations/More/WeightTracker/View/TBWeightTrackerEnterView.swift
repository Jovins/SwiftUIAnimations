import UIKit
import SnapKit
import RxSwift

final class TBWeightTrackerEnterView: UIView {

    private var type: TBWeightTrackerEnterViewType = .add
    private let unitLabel: UILabel = {
        let title = UserDefaults.standard.isMetricUnit ? "kg." : "lbs."
        let label = UILabel()
        label.attributedText = title.attributedText(.mulishBody2)
        return label
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Add New Weight".attributedText(.mulishTitle4)
        label.isHidden = true
        return label
    }()
    private lazy var weightTextField: TBTextField = {
        let textField = TBTextField()
        textField.hintText = "Weight"
        textField.placeholder = "0"
        textField.leftIconImage = TBIconList.weightTracker.image()
        textField.keyboardType = .decimalPad
        textField.delegate = self
        textField.maskInputContent(true)
        return textField
    }()
    private let dateTextField: TBTextField = {
        let textField = TBTextField()
        textField.hintText = "Date"
        textField.leftIconImage = TBIconList.calendar.image()
        textField.isUserInteractionEnabled = false
        textField.maskInputContent(true)
        return textField
    }()
    private let dateCTA: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        return button
    }()
    private(set) var deleteCTA: UIButton = {
        let button = UIButton()
        button.setAttributedTitle("Delete".attributedText(.mulishLink2, additionalAttrsArray: [("Delete", [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])]), for: .normal)
        button.setAttributedTitle("Delete".attributedText(.mulishLink2, foregroundColor: .DarkGray500, additionalAttrsArray: [("Delete", [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])]), for: .highlighted)
        button.setImage(TBIconList.trash.image(sizeOption: .small, color: .GlobalTextPrimary), for: .normal)
        button.setImage(TBIconList.trash.image(sizeOption: .small, color: .DarkGray500), for: .highlighted)
        button.imageEdgeInsets = UIEdgeInsets(top: 1.5, left: 56, bottom: -1.5, right: -56)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 16)
        button.isHidden = true
        return button
    }()
    private(set) var saveCTA: TBCommonButton = {
        let button = TBCommonButton()
        button.setTitle("Save Weight", for: .normal)
        button.buttonWidth = UIDevice.isPad() ? 335 : UIDevice.width - 40
        button.isEnabled = false
        return button
    }()
    private lazy var pickerView: TBDatePickerView = {
        let view = TBDatePickerView()
        view.mode = .date
        if #available(iOS 13.4, *) {
            view.pickerStyle = .wheels
        }
        view.delegate = self
        if let pregnancyDueDate = TBMemberDataManager.sharedInstance().memberDataObject?.pregnancyDueDate {
            let maximumDate = Date.addWeeks(weekNumber: 2, toDate: pregnancyDueDate)
            view.maximumDate = maximumDate
        }
        return view
    }()
    let medicalDisclaimerCTA: UIButton = {
        let titleAttributedString = "Medical Disclaimer".attributedText(.mulishLink4, foregroundColor: .DarkGray600, additionalAttrsArray: [("Medical Disclaimer", [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])])
        let button = UIButton()
        button.setAttributedTitle(titleAttributedString, for: .normal)
        button.tb.expandTouchingArea(UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        return button
    }()

    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        return dateFormatter
    }()
    private var contentWidth: CGFloat {
        return UIDevice.isPad() ? 335 : UIDevice.width - 40
    }
    private var unitLabelLeadingConstraint: Constraint?
    private let unitLeadingSpace: CGFloat = 42
    private var pickerDate: Date = Date()
    var shouldSaveWeightTracker: Bool {
        guard let weightText = weightTextField.text, let dateText = dateTextField.text else { return false }
        switch type {
        case .add:
            guard !weightText.isEmpty && weightText != "0" else { return false }
            return true
        case .edit:
            guard let model = model else { return false }
            return weightText != model.weightString || dateText != dateFormatter.string(from: model.calendarDate)
        }
    }
    var model: TBWeightTrackerModel? {
        didSet {
            guard let model = model else { return }
            weightTextField.text = model.weightString
            dateTextField.text = dateFormatter.string(from: model.calendarDate)
            pickerDate = model.calendarDate
            updateUnitLabelPosition()
        }
    }
    var saveWeightsSubject = PublishSubject<Bool>()
    var editWeightSubject = PublishSubject<Bool>()
    var deleteWeightSubject = PublishSubject<Bool>()

    init(type: TBWeightTrackerEnterViewType) {
        super.init(frame: .zero)
        self.type = type
        setupUI()
        setupData()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        [titleLabel, weightTextField, unitLabel, dateTextField, dateCTA, deleteCTA, medicalDisclaimerCTA, saveCTA].forEach(addSubview)
        titleLabel.isHidden = type == .add ? false : true
        deleteCTA.isHidden = type == .edit ? false : true
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        weightTextField.snp.makeConstraints {
            $0.top.equalToSuperview().inset(type == .add ? 42 : 0)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(contentWidth)
            $0.height.equalTo(72)
        }
        unitLabel.snp.makeConstraints {
            $0.bottom.equalTo(weightTextField.snp.bottom).offset(-12)
            unitLabelLeadingConstraint = $0.leading.equalTo(weightTextField.snp.leading).offset(unitLeadingSpace).constraint
        }
        dateTextField.snp.makeConstraints {
            $0.top.equalTo(weightTextField.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(contentWidth)
            $0.height.equalTo(72)
        }
        dateCTA.snp.makeConstraints {
            $0.leading.bottom.trailing.equalTo(dateTextField)
            $0.height.equalTo(48)
        }
        deleteCTA.snp.makeConstraints {
            $0.top.equalTo(dateTextField.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(CGSize(width: 80, height: 24))
        }
        medicalDisclaimerCTA.snp.makeConstraints {
            $0.bottom.equalTo(saveCTA.snp.top).offset(-24)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(CGSize(width: 118, height: 18))
        }
        saveCTA.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(36)
            $0.centerX.equalToSuperview()
        }
        dateCTA.addTarget(self, action: #selector(didTapDateCTA), for: .touchUpInside)
        saveCTA.addTarget(self, action: #selector(didTapSaveCTA(sender:)), for: .touchUpInside)
        deleteCTA.addTarget(self, action: #selector(didTapDeleteCTA(sender:)), for: .touchUpInside)
    }

    private func setupData() {
        if type == .add {
            dateTextField.text = dateFormatter.string(from: Date())
            updateUnitLabelPosition()
        }
    }

    private func updateUnitLabelPosition() {
        if let text = weightTextField.text, let attributedText = text.attributedText(.mulishBody2) {
            let width = ceilf(Float(attributedText.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 24),
                                                    options: .usesLineFragmentOrigin, context: nil).width))
            let space = unitLeadingSpace + (width == 0 ? 10 : CGFloat(width))
            unitLabelLeadingConstraint?.update(offset: space)
            if text == "0" || text.isEmpty {
                weightTextField.textColor = .DarkGray600
                saveCTA.isEnabled = false
            }
        }
    }

    @objc private func didTapDateCTA() {
        weightTextField.resignFirstResponder()
        pickerView.date = pickerDate
        dateTextField.textColor = .DarkGray600
        pickerView.show()
    }

    @objc private func didTapSaveCTA(sender: UIButton) {
        let dateString = dateFormatter.string(from: pickerDate)
        if let date = dateFormatter.date(from: dateString) {
            pickerDate = date
        }
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 1
        guard let text = weightTextField.text,
              var weight = numberFormatter.number(from: text)?.doubleValue else { return }
        if !UserDefaults.standard.isMetricUnit {
            weight = weight / TBWeightTrackerModel.kgTolbs
        }
        switch type {
        case .add:
            let weightTrackerModel = TBWeightTrackerModel(id: UUID().uuidString, calendarDate: pickerDate, weight: weight)
            TBWeightTrackerRepository.shared.addWeight(model: weightTrackerModel)
            saveWeightsSubject.onNext(true)
        case .edit:
            guard var model = model else { return }
            let newModel = TBWeightTrackerModel(id: model.id, calendarDate: pickerDate, weight: weight)
            TBWeightTrackerRepository.shared.editWeight(id: model.id, model: newModel)
            editWeightSubject.onNext(true)
        }
        TBAnalyticsManager.trackWeightTrackerInteraction(selection: .saveWeight)
    }

    @objc private func didTapDeleteCTA(sender: UIButton) {
        let alertVC = UIAlertController(title: nil, message: "Are you sure you want to delete your weight data?", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.deleteWeightTracker()
            TBAnalyticsManager.trackWeightTrackerInteraction(selection: .deleteWeight)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertVC.addAction(deleteAction)
        alertVC.addAction(cancelAction)
        if let popoverController = alertVC.popoverPresentationController {
            if let sender = sender as? UIBarButtonItem {
                popoverController.barButtonItem = sender
            } else if let sender = sender as? UIView {
                popoverController.sourceView = sender
                popoverController.sourceRect = sender.bounds
            }
            popoverController.permittedArrowDirections = [.down, .up]
        }
        AppRouter.shared.navigator.present(alertVC)
    }

    private func deleteWeightTracker() {
        guard let model = model else { return }
        TBWeightTrackerRepository.shared.deleteWeight(id: model.id)
        deleteWeightSubject.onNext(true)
    }

    private func checkSaveCTAState() {
        if shouldSaveWeightTracker {
            weightTextField.textColor = .GlobalTextPrimary
            saveCTA.isEnabled = true
        } else {
            weightTextField.textColor = .DarkGray600
            saveCTA.isEnabled = false
        }
    }
}

// MARK: - TBDatePickerViewDelegate
extension TBWeightTrackerEnterView: TBDatePickerViewDelegate {
    func didSelect(view: TBDatePickerView, date: Date) {
        pickerDate = date
        dateTextField.text = dateFormatter.string(from: date)
    }

    func dismiss() {
        dateTextField.textColor = .GlobalTextPrimary
        checkSaveCTAState()
    }
}

// MARK: - UITextFieldDelegate
extension TBWeightTrackerEnterView: TBTextFieldDelegate {

    func textField(_ textField: TBTextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }
        if (text.range(of: ".") != nil && string == ".")
           || (text.range(of: ",") != nil && string == ",") {
            return false
        }
        if text.hasPrefix("0"), string == "0" {
            return false
        }
        if let pointRange = text.range(of: "."),
           range.location - NSRange(pointRange, in: text).location > 1 {
            return false
        }
        if let pointRange = text.range(of: ","),
           range.location - NSRange(pointRange, in: text).location > 1 {
            return false
        }
        return true
    }

    func textFieldDidChangeSelection(_ textField: TBTextField) {
        updateUnitLabelPosition()
    }

    func textFieldDidBeginEditing(_ textField: TBTextField) {
        guard textField == weightTextField else { return }
        weightTextField.textColor = .DarkGray600
    }

    func textFieldDidEndEditing(_ textField: TBTextField) {
        guard textField == weightTextField else { return }
        checkSaveCTAState()
    }

    func textFieldShouldReturn(_ textField: TBTextField) -> Bool {
        return true
    }

    func tapRightButton(_ textField: TBTextField, _ sender: UIButton) {}
}

extension TBWeightTrackerEnterView {

    enum TBWeightTrackerEnterViewType {
        case add
        case edit
    }
}
