import UIKit
import RxSwift

final class TBFeedingTrackerHistoryViewController: UIViewController {

    var selectedIndex: Int = 0
    private lazy var toolbar: TBFeedingToolbar = {
        let bar = TBFeedingToolbar()
        bar.selectedIndex = selectedIndex
        bar.delegate = self
        return bar
    }()
    private var pageViewControllers: [UIViewController] {
        return [TBHistoryViewController(type: .all),
                TBHistoryViewController(type: .nursing),
                TBHistoryViewController(type: .bottle),
                TBHistoryViewController(type: .pumping),
                TBHistoryViewController(type: .diapers)]
    }
    private let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    private let viewModel = TBHistoryViewModel()
    private let disposeBag = DisposeBag()

    override var screenName: String? {
        return "Baby Tracker Screen"
    }

    override var descriptionGA: String {
        return "Baby Tracker"
    }

    override var screenNameProperties: [String: Any]? {
        return [TBAnalyticsManager.analyticsKeyType: "history"]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateShareButtonAppearance()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        screenViewed()
        if TBMedicalDisclaimerDisplayHelper.shouldAutomaticallyShow(inPosition: .feedingTracker) {
            TBMedicalDisclaimerView().show()
        }
    }

    private func setupUI() {
        view.backgroundColor = .GlobalBackgroundPrimary
        navigationItem.title = "History"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        if presentingViewController != nil {
            setupFeedingTrackerLeftNavigationItem(model: TBFeedingTrackerNavigationBarModel(type: .close, action: #selector(didTapToClose)))
        } else {
            setupFeedingTrackerLeftNavigationItem(model: TBFeedingTrackerNavigationBarModel(type: .back, action: #selector(didTapToBack)))
        }
        setupFeedingTrackerRightNavigationItems([TBFeedingTrackerNavigationBarModel(type: .help, action: #selector(didTapToHelp)),
                                                 TBFeedingTrackerNavigationBarModel(type: .setting, action: #selector(didTapToSetting)),
                                                 TBFeedingTrackerNavigationBarModel(type: .share, action: #selector(didTapNavigationShare(button:)))])

        addChild(pageVC)
        [toolbar, pageVC.view].forEach(view.addSubview)
        toolbar.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(72)
        }
        pageVC.view.snp.makeConstraints {
            $0.top.equalTo(toolbar.snp.bottom)
            $0.leading.bottom.trailing.equalToSuperview()
        }
        if let vc = pageViewControllers[safe: selectedIndex] {
            pageVC.setViewControllers([vc], direction: .forward, animated: false)
        }
    }

    private func updateShareButtonAppearance() {
        guard let rightBarButtonItem = navigationItem.rightBarButtonItem else { return }
        if let stackView = rightBarButtonItem.customView as? UIStackView {
            if let button = stackView.arrangedSubviews.first(where: { view -> Bool in
                guard let button = view as? UIButton else { return false }
                return TBFeedingTrackerNavigationBarModel.NavigationButtonType(rawValue: button.tag) == .share
            }) as? UIButton {
                button.isEnabled = !viewModel.allHistorys.isEmpty
            }
        }
    }

    private func getData() {
        viewModel.getAllHistory()
    }

    @objc private func didTapToBack() {
        navigationController?.popViewController(animated: true)
        TBAnalyticsManager.babyTrackerInteraction(type: .history(type: "null"), selectionType: .back)
    }

    @objc private func didTapToClose() {
        dismiss(animated: true)
        TBAnalyticsManager.babyTrackerInteraction(type: .history(type: "null"), selectionType: .back)
    }

    @objc private func didTapToHelp() {
        view.endEditing(true)
        AppRouter.shared.navigator.push(TBFeedingTrackerAboutPageViewController())
        TBAnalyticsManager.babyTrackerInteraction(type: .history(type: "null"), selectionType: .help)
    }

    @objc private func didTapToSetting() {
        view.endEditing(true)
        AppRouter.navigateToFeedingTrackerSettingPage(action: .push)
        TBAnalyticsManager.babyTrackerInteraction(type: .history(type: "null"), selectionType: .setting)
    }

    @objc private func didTapNavigationShare(button: UIButton) {
        viewModel.outputDataAsCSV(sender: button)
        TBAnalyticsManager.babyTrackerInteraction(type: .history(type: "null"), selectionType: .share)
    }
}

// MARK: - TBFeedingToolbarDelegate
extension TBFeedingTrackerHistoryViewController: TBFeedingToolbarDelegate {
    func toolbar(_ toolbar: TBFeedingToolbar, didSelectIndexAt index: Int, item: TBFeedingToolbarItem) {
        self.selectedIndex = index
        guard let vc = pageViewControllers[safe: index] else { return }
        pageVC.setViewControllers([vc], direction: .forward, animated: false)
    }
}
