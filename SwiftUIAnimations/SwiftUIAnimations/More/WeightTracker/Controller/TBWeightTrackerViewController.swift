import UIKit
import SnapKit
import RxSwift

final class TBWeightTrackerViewController: UIViewController {
    private let currentWeekContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .Magenta
        return view
    }()
    private let currentWeekLabel: UILabel = UILabel()
    private let lastWeightLabel: UILabel = UILabel()
    private let settingContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .Beige
        return view
    }()
    private let addNewWeightButton: TBCommonButton = {
        let button = TBCommonButton(frame: .zero)
        button.setTitle("Add New Weight", for: .normal)
        button.setImage(TBIconList.plugs.image(sizeOption: .normal, color: .OffWhite), for: [.normal])
        button.buttonPosition = .right
        return button
    }()
    private let addNewWeightContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .Beige
        view.addShadow(with: .black, alpha: 0.08, radius: 8, offset: CGSize(width: 0, height: -3))
        return view
    }()
    private let settingButton: TBLinkButton = {
        let button = TBLinkButton()
        button.title = "Lbs. or Kg."
        button.image = TBIconList.settings.image()
        button.colorStyle = .black
        return button
    }()
    private let myDataButton: TBLinkButton = {
        let button = TBLinkButton()
        button.title = "My Data"
        button.colorStyle = .black
        return button
    }()
    private lazy var weightTrackTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TBWeightTrackHeaderTableViewCell.self)
        tableView.register(TBWeightTrackerTableViewCell.self)
        tableView.register(TBWeightTrackerViewAllTableViewCell.self)
        tableView.register(TBTotalWeightTableViewCell.self)
        tableView.register(TBWeightChartTableViewCell.self)
        tableView.separatorStyle = .none
        return tableView
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
            $0.top.equalToSuperview().inset(24)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(CGSize(width: 118, height: 18))
        }
        return view
    }()
    private let modalView = TBModalView.build(content: "Please note: The Bump and the materials and information it contains are not intended to, and do not constitute, medical or other health advice or diagnosis and should not be used as such. You should always consult with a qualified physician or health professional about your specific circumstances.", ctaType: .medicalDisclaimer)
    private let iCloudBackupModalView = TBModalView.build(ctaType: .iCloudBackup)
    private let viewModel = TBWeightTrackerViewModel()
    private let disposeBag = DisposeBag()
    private var addWeightVC: TBAddNewWeightViewController?

    private var contentHeight: CGFloat {
        var rowsHeight: CGFloat = 0
        for section in 0..<weightTrackTableView.numberOfSections {
            for row in 0..<weightTrackTableView.numberOfRows(inSection: section) {
                rowsHeight += weightTrackTableView.rectForRow(at: IndexPath(row: row, section: section)).height
            }
        }
        return rowsHeight
    }
    private var isUserPregnant: Bool {
        guard let memberData = TBMemberDataManager.shared.memberData else { return false }
        return memberData.isUserPregnant
    }
    private var medicalDisclaimerHeight: CGFloat {
        return isUserPregnant ? 66 : 42
    }
    private var addNewWeightTrackerHeight: CGFloat {
        return isUserPregnant ? 100 : 0
    }

    override var screenName: String? {
        return "Weight Tracker Page"
    }
    override var descriptionGA: String {
        return "Weight Tracker"
    }
    override var screenNameProperties: [String: Any]? {
        return [TBAnalyticsManager.analyticsKeyCount: TBWeightTrackerRepository.shared.weights.count,
                TBAnalyticsManager.analyticsKeyVisibleCount: TBWeightTrackerRepository.shared.weights.filter {$0.archived == false}.count]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updatedUnitType), name: TBNotificationConstant.didUpdateMetric, object: nil)
        setupUI()
        setNavigationItem()
        bindData()
        viewModel.getWeights()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        screenViewed()
        if !UserDefaults.standard.hasSeenWeightTrackeriCloud {
            UserDefaults.standard.hasSeenWeightTrackeriCloud = true
            iCloudBackupModalView.show { [weak self] in
                self?.autoShowMedicalDisclaimer()
            }
        } else {
            autoShowMedicalDisclaimer()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func autoShowMedicalDisclaimer() {
        if !UserDefaults.standard.hasSeenWeightTracker {
            UserDefaults.standard.hasSeenWeightTracker = true
            modalView.show()
        }
    }

    private func setupUI() {
        view.backgroundColor = .GlobalBackgroundPrimary
        setupHeader()
    }

    private func setupHeader() {
        lastWeightLabel.isHidden = true
        [currentWeekContainerView, settingContainerView, weightTrackTableView, addNewWeightContainerView].forEach(view.addSubview)
        [currentWeekLabel, lastWeightLabel].forEach(currentWeekContainerView.addSubview)
        [settingButton, myDataButton].forEach(settingContainerView.addSubview)
        addNewWeightContainerView.addSubview(addNewWeightButton)
        let stackView = UIStackView(arrangedSubviews: [currentWeekLabel, lastWeightLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        currentWeekContainerView.addSubview(stackView)
        let inset: CGFloat = isUserPregnant ? 20 : 16
        stackView.snp.makeConstraints {
            $0.leading.trailing.equalTo(currentWeekContainerView).inset(inset)
            $0.top.bottom.equalTo(currentWeekContainerView).inset(16)
        }
        currentWeekContainerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        currentWeekLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(stackView)
        }
        lastWeightLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(stackView)
        }
        settingContainerView.snp.makeConstraints {
            $0.top.equalTo(currentWeekContainerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }
        settingButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
            $0.size.equalTo(CGSize(width: 99, height: 24))
        }
        myDataButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
        }
        weightTrackTableView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(settingContainerView.snp.bottom)
            $0.bottom.equalTo(addNewWeightContainerView.snp.top)
        }
        addNewWeightContainerView.snp.makeConstraints {
            $0.height.equalTo(addNewWeightTrackerHeight)
            $0.bottom.leading.trailing.equalToSuperview()
        }
        addNewWeightButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(16)
        }
        addNewWeightButton.addTarget(self, action: #selector(didTapAddNewWeightTracker), for: .touchUpInside)
        settingButton.addTarget(self, action: #selector(didTapSetting(sender:)), for: .touchUpInside)
        myDataButton.addTarget(self, action: #selector(didTapQuestion), for: .touchUpInside)
        medicalDisclaimerCTA.addTarget(self, action: #selector(didTapMedicalDisclaimerCTA), for: .touchUpInside)
    }

    private func bindData() {
        viewModel.weightsSubject.observeOn(MainScheduler.instance).subscribe {[weak self] _ in
            guard let self = self else { return }
            self.updateHeader()
            if self.isUserPregnant && self.viewModel.weights.isEmpty {
                let vc = TBAddNewWeightViewController()
                self.addChild(vc)
                self.view.addSubview(vc.view)
                vc.view.snp.makeConstraints {
                    $0.top.equalTo(self.settingContainerView.snp.bottom)
                    $0.leading.trailing.bottom.equalToSuperview()
                }
                self.addWeightVC = vc
            } else {
                self.addWeightVC?.view.removeFromSuperview()
                self.addWeightVC = nil
                self.weightTrackTableView.reloadData()
                DispatchQueue.main.async {
                    self.adjustMedicalDisclaimerLayout()
                }
            }
            if self.viewModel.weights.isEmpty && !self.isUserPregnant {
                self.dismiss(animated: true) {
                    NotificationCenter.default.post(name: TBNotificationConstant.didDeleteAllWeightTrackerData, object: nil)
                }
            }
        } onError: { _ in

        }.disposed(by: disposeBag)
    }

    private func adjustMedicalDisclaimerLayout() {
        let tableViewHeight = weightTrackTableView.frame.height - medicalDisclaimerHeight
        if contentHeight < tableViewHeight {
            guard medicalDisclaimerView.superview != view else { return }
            weightTrackTableView.tableFooterView = nil
            view.addSubview(medicalDisclaimerView)
            medicalDisclaimerView.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalTo(addNewWeightContainerView.snp.top)
                $0.height.equalTo(medicalDisclaimerHeight)
            }
        } else {
            guard weightTrackTableView.tableFooterView == nil else { return }
            medicalDisclaimerView.removeFromSuperview()
            let footerView = UIView(frame: .init(x: 0, y: 0, width: UIDevice.width, height: medicalDisclaimerHeight))
            footerView.addSubview(medicalDisclaimerView)
            medicalDisclaimerView.snp.makeConstraints {
                $0.edges.equalToSuperview()
                $0.height.equalTo(medicalDisclaimerHeight)
            }
            weightTrackTableView.tableFooterView = footerView
        }
    }

    private func updateHeader() {
        if isUserPregnant {
            if let week = TBMemberDataManager.shared.memberData?.weeksInCurrentPregnancy {
                currentWeekLabel.attributedText = "You’re \(week) \("Week".pluralize(with: week)) Pregnant!".attributedText(.mulishTitle4, foregroundColor: .GlobalTextSecondary)
            }
        } else {
            currentWeekLabel.attributedText = "Pregnancy Weight Tracker History".attributedText(.mulishTitle4, foregroundColor: .GlobalTextSecondary)
        }

        if let model = viewModel.weights.first {
            lastWeightLabel.isHidden = false
            lastWeightLabel.attributedText = "Last Weight \(model.weightString) \(model.unitType)".attributedText(.mulishBody2, foregroundColor: .GlobalTextSecondary)
        } else {
            lastWeightLabel.isHidden = true
        }
    }

    @objc private func updatedUnitType() {
        if self.viewModel.weights.isEmpty {
            self.addWeightVC?.view.removeFromSuperview()
            self.addWeightVC = nil
            let vc = TBAddNewWeightViewController()
            self.addChild(vc)
            self.view.addSubview(vc.view)
            vc.view.snp.makeConstraints {
                $0.top.equalTo(self.settingContainerView.snp.bottom)
                $0.leading.trailing.bottom.equalToSuperview()
            }
            self.addWeightVC = vc
        } else {
            self.updateHeader()
            self.weightTrackTableView.reloadData()
        }
    }

    private func setNavigationItem() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        guard presentingViewController != nil else { return }
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: TBIconList.close.image(), style: .plain, target: self, action: #selector(didTapClose(sender:)))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: TBIconList.question.image(), style: .plain, target: self, action: #selector(didTapQuestion))
    }

    @objc private func didTapClose(sender: UIBarButtonItem) {
        guard let vc = addWeightVC, vc.addWeightTrackerView.shouldSaveWeightTracker else {
            dismiss(animated: true, completion: nil)
            return
        }
        let alertVC = UIAlertController(title: nil, message: "Changes have not been saved.\nDo you want to continue?", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "No", style: .cancel)
        alertVC.addAction(deleteAction)
        alertVC.addAction(cancelAction)
        if let popoverController = alertVC.popoverPresentationController {
            if let sender = sender as? UIBarButtonItem {
                popoverController.barButtonItem = sender
            } else if let sender = sender as? UIView {
                popoverController.sourceView = sender
                popoverController.sourceRect = sender.bounds
            }
            popoverController.permittedArrowDirections = [.down, .up]
        }
        AppRouter.shared.navigator.present(alertVC)
    }

    @objc private func didTapQuestion() {
        let aboutPageVC = TBWeightTrackerAboutPageViewController()
        AppRouter.shared.navigator.push(aboutPageVC)
    }

    @objc private func didTapAddNewWeightTracker() {
        let addNewWeightTrackerVC = TBAddNewWeightViewController()
        AppRouter.shared.navigator.push(addNewWeightTrackerVC)
        TBAnalyticsManager.trackWeightTrackerInteraction(selection: .addNewWeight)
    }

    @objc private func didTapSetting(sender: UIButton) {
        AppRouter.navigateToMyAccount(sourceType: ScreenAnalyticsSourceType.weightTracker)
    }

    @objc private func didTapMedicalDisclaimerCTA() {
        modalView.show()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension TBWeightTrackerViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellTypes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel.cellTypes[indexPath.row] {
        case .weightListHeader:
            let cell: TBWeightTrackHeaderTableViewCell = tableView.dequeueReusableCell(TBWeightTrackHeaderTableViewCell.self, for: indexPath)
            return cell
        case .weight:
            let cell: TBWeightTrackerTableViewCell = tableView.dequeueReusableCell(TBWeightTrackerTableViewCell.self, for: indexPath)
            cell.delegate = self
            if let firstIndex = viewModel.cellTypes.firstIndex(where: { $0 == .weight}),
               let modelIndex = (indexPath.row - firstIndex) as? Int,
               let model = viewModel.weights[safe: modelIndex] {
                cell.setup(model: model, previousModel: viewModel.weights[safe: modelIndex + 1])
            }
            if indexPath.row % 2 == 0 {
                cell.containerView.backgroundColor = .Beige
            } else {
                cell.containerView.backgroundColor = .GlobalBackgroundPrimary
            }
            return cell
        case .viewAll:
            let cell: TBWeightTrackerViewAllTableViewCell = tableView.dequeueReusableCell(TBWeightTrackerViewAllTableViewCell.self, for: indexPath)
            return cell
        case .totalWeight:
            let cell: TBTotalWeightTableViewCell = tableView.dequeueReusableCell(TBTotalWeightTableViewCell.self, for: indexPath)
            if let model = viewModel.weights.first {
                cell.setup(firstModel: model, lastModel: viewModel.weights.last)
            }
            return cell
        case .chart:
            let cell: TBWeightChartTableViewCell = tableView.dequeueReusableCell(TBWeightChartTableViewCell.self, for: indexPath)
            cell.delegate = self
            cell.setup(models: viewModel.weights)
            return cell
        }
        fatalError("Could not get cell for \(indexPath) in TBWeightTrackerViewController")
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch viewModel.cellTypes[indexPath.row] {
        case .viewAll:
            let vc = TBWeightTrackerHistoryViewController()
            AppRouter.shared.navigator.push(vc)
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - TBWeightTrackerTableViewCellDelegate
extension TBWeightTrackerViewController: TBWeightTrackerTableViewCellDelegate {
    func editAction(model: TBWeightTrackerModel) {
        let editVC = TBEditWeightTrackerViewController()
        editVC.delegate = self
        editVC.model = model
        AppRouter.shared.navigator.push(editVC)
        TBAnalyticsManager.trackWeightTrackerInteraction(selection: .editWeight)
    }
}

// MARK: - TBEditWeightTrackerViewControllerDelegate
extension TBWeightTrackerViewController: TBEditWeightTrackerViewControllerDelegate {

    func didFinishToEditWeight(message: String) {
        TBToastView().display(attributedText: message.attributedText(.mulishBody3, foregroundColor: .GlobalTextSecondary),
                              on: view, bottomSpacing: TBWeightTrackerRepository.shared.hasWeights ? 112 : 12)
    }
}

// MARK: - TBWeightChartTableViewCellDelegate
extension TBWeightTrackerViewController: TBWeightChartTableViewCellDelegate {
    func resetAll(sender: UIButton) {
        let popUpView = TBWeightTrackerDeleteAllPopUpView()
        popUpView.delegate = self
        popUpView.show()
    }
}

// MARK: - TBWeightTrackerDeleteAllPopUpViewDelegate
extension TBWeightTrackerViewController: TBWeightTrackerDeleteAllPopUpViewDelegate {
    func confirmToDeleteAllData() {
        self.viewModel.resetAll()
        TBAnalyticsManager.trackWeightTrackerInteraction(selection: .resetWeightTracker)
    }
}
