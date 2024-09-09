import UIKit
import SnapKit
import RxSwift

final class TBKickCounterViewController: UIViewController {
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
    private let controlView: TBKickCounterControlView = {
        let view = TBKickCounterControlView()
        view.backgroundColor = .GlobalBackgroundPrimary
        return view
    }()
    private lazy var kicksTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(TBKickCounterTableViewCell.self)
        tableView.register(TBKickCounterHeaderView.self)
        tableView.register(TBKickCounterEmptyCell.self)
        return tableView
    }()
    private let historyView = TBKickCounterHistoryView()
    private let medicalDisclaimerCTA: UIButton = {
        let titleAttributedString = "Medical Disclaimer".attributedText(.mulishLink4, foregroundColor: .DarkGray600, additionalAttrsArray: [("Medical Disclaimer", [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])])
        let button = UIButton()
        button.setAttributedTitle(titleAttributedString, for: .normal)
        button.tb.expandTouchingArea(UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        return button
    }()
    private lazy var medicalDisclaimerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIDevice.width, height: 66))
        view.backgroundColor = .GlobalBackgroundPrimary
        view.addSubview(medicalDisclaimerCTA)
        medicalDisclaimerCTA.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(CGSize(width: 118, height: 18))
        }
        return view
    }()
    private let gradualView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.applyGradientMask(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: 50),
                               colors: [UIColor.OffWhite.withAlphaComponent(0).cgColor, UIColor.OffWhite.withAlphaComponent(1).cgColor],
                               startPoint: CGPoint(x: 1, y: 0),
                               endPoint: CGPoint(x: 1, y: 1),
                               locations: [0, 1])
        return view
    }()
    private let modalView = TBModalView.build(content: "Please note: The Bump and the materials and information it contains are not intended to, and do not constitute, medical or other health advice or diagnosis and should not be used as such. You should always consult with a qualified physician or health professional about your specific circumstances.", ctaType: .medicalDisclaimer)

    private let controlViewHeight: CGFloat = 542
    private var kicksTableViewHeaderHeight: CGFloat {
        UIDevice.isPad() ? 88 : 84
    }
    private var kicksTableViewHeight: CGFloat {
        var kickCounterModels = [TBKickCounterModel]()
        for section in 0..<kicksTableView.numberOfSections {
            if let models = viewModel.kickCounterModels[safe: section],
               !models.isEmpty,
               models.first?.startTime.isSameDayAs(otherDate: Date()) == true {
                kickCounterModels = models
                break
            }
        }
        kicksTableView.isScrollEnabled = !kickCounterModels.isEmpty
        gradualView.isHidden = kickCounterModels.count < 2 ? true : false
        let rowHeight: CGFloat = kickCounterModels.count < 2 ? 50 : 100
        return kicksTableViewHeaderHeight + rowHeight
    }
    private let medicalDisclaimerHeight: CGFloat = 66

    private let viewModel = TBKickCounterViewModel()
    private let disposeBag = DisposeBag()

    override var screenName: String? {
        return "Kick Counter Screen"
    }

    override var descriptionGA: String {
        return "Kick Counter Screen"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setNavigationItem()
        bindData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.viewModel.getKickCounter()
            self.historyView.getKickCounter()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        screenViewed()
        if !UserDefaults.standard.hasSeenKickCounter {
            UserDefaults.standard.hasSeenKickCounter = true
            modalView.show()
        }
    }

    private func setupUI() {
        navigationItem.title = "Kick Counter"
        view.backgroundColor = .GlobalBackgroundPrimary
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(UIDevice.width)
            $0.height.greaterThanOrEqualToSuperview()
        }
        [controlView, kicksTableView, medicalDisclaimerView, gradualView].forEach(contentView.addSubview)
        controlView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(controlViewHeight)
        }
        kicksTableView.snp.makeConstraints {
            $0.top.equalTo(controlView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(kicksTableViewHeight)
        }
        medicalDisclaimerView.snp.makeConstraints {
            $0.top.equalTo(kicksTableView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(medicalDisclaimerHeight)
            $0.bottom.equalToSuperview()
        }
        gradualView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
            $0.bottom.equalTo(kicksTableView)
        }
        medicalDisclaimerCTA.addTarget(self, action: #selector(didTapMedicalDisclaimerCTA), for: .touchUpInside)
    }

    private func updateKicksTableView() {
        let totalHeight = UIDevice.navigationBarHeight + controlViewHeight + kicksTableViewHeight + medicalDisclaimerHeight
        if totalHeight <= UIScreen.main.bounds.height {
            kicksTableView.snp.remakeConstraints {
                $0.top.equalTo(controlView.snp.bottom)
                $0.leading.trailing.equalToSuperview()
            }
            medicalDisclaimerView.snp.remakeConstraints {
                $0.top.equalTo(kicksTableView.snp.bottom)
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(medicalDisclaimerHeight)
                $0.bottom.equalToSuperview()
            }
        } else {
            kicksTableView.snp.remakeConstraints {
                $0.top.equalTo(controlView.snp.bottom)
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(kicksTableViewHeight)
            }
        }
    }

    private func bindData() {
        viewModel.kickCounterSubject.subscribeOn(MainScheduler.instance).subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.reloadData()
        }, onError: { _ in }).disposed(by: disposeBag)
    }

    private func reloadData() {
        self.kicksTableView.reloadData()
        self.updateKicksTableView()
    }

    private func setNavigationItem() {
        guard presentingViewController != nil else { return }
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: TBIconList.close.image(), style: .plain, target: self, action: #selector(didTapClose(sender:)))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: TBIconList.question.image(), style: .plain, target: self, action: #selector(didTapQuestion))
    }

    @objc private func didTapMedicalDisclaimerCTA() {
        modalView.show()
    }

    @objc private func didTapClose(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @objc private func didTapQuestion() {
        let aboutPageVC = TBKickCounterAboutPageViewController()
        aboutPageVC.delegate = self
        AppRouter.shared.navigator.push(aboutPageVC)
        TBAnalyticsManager.trackKickCounterInteraction(selection: .aboutPage)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension TBKickCounterViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let models = viewModel.kickCounterModels[safe: section],
              models.first?.startTime.isSameDayAs(otherDate: Date()) == true,
              !models.isEmpty else { return 1 }
        return models.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let models = viewModel.kickCounterModels[safe: indexPath.section],
              models.first?.startTime.isSameDayAs(otherDate: Date()) == true,
              let model = models[safe: indexPath.row] else {
            let cell = tableView.dequeueReusableCell(TBKickCounterEmptyCell.self, for: indexPath)
            cell.setup(text: "No Kicks Today")
            return cell
        }
        let cell = tableView.dequeueReusableCell(TBKickCounterTableViewCell.self, for: indexPath)
        cell.setup(model: model)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(TBKickCounterHeaderView.self)
        var displayViewHistory = false
        if viewModel.kickCounterModels.contains(where: { $0.contains(where: {!$0.startTime.isSameDayAs(otherDate: Date())})}) {
            displayViewHistory = true
        }
        view.setup(model: viewModel.kickCounterModels[safe: section]?.first, displayViewHistory: displayViewHistory, type: .viewHistory)
        view.delegate = self
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kicksTableViewHeaderHeight
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let models = viewModel.kickCounterModels[safe: indexPath.section],
              !models.isEmpty,
              models.first?.startTime.isSameDayAs(otherDate: Date()) == true else {
            return false
        }
        return true
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: UIContextualAction.Style.normal, title: "Delete") { [weak self] _, _, complete in
            guard let self = self else { return }
            self.tableView(tableView, deleteKickCounterForRowAt: indexPath)
            complete(true)
        }
        delete.backgroundColor = .validationRed
        let action = UISwipeActionsConfiguration(actions: [delete])
        action.performsFirstActionWithFullSwipe = false
        return action
    }

    private func tableView(_ tableView: UITableView, deleteKickCounterForRowAt indexPath: IndexPath) {
        guard let model = viewModel.kickCounterModels[safe: indexPath.section]?[safe: indexPath.row] else { return }
        let actionSheet = UIAlertController(title: "Are you sure you want to delete this kick session?",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let delete = UIAlertAction(title: "Delete",
                                   style: .destructive) {[weak self] _ in
            guard let self = self else { return }
            self.viewModel.deleteKickCounter(id: model.id)
            TBAnalyticsManager.trackKickCounterInteraction(selection: .delete)
        }
        actionSheet.addAction(delete)
        actionSheet.addAction(cancel)
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = view
            let rect = tableView.rectForRow(at: indexPath)
            let point = tableView.convert(rect.origin, to: self.view)
            popoverController.sourceRect = CGRect(origin: CGPoint(x: UIScreen.width - 72, y: point.y), size: CGSize(width: 72, height: 52))
        }
        AppRouter.shared.navigator.present(actionSheet)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView is UITableView else { return }
        let contentOffsetY = scrollView.contentOffset.y
        let bottomOffset = scrollView.contentSize.height - contentOffsetY
        if bottomOffset <= scrollView.frame.height {
            gradualView.isHidden = true
        } else {
            gradualView.isHidden = false
        }
    }
}

// MARK: - TBKickCounterHeaderViewDelegate
extension TBKickCounterViewController: TBKickCounterHeaderViewDelegate {
    func didTapViewHistory() {
        historyView.show(to: view)
        TBAnalyticsManager.trackKickCounterInteraction(selection: .kickHistory)
    }
}

extension TBKickCounterViewController: TBKickCounterAboutPageDelegate {
    func didTapStartAction() {
        historyView.dismiss()
    }
}
