import UIKit
import RxSwift

protocol TBNursingToolViewDelegate: AnyObject {
    func didTapAddManualEntryCTA()
}

final class TBNursingToolView: UIView {

    weak var delegate: TBNursingToolViewDelegate?
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Tap the Left or\nRight Breast to Start".attributedText(.mulishLink1, alignment: .center)
        label.numberOfLines = 2
        return label
    }()
    private let timeTitleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Feed Duration".attributedText(.mulishBody1)
        label.isHidden = true
        return label
    }()
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "00:00:00".attributedText(.mulishTitle3)
        label.isHidden = true
        return label
    }()
    private let leftButton: TBFeedingBreastButton = {
        let button = TBFeedingBreastButton()
        button.buttonSide = .left
        button.timeText = "00:00"
        return button
    }()
    private let rightButton: TBFeedingBreastButton = {
        let button = TBFeedingBreastButton()
        button.buttonSide = .right
        button.timeText = "00:00"
        return button
    }()
    private let lastSideLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Last\nSide".attributedText(.mulishBody4, alignment: .center)
        label.numberOfLines = 2
        label.backgroundColor = .Chartreuse
        label.cornerRadius = 26
        label.isHidden = true
        return label
    }()
    private lazy var addNoteView: TBAddNoteTextView = {
        let view = TBAddNoteTextView()
        view.titleLabelText = "Add Note"
        view.delegate = self
        return view
    }()
    private let resetCTA: TBCommonButton = {
        let button = TBCommonButton()
        button.setTitle("Reset", for: .normal)
        button.buttonState = .secondary
        button.buttonWidth = (UIDevice.width - 76) * 0.5
        button.buttonHeight = 46
        button.isEnabled = false
        return button
    }()
    private(set) var saveCTA: TBCommonButton = {
        let button = TBCommonButton()
        button.setTitle("Save", for: .normal)
        button.buttonWidth = (UIDevice.width - 76) * 0.5
        button.buttonHeight = 46
        button.isEnabled = false
        return button
    }()
    private let addManualEntryCTA: TBLinkButton = {
        let button = TBLinkButton()
        button.colorStyle = .theme
        button.contentStyle = .medium
        button.setTitle("Add Manual Entry", for: .normal)
        return button
    }()
    private let disposeBag = DisposeBag()
    private var nursingTimer: Timer?
    private var viewModel: TBNursingToolViewModel
    private var buttonPadding: CGFloat {
        return UIDevice.isPad() ? 48 : 24
    }

    override init(frame: CGRect) {
        viewModel = TBNursingToolViewModel()
        super.init(frame: frame)
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(invalidateTimer), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateButtonStateIfNeed), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        invalidateTimer()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        endEditing(true)
    }

    private func setupUI() {
        backgroundColor = .OffWhite
        addManualEntryCTA.addTarget(self, action: #selector(didTapAddManualEntryCTA), for: .touchUpInside)
        [titleLabel, timeTitleLabel, timeLabel, leftButton, rightButton, lastSideLabel,
         addNoteView, resetCTA, saveCTA, addManualEntryCTA].forEach(addSubview)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(24)
            $0.centerX.equalToSuperview()
        }
        timeTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(24)
            $0.centerX.equalToSuperview()
        }
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(timeTitleLabel.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }
        leftButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(114)
            $0.trailing.equalTo(self.snp.centerX).offset(-buttonPadding)
            $0.size.equalTo(126)
        }
        rightButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(114)
            $0.leading.equalTo(self.snp.centerX).offset(buttonPadding)
            $0.size.equalTo(126)
        }
        lastSideLabel.snp.makeConstraints {
            $0.leading.equalTo(rightButton.snp.centerX).offset(24)
            $0.top.equalTo(rightButton.snp.top).offset(-14)
            $0.size.equalTo(52)
        }
        addNoteView.snp.makeConstraints {
            $0.top.equalTo(leftButton.snp.bottom).offset(36)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        resetCTA.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalTo(addNoteView.snp.bottom).offset(32)
        }
        saveCTA.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(addNoteView.snp.bottom).offset(32)
        }
        addManualEntryCTA.snp.makeConstraints {
            $0.top.equalTo(saveCTA.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        leftButton.addTarget(self, action: #selector(didTapFeedingCTA(sender:)), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(didTapFeedingCTA(sender:)), for: .touchUpInside)
        resetCTA.addTarget(self, action: #selector(didTapResetCTA(sender:)), for: .touchUpInside)
        saveCTA.addTarget(self, action: #selector(didTapSaveCTA(sender:)), for: .touchUpInside)
        viewModel.updateNursingSubject.subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] shouldUpdate in
                guard shouldUpdate, let self = self else { return }
                self.updateAppearance()
            }, onError: { _ in }).disposed(by: disposeBag)
        viewModel.getData()
        updateButtonStateIfNeed()
        updateAppearance()
    }

    private func checkSaveEnable() {
        saveCTA.isEnabled = viewModel.totalDuration > 0 && !addNoteView.moreThanMaxCharacter
    }

    private func updateAppearance() {
        if !viewModel.shouldStartToRecord {
            timeLabel.attributedText = "00:00:00".attributedText(.mulishTitle3)
            leftButton.isSelected = false
            leftButton.buttonState = .normal
            leftButton.timeText = "00:00"
            rightButton.isSelected = false
            rightButton.buttonState = .normal
            rightButton.timeText = "00:00"
            addNoteView.note = ""
        }
        titleLabel.isHidden = viewModel.shouldStartToRecord
        timeTitleLabel.isHidden = !viewModel.shouldStartToRecord
        timeLabel.isHidden = !viewModel.shouldStartToRecord
        resetCTA.isEnabled = viewModel.totalDuration > 0
        checkSaveEnable()
        if let lastSide = viewModel.lastSide {
            lastSideLabel.isHidden = false
            updateLastSideIfNeed()
        } else {
            lastSideLabel.isHidden = true
        }
        addManualEntryCTA.isEnabled = !(leftButton.isSelected || rightButton.isSelected)
    }

    @objc private func updateButtonStateIfNeed() {
        guard let model = viewModel.currentModel else { return }
        leftButton.isSelected = model.leftBreast.isBreasting
        if leftButton.isSelected {
            viewModel.currentSide = .left
            leftButton.buttonState = .select
        } else {
            leftButton.buttonState = model.leftBreast.duration != 0 ? .end : .normal
        }

        rightButton.isSelected = model.rightBreast.isBreasting
        if rightButton.isSelected {
            viewModel.currentSide = .right
            rightButton.buttonState = .select
        } else {
            rightButton.buttonState = model.rightBreast.duration != 0 ? .end : .normal
        }

        let duration = Date().timeIntervalSince1970 - model.updatedTime.timeIntervalSince1970
        let isBreasting = leftButton.buttonState == .select || rightButton.buttonState == .select
        viewModel.updateCurrentNursing(duration: Int(duration), isBreasting: isBreasting)
        setup(totalDuration: viewModel.shouldStartToRecord ? viewModel.totalDuration : 0)
        if isBreasting {
            startNursingTimer()
        }
    }

    private func updateLastSideIfNeed() {
        guard let lastSide = viewModel.lastSide else { return }
        lastSideLabel.isHidden = false
        switch lastSide {
        case .left:
            lastSideLabel.snp.remakeConstraints {
                $0.leading.equalTo(leftButton.snp.centerX).offset(24)
                $0.top.equalTo(leftButton.snp.top).offset(-14)
                $0.size.equalTo(52)
            }
        case .right:
            lastSideLabel.snp.remakeConstraints {
                $0.leading.equalTo(rightButton.snp.centerX).offset(24)
                $0.top.equalTo(rightButton.snp.top).offset(-14)
                $0.size.equalTo(52)
            }
        }
    }

    private func startNursingTimer() {
        invalidateTimer()
        let timer = Timer(timeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            self.repeatNursingTimer()
        })
        nursingTimer = timer
        RunLoop.current.add(timer, forMode: .common)
    }

    @objc private func invalidateTimer() {
        guard let timer = nursingTimer else { return }
        timer.invalidate()
        nursingTimer = nil
    }

    private func repeatNursingTimer() {
        if leftButton.buttonState == .select || rightButton.buttonState == .select {
            viewModel.updateCurrentNursing()
        }
        setup(totalDuration: viewModel.totalDuration)
    }

    private func setup(totalDuration: TimeInterval) {
        if let timeString = Date.timeIntervalToString(timeInterval: totalDuration) {
            timeLabel.attributedText = "\(timeString)".attributedText(.mulishTitle3)
        }
        leftButton.timeText = Date.minutesSeconds(timeInterval: viewModel.leftDuration)
        rightButton.timeText = Date.minutesSeconds(timeInterval: viewModel.rightDuration)
    }

    @objc private func didTapFeedingCTA(sender: TBFeedingBreastButton) {
        endEditing(true)
        guard !viewModel.shouldStartToRecord || viewModel.totalDuration > 0 else { return }
        if !viewModel.shouldStartToRecord {
            viewModel.startNursing()
        }
        if sender == leftButton {
            viewModel.currentSide = .left
            leftButton.isSelected = !leftButton.isSelected
            leftButton.buttonState = leftButton.isSelected ? .select : .end
            if rightButton.buttonState == .select {
                rightButton.isSelected = !rightButton.isSelected
                rightButton.buttonState = .end
            }
        } else {
            viewModel.currentSide = .right
            rightButton.isSelected = !rightButton.isSelected
            rightButton.buttonState = rightButton.isSelected ? .select : .end
            if leftButton.buttonState == .select {
                leftButton.isSelected = !leftButton.isSelected
                leftButton.buttonState = .end
            }
        }
        let isBreasting = leftButton.buttonState == .select || rightButton.buttonState == .select
        addManualEntryCTA.isEnabled = !isBreasting
        viewModel.updateCurrentNursing(duration: 0, isBreasting: isBreasting)
        if isBreasting {
            startNursingTimer()
        } else {
            invalidateTimer()
        }
    }

    @objc private func didTapResetCTA(sender: UIButton) {
        endEditing(true)
        let actionSheet = UIAlertController(title: "Are you sure you want to reset this nursing session?\n These feed will be deleted.",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let resetAction = UIAlertAction(title: "Reset",
                                   style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.invalidateTimer()
            self.viewModel.resetCurrentNursing()
            TBAnalyticsManager.babyTrackerInteraction(type: .nursing, selectionType: .reset)
        }
        actionSheet.addAction(resetAction)
        actionSheet.addAction(cancelAction)
        if let popoverController = actionSheet.popoverPresentationController {
            if let sender = sender as? UIBarButtonItem {
                popoverController.barButtonItem = sender
            } else if let sender = sender as? UIView {
                popoverController.sourceView = sender
                popoverController.sourceRect = sender.bounds
            }
            popoverController.permittedArrowDirections = [.down, .up]
        }
        AppRouter.shared.navigator.present(actionSheet)
    }

    @objc private func didTapAddManualEntryCTA() {
        delegate?.didTapAddManualEntryCTA()
        TBAnalyticsManager.babyTrackerInteraction(type: .nursing, selectionType: .addManual)
    }

    @objc private func didTapSaveCTA(sender: UIButton) {
        endEditing(true)
        if leftButton.isSelected || rightButton.isSelected {
            saveNursingWithAlert(sender: sender, message: "Nursing  Saved")
        } else {
            saveNursing("Nursing  Saved")
        }
    }

    private func saveNursing(_ message: String?) {
        invalidateTimer()
        self.viewModel.updateCurrentNursing(isBreasting: false, isSave: true, note: addNoteView.note?.trimmed)
        if let message {
            let attributedText = message.attributedText(.mulishBody4, foregroundColor: .GlobalTextSecondary)
            let bottomSpacing = UIDevice.tabbarSafeAreaHeight == 0 ? 12 : UIDevice.tabbarSafeAreaHeight
            if let vc = TopViewController.topViewController() {
                TBToastView().display(attributedText: attributedText, on: vc.view, leadingAndTrailingSpacing: 10, bottomSpacing: bottomSpacing)
            }
        }
        TBAnalyticsManager.babyTrackerInteraction(type: .nursing, selectionType: .save)
    }

    private func saveNursingWithAlert(sender: UIButton, message: String? = nil) {
        let actionSheet = UIAlertController(title: "Do you want to finish your nursing session and save it?",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        let saveAction = UIAlertAction(title: "Save",
                                   style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.saveNursing(message)
        }
        actionSheet.addAction(saveAction)
        actionSheet.addAction(cancelAction)
        if let popoverController = actionSheet.popoverPresentationController {
            if let sender = sender as? UIBarButtonItem {
                popoverController.barButtonItem = sender
            } else if let sender = sender as? UIView {
                popoverController.sourceView = sender
                popoverController.sourceRect = sender.bounds
            }
            popoverController.permittedArrowDirections = [.down, .up]
        }
        AppRouter.shared.navigator.present(actionSheet)
    }
}

// MARK: - TBAddNoteTextViewDelegate
extension TBNursingToolView: TBAddNoteTextViewDelegate {

    func textView(textView: UITextView, moreThanMaxCharacter isEnabled: Bool) {
        checkSaveEnable()
    }
}
