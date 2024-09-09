import UIKit
import RxSwift

final class TBKickCounterHistoryView: UIView {

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .Powder
        label.attributedText = "No Kicks Today".attributedText(.mulishTitle3, alignment: .center)
        return label
    }()
    private(set) lazy var kickCounterTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(TBKickCounterTableViewCell.self)
        tableView.register(TBKickCounterHeaderView.self)
        tableView.register(TBKickCounterEmptyCell.self)
        return tableView
    }()
    private let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .Powder
        view.addShadow(with: .DarkGray400, alpha: 0.25, radius: 4, offset: CGSize(width: 0, height: -4))
        return view
    }()
    private let startCTA: TBCommonButton = {
        let button = TBCommonButton(frame: .zero)
        button.setTitle("Start New Session", for: .normal)
        button.setImage(TBIconList.start.image(sizeOption: .normal, color: .white), for: [.normal])
        button.buttonHeight = 46
        return button
    }()
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
    private lazy var modalView: TBModalView = {
        let view = TBModalView.build(content: "Please note: The Bump and the materials and information it contains are not intended to, and do not constitute, medical or other health advice or diagnosis and should not be used as such. You should always consult with a qualified physician or health professional about your specific circumstances.", ctaType: .medicalDisclaimer)
        return view
    }()
    private var headerHeight: CGFloat {
        UIDevice.isPad() ? 88 : 84
    }
    private var tableViewContentHeight: CGFloat {
        let sectionHeight: CGFloat = CGFloat(kickCounterTableView.numberOfSections) * headerHeight
        var rowHeight: CGFloat = 0
        for section in 0..<kickCounterTableView.numberOfSections {
            for row in 0..<kickCounterTableView.numberOfRows(inSection: section) {
                rowHeight += CGFloat(50)
            }
        }
        return sectionHeight + rowHeight
    }
    private var viewContentHeight: CGFloat {
        return UIScreen.main.bounds.height - UIDevice.navigationBarHeight - 248
    }
    private let viewModel: TBKickCounterHistoryViewModel
    private let disposeBag = DisposeBag()

    override init(frame: CGRect) {
        viewModel = TBKickCounterHistoryViewModel()
        super.init(frame: frame)
        setupUI()
        bindData()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .GlobalBackgroundPrimary
        [headerLabel, kickCounterTableView, bottomView].forEach(addSubview)
        bottomView.addSubview(startCTA)

        headerLabel.snp.makeConstraints {
            $0.height.equalTo(74)
            $0.leading.trailing.top.equalToSuperview()
        }
        kickCounterTableView.snp.makeConstraints {
            $0.top.equalTo(headerLabel.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomView.snp.top)
        }
        bottomView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(94)
        }
        startCTA.snp.remakeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalToSuperview().offset(24)
        }
        startCTA.addTarget(self, action: #selector(didTapStartNewSession), for: .touchUpInside)
        medicalDisclaimerCTA.addTarget(self, action: #selector(didTapMedicalDisclaimerCTA), for: .touchUpInside)
    }

    private func bindData() {
        viewModel.kickCounterSubject.subscribeOn(MainScheduler.instance).subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.updateHeader()
            self.kickCounterTableView.reloadData()
            DispatchQueue.main.async {
                self.updateMedicalDisclaimerView()
            }
        }, onError: { _ in }).disposed(by: disposeBag)
    }

    private func updateMedicalDisclaimerView() {
        if tableViewContentHeight < viewContentHeight {
            guard medicalDisclaimerView.superview != self else { return }
            kickCounterTableView.tableFooterView = nil
            addSubview(medicalDisclaimerView)
            medicalDisclaimerView.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalTo(bottomView.snp.top)
                $0.height.equalTo(66)
            }
        } else {
            guard kickCounterTableView.tableFooterView == nil else { return }
            medicalDisclaimerView.removeFromSuperview()
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: UIDevice.width, height: 66))
            footerView.addSubview(medicalDisclaimerView)
            medicalDisclaimerView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            kickCounterTableView.tableFooterView = footerView
        }
    }

    private func updateHeader() {
        var title = "No Kicks Today"
        if let models = viewModel.kickCounterModels.first,
           models.first?.startTime.isSameDayAs(otherDate: Date()) ?? false {
            let count = models.reduce(0) { sun, model in
                sun + model.kickCounterCount
            }
            if count > 0 {
                title = "\(count) \("Kick".pluralize(with: count)) Today"
            }
        }
        headerLabel.attributedText = title.attributedText(.mulishTitle3, alignment: .center)
    }

    @objc private func didTapMedicalDisclaimerCTA() {
        modalView.show()
    }

    @objc private func didTapStartNewSession() {
        dismiss(0.15)
    }

    func getKickCounter() {
        viewModel.getKickCounter()
    }

    func show(to view: UIView, duration: TimeInterval = 0.15) {
        alpha = 0
        view.addSubview(self)
        self.frame = view.bounds
        UIView.animate(withDuration: duration) {
            self.alpha = 1.0
        }
    }

    func dismiss(_ duration: TimeInterval = 0) {
        UIView.animate(withDuration: duration) {
            self.alpha = 0.0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension TBKickCounterHistoryView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard !viewModel.kickCounterModels.isEmpty else { return 1 }
        return viewModel.kickCounterModels.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let models = viewModel.kickCounterModels[safe: section],
              !models.isEmpty else { return 1 }
        return models.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = viewModel.kickCounterModels[safe: indexPath.section]?[safe: indexPath.row] else {
            let cell = tableView.dequeueReusableCell(TBKickCounterEmptyCell.self, for: indexPath)
            cell.setup(text: nil)
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
        view.setup(model: viewModel.kickCounterModels[safe: section]?.first, type: .resetCounter)
        view.delegate = self
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let models = viewModel.kickCounterModels[safe: indexPath.section],
              !models.isEmpty else {
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
            TBAnalyticsManager.trackKickCounterHistoryInteraction(selection: .delete)
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

}

// MARK: - TBKickCounterHeaderViewDelegate
extension TBKickCounterHistoryView: TBKickCounterHeaderViewDelegate {
    func didTapResetData(model: TBKickCounterModel?, sender: UIControl) {
        guard let model = model else { return }
        let actionSheet = UIAlertController(title: "Are you sure you want to delete today’s Kick Counter data?",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let delete = UIAlertAction(title: "Delete",
                                   style: .destructive) {[weak self] _ in
            guard let self = self else { return }
            self.viewModel.deleteKickCountersOfThisDay(date: model.startTime)
            TBAnalyticsManager.trackKickCounterHistoryInteraction(selection: .resetCounter)
        }
        actionSheet.addAction(delete)
        actionSheet.addAction(cancel)
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        AppRouter.shared.navigator.present(actionSheet)
    }
}
