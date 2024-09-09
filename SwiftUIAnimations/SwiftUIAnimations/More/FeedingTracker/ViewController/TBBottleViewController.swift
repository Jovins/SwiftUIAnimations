import UIKit
import SnapKit
import RxSwift

final class TBBottleViewController: UIViewController {
    private let unitBar: TBFeedingTrackerUnitBarView = TBFeedingTrackerUnitBarView()
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
    private let contentView: UIView = UIView()
    private let bottleToolView: TBBottleToolView = TBBottleToolView()
    private let todayView: TBFeedingTodayView = TBFeedingTodayView(type: .bottle)
    private let medicalDisclaimerView: TBMedicalDisclaimerView = TBMedicalDisclaimerView()
    private let saveView: TBFeedingSaveView = TBFeedingSaveView()
    private let unitBarHeight: CGFloat = 48
    private let medicalDisclaimerHeight: CGFloat = 66
    private let bottleToolViewHeight: CGFloat = 502
    private let saveViewHeight: CGFloat = 56
    private let disposeBag = DisposeBag()
    private let viewModel: TBBottleHomePageViewModel = TBBottleHomePageViewModel()

    override var screenName: String? {
        return "Baby Tracker Screen"
    }

    override var descriptionGA: String {
        return "Baby Tracker"
    }

    override var screenNameProperties: [String: Any]? {
        return [TBAnalyticsManager.analyticsKeyType: TBAnalyticsManager.BabyTrackerType.bottle.recordType]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBarButtonItem()
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateMetric), name: TBNotificationConstant.didUpdateMetric, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        screenViewed()
        if TBMedicalDisclaimerDisplayHelper.shouldAutomaticallyShow(inPosition: .feedingTracker) {
            TBMedicalDisclaimerView().show()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupBarButtonItem() {
        navigationItem.title = "Bottle Feeding"
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
        bottleToolView.delegate = self
        [unitBar, scrollView, saveView].forEach(view.addSubview)
        scrollView.addSubview(contentView)
        [bottleToolView, todayView, medicalDisclaimerView].forEach(contentView.addSubview)
        unitBar.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(unitBarHeight)
        }
        scrollView.snp.makeConstraints {
            $0.top.equalTo(unitBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(saveView.snp.top)
        }
        saveView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(UIDevice.width)
            $0.height.greaterThanOrEqualToSuperview()
        }
        bottleToolView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        todayView.snp.makeConstraints {
            $0.top.equalTo(bottleToolView.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(92)
        }
        medicalDisclaimerView.snp.remakeConstraints {
            $0.top.greaterThanOrEqualTo(todayView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(medicalDisclaimerHeight)
            $0.bottom.equalToSuperview()
        }

        saveView.saveCTA.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        todayView.updateTodayViewHeightSubject.subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] tableViewHeight in
                guard let self = self else { return }
                self.updateTodayView(height: tableViewHeight)
        }, onError: { _ in }).disposed(by: disposeBag)
        viewModel.getData()
    }

    private func updateTodayView(height: CGFloat) {
        todayView.snp.updateConstraints {
            $0.height.equalTo(height)
        }
    }

    @objc private func didTapSave() {
        bottleToolView.viewModel.editModel.savedTime = Date()
        viewModel.addModel(model: bottleToolView.viewModel.editModel)
        bottleToolView.viewModel.editModel = TBBottleModel(startTime: Date())
        bottleToolView.resetUI()
        checkSaveEnable()

        let message = "Bottle Feeding Saved".attributedText(.mulishBody4, foregroundColor: .GlobalTextSecondary)
        let bottomSpacing = UIDevice.tabbarSafeAreaHeight == 0 ? 12 : UIDevice.tabbarSafeAreaHeight
        TBToastView().display(attributedText: message, on: self.view, leadingAndTrailingSpacing: 10, bottomSpacing: bottomSpacing)

        TBAnalyticsManager.babyTrackerInteraction(type: .bottle, selectionType: .save)
    }

    @objc private func didTapToHelp() {
        view.endEditing(true)
        AppRouter.shared.navigator.push(TBFeedingTrackerAboutPageViewController())
        TBAnalyticsManager.babyTrackerInteraction(type: .bottle, selectionType: .help)
    }

    @objc private func didTapToSetting() {
        view.endEditing(true)
        AppRouter.navigateToFeedingTrackerSettingPage(action: .push)
        TBAnalyticsManager.babyTrackerInteraction(type: .bottle, selectionType: .setting)
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
        TBAnalyticsManager.babyTrackerInteraction(type: .bottle, selectionType: .back)
    }

    private func checkSaveEnable() {
        if bottleToolView.viewModel.editModel.amountModel.amount == 0 {
            saveView.saveCTA.isEnabled = false
            return
        }
        if bottleToolView.addNoteView.moreThanMaxCharacter {
            saveView.saveCTA.isEnabled = false
            return
        }
        saveView.saveCTA.isEnabled = true
    }

    @objc private func didUpdateMetric() {
        bottleToolView.resetUI()
        todayView.reloadData()
    }
}

// MARK: - TBBottleToolViewDelegate
extension TBBottleViewController: TBBottleToolViewDelegate {
    func modelDidUpdate() {
        checkSaveEnable()
    }
}
