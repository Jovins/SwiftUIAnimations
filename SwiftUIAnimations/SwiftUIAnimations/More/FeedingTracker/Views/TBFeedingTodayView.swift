import UIKit
import RxSwift

final class TBFeedingTodayView: UIView {

    var updateTodayViewHeightSubject = PublishSubject<CGFloat>()
    private lazy var todayTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .OffWhite
        tableView.bounces = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(TBFeedingTodayRecordCell.self)
        tableView.register(TBFeedingTrackerEmptyCell.self)
        tableView.register(TBFeedingTrackerRecordHeaderView.self)
        return tableView
    }()
    private let disposeBag = DisposeBag()
    private var type: FeedingTrackerToolType = .nursing
    private var viewModel: TBFeedingTodayViewModel

    init(type: FeedingTrackerToolType = .nursing) {
        self.type = type
        viewModel = TBFeedingTodayViewModel(type: type)
        super.init(frame: .zero)
        setupUI()
        viewModel.updateTodaySubject.subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] shouldUpdate in
            guard shouldUpdate, let self = self else { return }
                self.todayTableView.reloadData()
                self.updateTodayTableView()
        }, onError: { _ in }).disposed(by: disposeBag)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func getData() {
        viewModel.getData()
    }

    func reloadData() {
        todayTableView.reloadData()
    }

    private func setupUI() {
        backgroundColor = .OffWhite
        [todayTableView].forEach(addSubview)
        todayTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func updateTodayTableView() {
        updateTodayViewHeightSubject.onNext(viewModel.tableViewHeight)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension TBFeedingTodayView: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !viewModel.todayModels.isEmpty else { return 1 }
        return viewModel.todayModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !viewModel.todayModels.isEmpty else {
            let cell = tableView.dequeueReusableCell(TBFeedingTrackerEmptyCell.self, for: indexPath)
            cell.setup(text: "No records yet")
            return cell
        }
        let cell = tableView.dequeueReusableCell(TBFeedingTodayRecordCell.self, for: indexPath)
        cell.delegate = self
        cell.setupData(model: viewModel.todayModels[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(TBFeedingTrackerRecordHeaderView.self)
        view.setup(title: "View All \(type.title) History", displayViewHistory: viewModel.displayViewHistory)
        view.delegate = self
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !viewModel.todayModels.isEmpty
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
            guard let self = self, !self.viewModel.todayModels.isEmpty else { return }
            self.viewModel.deleteModel(model: self.viewModel.todayModels[indexPath.row])
            self.trackInteractionEventWithDeleteAction()
        }
        actionSheet.addAction(delete)
        actionSheet.addAction(cancel)
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self
            let rect = tableView.rectForRow(at: indexPath)
            let point = tableView.convert(rect.origin, to: self)
            popoverController.sourceRect = CGRect(origin: CGPoint(x: UIScreen.width - 72, y: point.y), size: CGSize(width: 72, height: 52))
        }
        AppRouter.shared.navigator.present(actionSheet)
    }

    private func trackInteractionEventWithDeleteAction() {
        var trackType: TBAnalyticsManager.BabyTrackerType
        switch type {
        case .nursing:
            trackType = .nursing
        case .diapers:
            trackType = .diapers
        case .bottle:
            trackType = .bottle
        case .pumping:
            trackType = .pumping
        }
        TBAnalyticsManager.babyTrackerInteraction(type: trackType, selectionType: .delete)
    }
}

// MARK: - TBFeedingTodayRecordCellDelegate
extension TBFeedingTodayView: TBFeedingTodayRecordCellDelegate {

    func recordCell(_ cell: TBFeedingTodayRecordCell, didTapEdit model: Any) {
        switch type {
        case .nursing:
            guard let nursingModel = model as? TBNursingModel else { return }
            let manualAddEntryVC = TBNursingManualAddEntryViewController(type: .edit, nursingModel: nursingModel)
            AppRouter.shared.navigator.push(manualAddEntryVC)
        case .bottle:
            guard let bottleModel = model as? TBBottleModel else { return }
            let bottleVC = TBBottleEditViewController()
            bottleVC.bottleToolView.viewModel.defaultModel = bottleModel
            bottleVC.bottleToolView.resetUI()
            AppRouter.shared.navigator.push(bottleVC)
        case .pumping:
            guard let model = model as? TBPumpModel else { return }
            let pumpingVC = TBPumpingEditViewController()
            pumpingVC.pumpToolView.viewModel.defaultModel = model
            pumpingVC.pumpToolView.resetUI()
            AppRouter.shared.navigator.push(pumpingVC)
        case .diapers:
            guard let diapersModel = model as? TBDiapersModel else { return }
            let editDiapersVC = TBDiapersEditViewController()
            editDiapersVC.model = diapersModel
            AppRouter.shared.navigator.push(editDiapersVC)
        }
    }
}

// MARK: - TBFeedingTrackerRecordHeaderViewDelegate
extension TBFeedingTodayView: TBFeedingTrackerRecordHeaderViewDelegate {

    func didTapViewHistory() {
        var trackType: TBAnalyticsManager.BabyTrackerType
        var selectedIndex: Int = 0
        switch type {
        case .nursing:
            selectedIndex = 1
            trackType = .nursing
        case .bottle:
            selectedIndex = 2
            trackType = .bottle
        case .pumping:
            selectedIndex = 3
            trackType = .pumping
        case .diapers:
            selectedIndex = 4
            trackType = .diapers
        }
        AppRouter.navigateToFeedingTrackerHistory(selectedIndex: selectedIndex, action: .push, sourceType: ScreenAnalyticsSourceType.babyTracker)
        TBAnalyticsManager.babyTrackerInteraction(type: trackType, selectionType: .viewAllHistory)
    }
}
