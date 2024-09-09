import UIKit
import RxSwift

final class TBDiapersViewController: UIViewController {
    private let scrollView: TBScrollView = {
        let scrollView = TBScrollView()
        scrollView.backgroundColor = .GlobalBackgroundPrimary
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delaysContentTouches = false
        return scrollView
    }()
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .GlobalBackgroundPrimary
        return view
    }()
    private lazy var toolView: TBDiapersToolView = {
        let tool = TBDiapersToolView()
        tool.delegate = self
        return tool
    }()
    private let todayView: TBFeedingTodayView = TBFeedingTodayView(type: .diapers)
    private let medicalDisclaimerView: TBMedicalDisclaimerView = TBMedicalDisclaimerView()
    private let medicalDisclaimerHeight: CGFloat = 66
    private let saveView: TBFeedingSaveView = TBFeedingSaveView()
    private let viewModel = TBDiapersToolViewModel()
    private let disposeBag = DisposeBag()
    private var isSaveEnabled: Bool = false {
        didSet {
            saveView.saveCTA.isEnabled = isSaveEnabled && isEnabledForCharacter
        }
    }
    private var isEnabledForCharacter: Bool = true {
        didSet {
            saveView.saveCTA.isEnabled = isSaveEnabled && isEnabledForCharacter
        }
    }

    override var screenName: String? {
        return "Baby Tracker Screen"
    }

    override var descriptionGA: String {
        return "Baby Tracker"
    }

    override var screenNameProperties: [String: Any]? {
        return [TBAnalyticsManager.analyticsKeyType: TBAnalyticsManager.BabyTrackerType.diapers.recordType]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBarButtonItem()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        screenViewed()
        if TBMedicalDisclaimerDisplayHelper.shouldAutomaticallyShow(inPosition: .feedingTracker) {
            TBMedicalDisclaimerView().show()
        }
    }

    private func setupBarButtonItem() {
        navigationItem.title = "Diapers"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        if presentingViewController != nil {
            setupFeedingTrackerLeftNavigationItem(model: TBFeedingTrackerNavigationBarModel(type: .close, action: #selector(didTapToClose(sender:))))
        } else {
            setupFeedingTrackerLeftNavigationItem(model: TBFeedingTrackerNavigationBarModel(type: .back, action: #selector(didTapToBack(sender:))))
        }
        setupFeedingTrackerRightNavigationItems([TBFeedingTrackerNavigationBarModel(type: .help, action: #selector(didTapToHelp)),
                                                 TBFeedingTrackerNavigationBarModel(type: .setting, action: #selector(didTapToSetting))])
    }

    private func setupUI() {
        view.backgroundColor = .GlobalBackgroundPrimary
        view.addSubview(scrollView)
        [scrollView, saveView].forEach(view.addSubview)
        scrollView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.bottom.equalTo(saveView.snp.top)
        }
        saveView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(UIDevice.width)
            $0.height.greaterThanOrEqualToSuperview()
        }
        [toolView, todayView, medicalDisclaimerView].forEach(contentView.addSubview)
        toolView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(24)
            $0.leading.trailing.equalToSuperview()
        }
        todayView.snp.makeConstraints {
            $0.top.equalTo(toolView.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(92)
        }
        medicalDisclaimerView.snp.remakeConstraints {
            $0.top.greaterThanOrEqualTo(todayView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(medicalDisclaimerHeight)
            $0.bottom.equalToSuperview()
        }
        saveView.saveCTA.addTarget(self, action: #selector(didTapSaveCTA), for: .touchUpInside)

        viewModel.saveDiapersSubject.subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] shouldUpdate in
            guard shouldUpdate, let self = self else { return }
            self.recoverAppearance()
            let message = "Diapers change Saved".attributedText(.mulishBody4, foregroundColor: .GlobalTextSecondary)
            let bottomSpacing = UIDevice.tabbarSafeAreaHeight == 0 ? 12 : UIDevice.tabbarSafeAreaHeight
            if let vc = TopViewController.topViewController() {
                TBToastView().display(attributedText: message, on: vc.view, leadingAndTrailingSpacing: 10, bottomSpacing: bottomSpacing)
            }
        }, onError: { _ in }).disposed(by: disposeBag)

        todayView.updateTodayViewHeightSubject.subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] tableViewHeight in
                guard let self = self else { return }
                self.updateTodayView(height: tableViewHeight)
        }, onError: { _ in }).disposed(by: disposeBag)
        todayView.getData()
    }

    private func updateTodayView(height: CGFloat) {
        todayView.snp.updateConstraints {
            $0.height.equalTo(height)
        }
    }

    private func recoverAppearance() {
        saveView.saveCTA.isEnabled = false
        toolView.recoverAppearance()
    }

    @objc private func didTapSaveCTA() {
        view.endEditing(true)
        let model = TBDiapersModel()
        model.diaperName = toolView.lastDiapersButton?.type.rawValue
        model.startTime = toolView.startTime
        model.note = toolView.addNoteView.note?.trimmed
        model.savedTime = Date()
        viewModel.saveDiapers(model: model)
        TBAnalyticsManager.babyTrackerInteraction(type: .diapers, selectionType: .save)
    }

    @objc private func didTapToHelp() {
        view.endEditing(true)
        AppRouter.shared.navigator.push(TBFeedingTrackerAboutPageViewController())
        TBAnalyticsManager.babyTrackerInteraction(type: .diapers, selectionType: .help)
    }

    @objc private func didTapToSetting() {
        view.endEditing(true)
        AppRouter.navigateToFeedingTrackerSettingPage(action: .push)
        TBAnalyticsManager.babyTrackerInteraction(type: .diapers, selectionType: .setting)
    }

    @objc private func didTapToClose(sender: UIButton) {
        view.endEditing(true)
        showActionSheet(sender: sender, isPresenting: true)
    }

    @objc private func didTapToBack(sender: UIButton) {
        view.endEditing(true)
        showActionSheet(sender: sender, isPresenting: false)
    }

    private func showActionSheet(sender: UIButton, isPresenting: Bool) {
        if saveView.saveCTA.isEnabled {
            let actionSheet = UIAlertController(title: "Changes have not been saved.\nDo you want to continue?",
                                                message: nil,
                                                preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "No", style: .cancel)
            let resetAction = UIAlertAction(title: "Yes",
                                       style: .destructive) { [weak self] _ in
                guard let self = self else { return }
                self.dismissViewController(isPresenting: isPresenting)
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
        } else {
            dismissViewController(isPresenting: isPresenting)
        }
    }

    private func dismissViewController(isPresenting: Bool) {
        if isPresenting {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
        TBAnalyticsManager.babyTrackerInteraction(type: .diapers, selectionType: .back)
    }
}

// MARK: - TBDiapersToolViewDelegate
extension TBDiapersViewController: TBDiapersToolViewDelegate {

    func toolView(_ toolView: TBDiapersToolView, didSelectDiaper type: TBDiapersButtton.TBDiapersButttonType) {
        isSaveEnabled = true
    }

    func textView(_ textView: UITextView, moreThanMaxCharacter isEnabled: Bool) {
        isEnabledForCharacter = isEnabled
    }
}

final class TBBackButton: UIButton {
    var alignmentRectInsetsOverride: UIEdgeInsets?
    override var alignmentRectInsets: UIEdgeInsets {
        return alignmentRectInsetsOverride ?? super.alignmentRectInsets
    }
}
