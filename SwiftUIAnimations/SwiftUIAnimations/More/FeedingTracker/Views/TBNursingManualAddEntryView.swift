import UIKit
import RxSwift

class TBNursingManualAddEntryView: UIView {

    private weak var viewController: UIViewController?
    let viewModel = TBNursingManualAddEntryViewModel()
    private let disposeBag = DisposeBag()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        return label
    }()
    private let leftCTA = TBFeedingTrackerEditButton(side: .left)
    private let rightCTA = TBFeedingTrackerEditButton(side: .right)
    private let startTimeView: TBTextField = {
        let textField = TBTextField()
        textField.isUserInteractionEnabled = false
        textField.hinTextFontType = .mulishLink3
        textField.hintText = "Start Time"
        textField.rightButtonSetImage(image: UIImage.calendar(color: .Magenta), backgroundColor: .DarkGray200, for: .normal)
        return textField
    }()
    private let startTimeControl = UIControl()
    private let lastBreastView: TBTextField = {
        let textField = TBTextField()
        textField.isUserInteractionEnabled = false
        textField.hinTextFontType = .mulishLink3
        textField.hintText = "Last Breast"
        textField.placeholder = "Choose last breast"
        return textField
    }()
    private let lastBreastControl = UIControl()
    private(set) lazy var addNoteView: TBAddNoteTextView = {
        let view = TBAddNoteTextView()
        view.titleLabelText = "Add Note"
        return view
    }()
    private(set) var deleteCTA: UIButton = {
        let button = UIButton()
        button.setAttributedTitle("Delete".attributedText(.mulishLink2), for: .normal)
        button.setAttributedTitle("Delete".attributedText(.mulishLink2, foregroundColor: .DarkGray500), for: .highlighted)
        button.setImage(TBIconList.trash.image(sizeOption: .small, color: .GlobalTextPrimary), for: .normal)
        button.setImage(TBIconList.trash.image(sizeOption: .small, color: .DarkGray500), for: .highlighted)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        button.tb.expandTouchingArea(TBIconList.SizeOption.normal.tapArea)
        return button
    }()
    private lazy var startTimePickerView: TBDatePickerView = {
        let picker = TBDatePickerView()
        if #available(iOS 13.4, *) {
            picker.pickerStyle = .wheels
        }
        picker.maximumDate = Date()
        picker.pickerViewHeight = 248
        picker.mode = .dateAndTime
        picker.delegate = self
        return picker
    }()
    private lazy var leftDurationAdapter = TBFeedingDurationPickerAdapter()
    private lazy var rightDurationAdapter = TBFeedingDurationPickerAdapter()
    private lazy var feedDurationPickerView: TBOldPickerView = {
        let pickerView = TBOldPickerView()
        pickerView.pickerViewHeight = 212
        pickerView.autoSelectLastRow = false
        pickerView.assistantView.donebutton.setAttributedTitle("Done".attributedText(.mulishLink3, foregroundColor: .Navy), for: .normal)
        pickerView.delegate = self
        return pickerView
    }()
    private lazy var lastBreastPickerView: TBOldPickerView = {
        let adapter = TBFeedingLastBreastPickerAdapter()
        let pickerView = TBOldPickerView()
        pickerView.adapter = adapter
        pickerView.pickerViewHeight = 172
        pickerView.assistantView.donebutton.setAttributedTitle("Done".attributedText(.mulishLink3, foregroundColor: .Navy), for: .normal)
        pickerView.delegate = self
        return pickerView
    }()

    init(viewController: UIViewController, type: TBNursingManualAddEntryControllerViewModel.OperationType) {
        super.init(frame: .zero)
        self.backgroundColor = .GlobalBackgroundPrimary
        self.viewController = viewController
        viewModel.operationType = type
        viewModel.editModel.startTime = Date()
        bindData()
        setupUI()
        updateUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing()
    }

    func endEditing() {
        endEditing(true)
    }

    private func bindData() {
        viewModel.updateSubject.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.updateUI()
        }).disposed(by: disposeBag)
    }

    private func setupUI() {
        titleLabel.attributedText = viewModel.title
        [titleLabel, leftCTA, rightCTA, startTimeView, startTimeControl, lastBreastView, lastBreastControl, addNoteView].forEach(addSubview)
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(20)
            $0.height.equalTo(54)
        }
        leftCTA.snp.makeConstraints {
            $0.right.equalTo(self.snp.centerX).offset(-24)
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.size.equalTo(CGSize(width: 126, height: 126))
        }
        rightCTA.snp.makeConstraints {
            $0.left.equalTo(self.snp.centerX).offset(24)
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.size.equalTo(CGSize(width: 126, height: 126))
        }
        startTimeView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(leftCTA.snp.bottom).offset(36)
        }
        startTimeControl.snp.makeConstraints {
            $0.edges.equalTo(startTimeView)
        }
        lastBreastView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(startTimeView.snp.bottom).offset(20)
        }
        lastBreastControl.snp.makeConstraints {
            $0.edges.equalTo(lastBreastView)
        }
        addNoteView.snp.makeConstraints {
            $0.top.equalTo(lastBreastView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        switch viewModel.operationType {
        case .add:
            setupAddConstraint()
        case .edit:
            addSubview(deleteCTA)
            deleteCTA.snp.makeConstraints {
                $0.top.equalTo(addNoteView.snp.bottom).offset(28)
                $0.centerX.equalToSuperview()
                $0.size.equalTo(CGSize(width: 72, height: 22))
                $0.bottom.equalToSuperview().inset(20)
            }
        }
        leftCTA.addTarget(self, action: #selector(didTapTrackCTA(sender:)), for: .touchUpInside)
        rightCTA.addTarget(self, action: #selector(didTapTrackCTA(sender:)), for: .touchUpInside)
        startTimeControl.addTarget(self, action: #selector(didTapStartTimeView(sender:)), for: .touchUpInside)
        lastBreastControl.addTarget(self, action: #selector(didTapLastBreastView(sender:)), for: .touchUpInside)
    }

    private func setupAddConstraint() {
        addNoteView.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(20)
        }
    }

    // MARK: - Update
    func updateUI() {
        updateTrackButtonView()
        updateStartTimeView()
        updateLastBreastView()
        updateNoteView()
    }
    private func updateTrackButtonView() {
        leftCTA.isSelected = false
        rightCTA.isSelected = false
        leftCTA.duration = Date.timeIntervalToString(timeInterval: TimeInterval(viewModel.editModel.leftBreast.duration),
                                                     allowedUnits: [.minute, .second]) ?? "00:00"
        rightCTA.duration = Date.timeIntervalToString(timeInterval: TimeInterval(viewModel.editModel.rightBreast.duration),
                                                      allowedUnits: [.minute, .second]) ?? "00:00"
    }
    private func updateStartTimeView() {
        startTimeView.text = viewModel.editModel.startTime.feedStartTimeString()
    }
    private func updateLastBreastView() {
        lastBreastView.isEnable = viewModel.lastBreastEnable
        if viewModel.lastBreastEnable {
            lastBreastView.hintColor = .GlobalTextPrimary
            lastBreastView.text = viewModel.editModel.lastBreast?.normalTitle
            lastBreastView.placeholderColor = .DarkGray500
            lastBreastView.rightButtonSetImage(image: TBIconList.caretDown.image(sizeOption: .normal, color: .Navy), backgroundColor: nil, for: .normal)
        } else {
            lastBreastView.hintColor = .DarkGray500
            lastBreastView.text = nil
            lastBreastView.placeholderColor = .DarkGray600
            lastBreastView.rightButtonSetImage(image: TBIconList.caretDown.image(sizeOption: .normal, color: .DarkGray500), backgroundColor: nil, for: .normal)
        }
    }
    private func updateNoteView() {
        addNoteView.note = viewModel.editModel.note
    }

    // MARK: - Actions
    @objc private func didTapTrackCTA(sender: TBFeedingTrackerEditButton) {
        endEditing()
        feedDurationPickerView.setupPicker(with: viewController, showIndex: nil)
        switch sender.side {
        case .left:
            feedDurationPickerView.adapter = leftDurationAdapter
        case .right:
            feedDurationPickerView.adapter = rightDurationAdapter
        }
        feedDurationPickerView.showPicker()
        let adapter = feedDurationPickerView.adapter as? TBFeedingDurationPickerAdapter
        if let minuteComponent = adapter?.dataSource.firstIndex(where: { $0.type == .minute }) {
            let pickerSelectMinute = viewModel.pickerSelectMinute(editButton: sender)
            feedDurationPickerView.picker.selectRow(pickerSelectMinute, inComponent: minuteComponent, animated: false)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                self.feedDurationPickerView.picker.delegate?.pickerView?(self.feedDurationPickerView.picker, didSelectRow: pickerSelectMinute, inComponent: minuteComponent)
            }
        }
        if let secondComponent = adapter?.dataSource.firstIndex(where: { $0.type == .second }) {
            let pickerSelectSecond = viewModel.pickerSelectSecond(editButton: sender)
            feedDurationPickerView.picker.selectRow(pickerSelectSecond, inComponent: secondComponent, animated: false)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                self.feedDurationPickerView.picker.delegate?.pickerView?(self.feedDurationPickerView.picker, didSelectRow: pickerSelectSecond, inComponent: secondComponent)
            }
        }
    }
    @objc private func didTapStartTimeView(sender: UIControl) {
        endEditing()
        startTimePickerView.date = viewModel.editModel.startTime
        startTimePickerView.show()
    }
    @objc private func didTapLastBreastView(sender: UIControl) {
        endEditing()
        guard lastBreastView.isEnable,
              let adapter = lastBreastPickerView.adapter as? TBFeedingLastBreastPickerAdapter else { return }
        let index = adapter.dataSource.firstIndex(of: viewModel.editModel.lastBreast ?? .left)
        lastBreastPickerView.setupPicker(with: viewController, showIndex: index)
        lastBreastPickerView.showPicker()
    }
}

// MARK: - TBDatePickerViewDelegate
extension TBNursingManualAddEntryView: TBDatePickerViewDelegate {
    func didSelect(view: TBDatePickerView, date: Date) {
        if view == startTimePickerView {
            viewModel.editModel.startTime = date
            viewModel.updateSubject.onNext(nil)
        }
    }
}

// MARK: - TBOldPickerViewDelegate
extension TBNursingManualAddEntryView: TBOldPickerViewDelegate {
    func didSelect(view: TBOldPickerView, index: Int) {
        if view == lastBreastPickerView {
            guard let lastSide = (view.adapter as? TBFeedingLastBreastPickerAdapter)?.dataSource[safe: index] else { return }
            viewModel.editModel.lastBreast = lastSide
            viewModel.updateSubject.onNext(nil)
        } else if view == feedDurationPickerView {
            guard let adapter = view.adapter as? TBFeedingDurationPickerAdapter else { return }
            if adapter == leftDurationAdapter {
                viewModel.setDuration(side: .left, minuteDuration: adapter.minuteDuration, secondDuration: adapter.secondDuration)
            } else if adapter == rightDurationAdapter {
                viewModel.setDuration(side: .right, minuteDuration: adapter.minuteDuration, secondDuration: adapter.secondDuration)
            }
            viewModel.updateSubject.onNext(nil)
        }
    }
    func didDismiss(view: TBOldPickerView) {
        if view == feedDurationPickerView {
            updateTrackButtonView()
        }
    }
}
