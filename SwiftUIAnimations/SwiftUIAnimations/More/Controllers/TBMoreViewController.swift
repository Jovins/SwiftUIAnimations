import UIKit

class TBMoreViewController: UIViewController {
    private(set) var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .GlobalBackgroundPrimary
        tableView.separatorStyle = .none
        return tableView
    }()

    override var descriptionGA: String { "More Page View" }
    private(set) var model = TBMoreViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        navigationController?.createRightItemButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        screenViewed()
    }

    private func setupUI() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        view.backgroundColor = .GlobalBackgroundPrimary
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TBMoreTableViewCell.self)

        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - UITableViewDelegate & UItableViewDataSource
extension TBMoreViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TBMoreViewModel.MoreMenu.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let menu = TBMoreViewModel.MoreMenu(rawValue: indexPath.row) else {
            fatalError("no menu on TBMoreTableViewCell")
        }
        let cell = tableView.dequeueReusableCell(TBMoreTableViewCell.self, for: indexPath)
        cell.setup(menu: menu)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menu = TBMoreViewModel.MoreMenu(rawValue: indexPath.row) else {
            return
        }

        switch menu {
        case .myProfile:
            AppRouter.shared.navigator.open(menu.link)
        case .community:
            TBToolsDataManager.sharedInstance.recordClickCount(type: .community)
            fallthrough
        case .accountPreference,
                .toolsAndResources,
                .help:
            AppRouter.shared.navigator.push(menu.link)
        case .bestOfTheBumpAwards:
            AppRouter.navigateToBrowser(url: menu.link) { setting in
                setting.title = menu.title
                return setting
            }
        case .shareYourSuggestions:
            let popupVC = MemberFeedbackPopupViewController()
            popupVC.delegate = self
            let navController = UINavigationController(rootViewController: popupVC)
            navController.modalPresentationStyle = .fullScreen
            AppRouter.shared.navigator.present(navController, animated: true, completion: nil)
        case .addTheBumpWidget:
            AppRouter.shared.navigator.present(menu.link, animated: false)
        }

        trackMenuInteraction(title: menu.title)
        TBNewItemIndicatorManager.shared.recordOpen(indicatorType: .new, indicatorItemType: menu.indicatorItemType)
        self.tableView.reloadData()
    }

    private func trackMenuInteraction(title: String) {
        TBAnalyticsManager
            .logEventNamed(kAnalyticsEventMenuInteraction,
                           withProperties: [kAnalyticsKeyPlacement: "more tab",
                                            kAnalyticsKeySelection: title])
    }
}

// MARK: MemberFeedbackPopupViewControllerDelegate
extension TBMoreViewController: MemberFeedbackPopupViewControllerDelegate {
    func finishSubmitAndDismiss() {
        TBToastView().display(attributedText: "Feedback submitted successfully! Thank you!".attributedText(.mulishBody3,
                                                                                                           foregroundColor: .GlobalTextSecondary),
                              on: view,
                              leadingAndTrailingSpacing: 20)
    }
}
