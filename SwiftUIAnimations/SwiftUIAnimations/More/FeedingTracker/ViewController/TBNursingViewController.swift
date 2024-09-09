import UIKit
import RxSwift

final class TBNursingViewController: UIViewController {
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
    private lazy var toolView: TBNursingToolView = {
        let view = TBNursingToolView()
        view.delegate = self
        return view
    }()
    private let todayView: TBFeedingTodayView = TBFeedingTodayView(type: .nursing)
    private let medicalDisclaimerView: TBMedicalDisclaimerView = TBMedicalDisclaimerView()
    private let medicalDisclaimerHeight: CGFloat = 66
    private let disposeBag = DisposeBag()

    override var screenName: String? {
        return "Baby Tracker Screen"
    }

    override var descriptionGA: String {
        return "Baby Tracker"
    }

    override var screenNameProperties: [String: Any]? {
        return [TBAnalyticsManager.analyticsKeyType: TBAnalyticsManager.BabyTrackerType.nursing.recordType]
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
        navigationItem.title = "Nursing"
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
        [scrollView].forEach(view.addSubview)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(UIDevice.width)
            $0.height.greaterThanOrEqualToSuperview()
        }
        [toolView, todayView, medicalDisclaimerView].forEach(contentView.addSubview)
        toolView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
        }
        todayView.snp.makeConstraints {
            $0.top.equalTo(toolView.snp.bottom).offset(36)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(92)
        }
        medicalDisclaimerView.snp.remakeConstraints {
            $0.top.greaterThanOrEqualTo(todayView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(medicalDisclaimerHeight)
            $0.bottom.equalToSuperview()
        }
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

    @objc private func didTapToHelp() {
        view.endEditing(true)
        AppRouter.shared.navigator.push(TBFeedingTrackerAboutPageViewController())
        TBAnalyticsManager.babyTrackerInteraction(type: .nursing, selectionType: .help)
    }

    @objc private func didTapToSetting() {
        view.endEditing(true)
        AppRouter.navigateToFeedingTrackerSettingPage(action: .push)
        TBAnalyticsManager.babyTrackerInteraction(type: .nursing, selectionType: .setting)
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
        if isPresenting {
            dismiss(animated: true) {
                self.showNursingPopup()
            }
        } else {
            navigationController?.popViewController(animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showNursingPopup()
            }
        }
        TBAnalyticsManager.babyTrackerInteraction(type: .nursing, selectionType: .back)
    }

    private func showNursingPopup() {
        guard toolView.saveCTA.isEnabled else { return }
        let modalView = TBModalView.build(content: "You're stepping away from the Nursing main screen, but don't worry, we'll keep recording your session. Just remember to come back and save it when you're done.", ctaType: .nursing)
        modalView.show()
    }
}

// MARK: - TBNursingToolViewDelegate
extension TBNursingViewController: TBNursingToolViewDelegate {

    func didTapAddManualEntryCTA() {
        let manualAddEntryVC = TBNursingManualAddEntryViewController()
        AppRouter.shared.navigator.push(manualAddEntryVC)
    }
}
