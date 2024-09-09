import UIKit
import RxSwift

final class TBHistoryViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(), style: .plain)
        tableView.backgroundColor = .OffWhite
        tableView.separatorStyle = .none
        tableView.register(TBFeedingTodayRecordCell.self)
        tableView.register(TBFeedingTrackerHistoryEmptyCell.self)
        tableView.register(TBAllEmptyHistoryTableViewCell.self)
        tableView.register(TBFeedingTrackerHistoryHeaderView.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInsetAdjustmentBehavior = .never
        return tableView
    }()
    private var viewContentHeight: CGFloat {
        return UIScreen.main.bounds.height - UIDevice.navigationBarHeight - 130
    }
    private var bottomView = TBFeedingTrackerBottomView()
    private let viewModel = TBHistoryViewModel()
    private var historys = [[TBFeedingTrackerModelProtocol]]()
    private var type: TBFeedingTrackerHistoryType = .all
    private let disposeBag = DisposeBag()

    init(type: TBFeedingTrackerHistoryType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.reloadSubject.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.getHistorys()
        }).disposed(by: disposeBag)
        viewModel.getAllHistory()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    private func setupUI() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        view.backgroundColor = .GlobalBackgroundPrimary
        [tableView, bottomView].forEach(view.addSubview)
        if type == .all {
            tableView.snp.remakeConstraints {
                $0.edges.equalToSuperview()
            }
            bottomView.snp.remakeConstraints {
                $0.leading.bottom.trailing.equalToSuperview()
            }
        } else {
            tableView.snp.makeConstraints {
                $0.leading.top.trailing.equalToSuperview()
            }
            bottomView.snp.makeConstraints {
                $0.top.equalTo(tableView.snp.bottom)
                $0.leading.bottom.trailing.equalToSuperview()
            }
        }
        bottomView.setButtonTitle(with: type.toolType)
    }

    private func getHistorys() {
        switch type {
        case .all:
            historys = viewModel.allHistorys
            updateMedicalDisclaimerView()
        case .nursing:
            historys = viewModel.nursingHistorys
        case .bottle:
            historys = viewModel.bottleHistorys
        case .pumping:
            historys = viewModel.pumpingHistorys
        case .diapers:
            historys = viewModel.diaperHistorys
        }
        tableView.reloadData()
    }

    private func updateMedicalDisclaimerView() {
        let tableViewContentHeight = viewModel.getCellsHeight(historys: historys)
        if tableViewContentHeight < viewContentHeight {
            guard tableView.tableFooterView != nil else { return }
            tableView.tableFooterView = nil
            view.addSubview(bottomView)
            bottomView.snp.remakeConstraints {
                $0.leading.bottom.trailing.equalToSuperview()
            }
        } else {
            guard tableView.tableFooterView == nil else { return }
            bottomView.removeFromSuperview()
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: UIDevice.width, height: 58))
            footerView.addSubview(bottomView)
            bottomView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            tableView.tableFooterView = footerView
        }
    }

    private func didTapToPresentViewController(model: Any) {
        switch model {
        case is TBNursingModel:
            guard let nursingModel = model as? TBNursingModel else { return }
            let manualAddEntryVC = TBNursingManualAddEntryViewController(type: .edit, nursingModel: nursingModel)
            manualAddEntryVC.eventTrackInteractionType = .history(type: TBAnalyticsManager.BabyTrackerType.nursing.recordType)
            AppRouter.shared.navigator.push(manualAddEntryVC)
        case is TBBottleModel:
            guard let bottleModel = model as? TBBottleModel else { return }
            let bottleVC = TBBottleEditViewController()
            bottleVC.bottleToolView.viewModel.defaultModel = bottleModel
            bottleVC.bottleToolView.resetUI()
            bottleVC.eventTrackInteractionType = .history(type: TBAnalyticsManager.BabyTrackerType.bottle.recordType)
            AppRouter.shared.navigator.push(bottleVC)
        case is TBPumpModel:
            guard let model = model as? TBPumpModel else { return }
            let pumpingVC = TBPumpingEditViewController()
            pumpingVC.pumpToolView.viewModel.defaultModel = model
            pumpingVC.pumpToolView.resetUI()
            pumpingVC.eventTrackInteractionType = .history(type: TBAnalyticsManager.BabyTrackerType.pumping.recordType)
            AppRouter.shared.navigator.push(pumpingVC)
        case is TBDiapersModel:
            guard let diapersModel = model as? TBDiapersModel else { return }
            let editDiapersVC = TBDiapersEditViewController()
            editDiapersVC.model = diapersModel
            editDiapersVC.eventTrackInteractionType = .history(type: TBAnalyticsManager.BabyTrackerType.diapers.recordType)
            AppRouter.shared.navigator.push(editDiapersVC)
        default:
            break
        }
    }

    private func trackDeleteInteractionEvent(model: TBFeedingTrackerModelProtocol) {
        var trackType: TBAnalyticsManager.BabyTrackerType = .nursing
        switch model {
        case is TBNursingModel:
            trackType = .nursing
        case is TBBottleModel:
            trackType = .bottle
        case is TBPumpModel:
            trackType = .pumping
        case is TBDiapersModel:
            trackType = .diapers
        default:
            break
        }
        TBAnalyticsManager.babyTrackerInteraction(type: .history(type: trackType.recordType), selectionType: .delete)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension TBHistoryViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        guard !historys.isEmpty else {
            return 1
        }
        return historys.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !historys.isEmpty else {
            return 1
        }
        return historys[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !historys.isEmpty else {
            if type == .all {
                let cell = tableView.dequeueReusableCell(TBAllEmptyHistoryTableViewCell.self, for: indexPath)
                cell.setupData()
                return cell
            } else {
                return tableView.dequeueReusableCell(TBFeedingTrackerHistoryEmptyCell.self, for: indexPath)
            }
        }
        let cell = tableView.dequeueReusableCell(TBFeedingTodayRecordCell.self, for: indexPath)
        cell.delegate = self
        cell.setupData(model: historys[indexPath.section][indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(TBFeedingTrackerHistoryHeaderView.self)
        var title = "Today"
        if let historys = historys[safe: section],
           let startTime = historys.first?.startTime,
           !startTime.isSameDayAs(otherDate: Date()) {
            title = startTime.convertToMMMdd()
        }
        view.setupTitle(title: title)
        return view
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !historys.isEmpty
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: UIContextualAction.Style.normal, title: "Delete") { [weak self] _, _, complete in
            guard let self = self else { return }
            self.tableView(tableView, deleteRecordForRowAt: indexPath)
            complete(true)
        }
        delete.backgroundColor = .validationRed
        let action = UISwipeActionsConfiguration(actions: [delete])
        action.performsFirstActionWithFullSwipe = false
        return action
    }

    private func tableView(_ tableView: UITableView, deleteRecordForRowAt indexPath: IndexPath) {
        let actionSheet = UIAlertController(title: "Are you sure you want to delete this data?",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let delete = UIAlertAction(title: "Delete",
                                   style: .destructive) { [weak self] _ in
            guard let self = self, let model = self.historys[safe: indexPath.section]?[safe: indexPath.row] else { return }
            self.viewModel.deleteModel(model: model)
            self.trackDeleteInteractionEvent(model: model)
        }
        actionSheet.addAction(delete)
        actionSheet.addAction(cancel)
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            let rect = tableView.rectForRow(at: indexPath)
            let point = tableView.convert(rect.origin, to: self.view)
            popoverController.sourceRect = CGRect(origin: CGPoint(x: UIScreen.width - 72, y: point.y), size: CGSize(width: 72, height: 52))
        }
        AppRouter.shared.navigator.present(actionSheet)
    }
}

// MARK: - TBFeedingTodayRecordCellDelegate
extension TBHistoryViewController: TBFeedingTodayRecordCellDelegate {
    func recordCell(_ cell: TBFeedingTodayRecordCell, didTapEdit model: Any) {
        didTapToPresentViewController(model: model)
    }
}

extension TBHistoryViewController {
    enum TBFeedingTrackerHistoryType {
        case nursing
        case bottle
        case pumping
        case diapers
        case all

        var toolType: FeedingTrackerToolType? {
            switch self {
            case .nursing:
                return FeedingTrackerToolType.nursing
            case .bottle:
                return FeedingTrackerToolType.bottle
            case .pumping:
                return FeedingTrackerToolType.pumping
            case .diapers:
                return FeedingTrackerToolType.diapers
            case .all:
                return nil
            }
        }
    }
}
