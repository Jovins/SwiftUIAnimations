import UIKit

final class TBFeedingTrackerSettingsViewController: UIViewController {

    private var dataSource: [TBFeedingTrackerSettingModel] = []
    private lazy var settingTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TBFeedingTrackerSettingCell.self)
        tableView.register(TBFeedingTrackerSettingHeaderView.self)
        return tableView
    }()
    private let medicalDisclaimerView = TBMedicalDisclaimerView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBarButtonItem()
        setupUI()
        getData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if TBMedicalDisclaimerDisplayHelper.shouldAutomaticallyShow(inPosition: .feedingTracker) {
            medicalDisclaimerView.show()
        }
    }

    private func setupBarButtonItem() {
        navigationItem.title = "Tracker Settings"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        if presentingViewController != nil {
            setupFeedingTrackerLeftNavigationItem(model: TBFeedingTrackerNavigationBarModel(type: .close))
        } else {
            setupFeedingTrackerLeftNavigationItem(model: TBFeedingTrackerNavigationBarModel(type: .back))
        }
        setupFeedingTrackerRightNavigationItems([TBFeedingTrackerNavigationBarModel(type: .help, action: #selector(didTapToHelp))])
    }

    private func setupUI() {
        view.backgroundColor = .GlobalBackgroundPrimary
        [settingTableView, medicalDisclaimerView].forEach(view.addSubview)
        settingTableView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.bottom.equalTo(medicalDisclaimerView.snp.top)
        }
        medicalDisclaimerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(66)
        }
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        settingTableView.addGestureRecognizer(longPress)
    }

    private func getData() {
        dataSource = TBFeedingTrackerSettingHelper.shared.getSettingModels()
    }

    private func saveData() {
        TBFeedingTrackerSettingHelper.shared.saveSettingModels(dataSource)
    }

    @objc private func didTapToHelp() {
        view.endEditing(true)
        AppRouter.shared.navigator.push(TBFeedingTrackerAboutPageViewController())
        TBAnalyticsManager.babyTrackerInteraction(type: .history(type: "null"), selectionType: .help)
    }
}

// MARK: - UITableViewDataSource
extension TBFeedingTrackerSettingsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(TBFeedingTrackerSettingCell.self, for: indexPath)
        cell.delegate = self
        if let model = dataSource[safe: indexPath.row] {
            cell.setup(model: model)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 73
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(TBFeedingTrackerSettingHeaderView.self)
        header.setup(title: "My Homefeed")
        return header
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        let state = gestureRecognizer.state
        let locationInView = gestureRecognizer.location(in: settingTableView)
        let indexPath = settingTableView.indexPathForRow(at: locationInView)

        struct Path {
            static var initialIndexPath: IndexPath?
        }

        switch state {
        case .began:
            guard let indexPath else { return }
            Path.initialIndexPath = indexPath
        case .changed:
            guard let indexPath = indexPath,
               let fromIndexPath = Path.initialIndexPath,
               indexPath != fromIndexPath else { return }
            dataSource.swapAt(fromIndexPath.row, indexPath.row)
            settingTableView.moveRow(at: fromIndexPath, to: indexPath)
            Path.initialIndexPath = indexPath
        case .ended:
            Path.initialIndexPath = nil
            saveData()
            trackReorderInteractionEvent(indexPath: indexPath)
        default:
            break
        }
    }

    private func trackReorderInteractionEvent(indexPath: IndexPath?) {
        guard let indexPath, let model = dataSource[safe: indexPath.row] else { return }
        TBAnalyticsManager.babyTrackerSettingInteraction(type: model.type.title.lowercased(), selection: .reorder)
    }
}

// MARK: - TBFeedingTrackerSettingCellDelegate
extension TBFeedingTrackerSettingsViewController: TBFeedingTrackerSettingCellDelegate {

    func didTapSwitchVisibleButton(model: TBFeedingTrackerSettingModel, sender: UIButton) {
        model.isVisible = !sender.isSelected
        saveData()
        TBAnalyticsManager.babyTrackerSettingInteraction(type: model.type.title.lowercased(),
                                                         selection: model.isVisible ? .unhide : .hide)
    }
}
