import UIKit
import RxSwift

final class TBWeightTrackerHistoryViewController: UIViewController {
    private let viewModel = TBWeightTrackerHistoryViewModel()
    private lazy var historyTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TBWeightTrackHeaderTableViewCell.self)
        tableView.register(TBWeightTrackerTableViewCell.self)
        tableView.separatorStyle = .none
        tableView.contentInsetAdjustmentBehavior = .never
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
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIDevice.width, height: medicalDisclaimerHeight))
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
    private let medicalDisclaimerHeight: CGFloat = 66
    private var contentHeight: CGFloat {
        var rowsHeight: CGFloat = 0
        for section in 0..<historyTableView.numberOfSections {
            for row in 0..<historyTableView.numberOfRows(inSection: section) {
                rowsHeight += historyTableView.rectForRow(at: IndexPath(row: row, section: section)).height
            }
        }
        return rowsHeight
    }

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindData()
        viewModel.getWeights()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        screenViewed()
    }

    private func setupUI() {
        title = "Weight History"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        view.backgroundColor = .GlobalBackgroundPrimary
        view.addSubview(historyTableView)
        historyTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        medicalDisclaimerCTA.addTarget(self, action: #selector(didTapMedicalDisclaimerCTA), for: .touchUpInside)
    }

    private func adjustMedicalDisclaimerLayout() {
        let tableViewHeight = historyTableView.frame.height - medicalDisclaimerHeight
        if contentHeight < tableViewHeight {
            guard medicalDisclaimerView.superview != view else { return }
            historyTableView.tableFooterView = nil
            view.addSubview(medicalDisclaimerView)
            medicalDisclaimerView.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalToSuperview()
                $0.height.equalTo(medicalDisclaimerHeight)
            }
        } else {
            guard historyTableView.tableFooterView == nil else { return }
            medicalDisclaimerView.removeFromSuperview()
            let footerView = UIView(frame: .init(x: 0, y: 0, width: UIDevice.width, height: medicalDisclaimerHeight))
            footerView.addSubview(medicalDisclaimerView)
            medicalDisclaimerView.snp.makeConstraints {
                $0.edges.equalToSuperview()
                $0.height.equalTo(medicalDisclaimerHeight)
            }
            historyTableView.tableFooterView = footerView
        }
    }

    private func bindData() {
        viewModel.weightsSubject.observeOn(MainScheduler.instance).subscribe {[weak self] _ in
            guard let self = self else { return }
            self.historyTableView.reloadData()
            DispatchQueue.main.async {
                self.adjustMedicalDisclaimerLayout()
            }
        } onError: { _ in

        }.disposed(by: disposeBag)
    }

    @objc private func didTapMedicalDisclaimerCTA() {
        modalView.show()
    }

    @objc private func didTapArchiveCTA() {
        viewModel.showArchivedData = !viewModel.showArchivedData
        viewModel.getWeights()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension TBWeightTrackerHistoryViewController: UITableViewDelegate, UITableViewDataSource {
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
            cell.hideTitle()
            return cell
        case .weight:
            let cell: TBWeightTrackerTableViewCell = tableView.dequeueReusableCell(TBWeightTrackerTableViewCell.self, for: indexPath)
            cell.delegate = self
            if let firstIndex = viewModel.cellTypes.firstIndex(where: { $0 == .weight}),
               let modelIndex = (indexPath.row - firstIndex) as? Int,
               let model = viewModel.weights[safe: modelIndex] {
                cell.setup(model: model, previousModel: viewModel.weights[safe: modelIndex + 1], showArchiveData: viewModel.showArchivedData)
            }
            if indexPath.row % 2 == 0 {
                cell.containerView.backgroundColor = .Beige
            } else {
                cell.containerView.backgroundColor = .GlobalBackgroundPrimary
            }
            return cell
        default:
            break
        }
        fatalError("Could not get cell for \(indexPath) in TBWeightTrackerHistoryViewController")
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch viewModel.cellTypes[indexPath.row] {
        case .weightListHeader:
            return 48
        default:
            return UITableView.automaticDimension
        }
    }
}

// MARK: - TBWeightTrackerTableViewCellDelegate
extension TBWeightTrackerHistoryViewController: TBWeightTrackerTableViewCellDelegate {
    func editAction(model: TBWeightTrackerModel) {
        let editVC = TBEditWeightTrackerViewController()
        editVC.delegate = self
        editVC.model = model
        AppRouter.shared.navigator.push(editVC)
        TBAnalyticsManager.trackWeightTrackerInteraction(selection: .editWeight)
    }

    func unarchiveAction(model: TBWeightTrackerModel) {
        TBWeightTrackerRepository.shared.editWeight(id: model.id, model: model)
    }
}

// MARK: - TBEditWeightTrackerViewControllerDelegate
extension TBWeightTrackerHistoryViewController: TBEditWeightTrackerViewControllerDelegate {

    func didFinishToEditWeight(message: String) {
        TBToastView().display(attributedText: message.attributedText(.mulishBody3, foregroundColor: .GlobalTextSecondary),
                              on: view)
    }
}
