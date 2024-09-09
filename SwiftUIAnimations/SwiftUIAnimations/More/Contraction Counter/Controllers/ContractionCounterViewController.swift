import UIKit
import SnapKit

final class ContractionCounterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let tableView = UITableView()
    private let ctaBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .Powder
        return view
    }()
    private let ctaButton: ContractionCounterCTA = {
        let button = ContractionCounterCTA(type: .start)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        return button
    }()
    private let timeLabel = UILabel()
    private let ctaLabel = UILabel()
    private lazy var headerView = ContractionCounterHeaderView(frame: CGRect(x: 0, y: 0, width: 400, height: headerHeight))
    private var headerHeight: CGFloat {
        return UIDevice.isPad() ? 90 : 72
    }
    private let emptyView = UIView()
    private let emptyLabel = UILabel()
    private let overlayView: UIView = {
        let view = UIView()
        view.applyGradientMask(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 36)),
                               colors: [UIColor.OffWhite.withAlphaComponent(0).cgColor, UIColor.OffWhite.withAlphaComponent(1).cgColor],
                               startPoint: .zero,
                               endPoint: CGPoint(x: 0, y: 1),
                               locations: [0, 1])
        return view
    }()
    private let endSessionCTA: TBLinkButton = {
        let button = TBLinkButton()
        button.title = "End Session"
        button.colorStyle = .black
        if UIDevice.isPad() {
            button.contentStyle = .medium
        }
        return button
    }()
    private lazy var modalView: TBModalView = TBModalView.build(content: "Please note: The Bump and the materials and information it contains are not intended to, and do not constitute, medical or other health advice or diagnosis and should not be used as such. You should always consult with a qualified physician or health professional about your specific circumstances.", ctaType: .medicalDisclaimer, delegate: nil)
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
    private var contentHeight: CGFloat {
        let sectionHeaderHeight: CGFloat = CGFloat(tableView.numberOfSections) * ContractionCounterSectionHeaderView.preferedHeight
        var rowsHeight: CGFloat = 0
        for section in 0..<tableView.numberOfSections {
            for row in 0..<tableView.numberOfRows(inSection: section) {
                rowsHeight += tableView.rectForRow(at: IndexPath(row: row, section: section)).height
            }
        }
        return sectionHeaderHeight + rowsHeight
    }
    private let timeFormatter = DateFormatter()
    private let dateFormatter = DateFormatter()

    private let ctaBackgroundHeight = 150
    private var contractionCounterTimer: Timer?

    private var sections = [(name: String, contractions: [Contraction])]()

    override var descriptionGA: String { "contraction counter" }
    override var screenName: String? { "contraction counter" }

    override func viewDidLoad() {
        super.viewDidLoad()
        ContractionDataManager.shared.readContractions()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        screenViewed()
        if !UserDefaults.standard.hasOpenedContractionCounter {
            UserDefaults.standard.hasOpenedContractionCounter = true
            modalView.show()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    private func setupUI() {
        title = "CONTRACTION COUNTER".capitalizedWithoutPreposition
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .medium

        dateFormatter.dateFormat = "MMM d"

        let closeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        closeButton.setImage(TBIconList.close.image(sizeOption: .normal), for: .normal)
        closeButton.addTarget(self, action: #selector(closeTouched), for: .touchUpInside)
        let closeIcon = UIBarButtonItem(customView: closeButton)
        self.navigationItem.rightBarButtonItem = closeIcon

        let helpButton = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        helpButton.setImage(TBIconList.question.image(), for: .normal)
        helpButton.addTarget(self, action: #selector(showInfoVC), for: .touchUpInside)
        let helpIcon = UIBarButtonItem(customView: helpButton)
        self.navigationItem.leftBarButtonItem = helpIcon

        // setup table view
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ContractionTableViewCell.self)
        tableView.register(ContractionCounterSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: String(describing: ContractionCounterSectionHeaderView.self))
        tableView.register(UITableViewCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.separatorStyle = .none
        tableView.layoutMargins = .zero
        view.addSubview(tableView)

        tableView.tableHeaderView = headerView

        emptyView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.backgroundColor = .GlobalBackgroundPrimary
        emptyView.alpha = 0
        view.addSubview(emptyView)

        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        let emptyFont: TBFontType = UIDevice.isPad() ? .mulishBody1 : .mulishBody2
        emptyLabel.attributedText = "No contractions yet.".attributedText(emptyFont, alignment: .center)
        emptyView.addSubview(emptyLabel)

        view.addSubview(ctaBackground)
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: ctaBackground.topAnchor).isActive = true

        emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        emptyView.topAnchor.constraint(equalTo: view.topAnchor, constant: headerView.height()).isActive = true
        emptyView.bottomAnchor.constraint(equalTo: ctaBackground.topAnchor).isActive = true

        emptyLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        emptyLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true

        [timeLabel, ctaLabel, ctaButton, endSessionCTA].forEach(ctaBackground.addSubview)

        ctaButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(46)
            $0.bottom.equalToSuperview().inset(36)
        }
        ctaLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.bottom.equalTo(ctaButton.snp.top).offset(-12)
            $0.centerX.equalToSuperview()
        }
        ctaBackground.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(127)
        }
        ctaButton.backgroundColor = .GlobalCTAPrimary
        ctaButton.layer.cornerRadius = 4
        ctaButton.layer.borderWidth = 1
        ctaButton.layer.borderColor = UIColor.OffWhite.cgColor
        ctaButton.addTarget(self, action: #selector(toggleContraction), for: .touchUpInside)
        endSessionCTA.addTarget(self, action: #selector(endSessionAction), for: .touchUpInside)
        view.addSubview(overlayView)
        overlayView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(36)
            $0.bottom.equalTo(ctaBackground.snp.top)
        }
        medicalDisclaimerCTA.addTarget(self, action: #selector(didTapMedicalDisclaimerCTA), for: .touchUpInside)

        startContractionCounterTimer()

        updateCTA()
        updateHeader()
    }

    private func loadData() {
        self.sections = ContractionDataManager.shared.sections
        tableView.reloadData()
        DispatchQueue.main.async {
            self.adjustMedicalDisclaimerLayout()
        }
        updateEmptyView(animated: true)
    }

    private func getContractionItem(for indexPath: IndexPath) -> Contraction? {
        let section = sections[safe: indexPath.section]
        return section?.contractions[safe: indexPath.item]
    }

    private func adjustMedicalDisclaimerLayout() {
        let tableViewHeight = self.tableView.frame.height - headerHeight
        if contentHeight + self.medicalDisclaimerView.frame.height > tableViewHeight {
            guard tableView.tableFooterView == nil else { return }
            medicalDisclaimerView.removeFromSuperview()
            let footerView = UIView(frame: .init(x: 0, y: 0, width: UIDevice.width, height: 66))
            footerView.addSubview(medicalDisclaimerView)
            medicalDisclaimerView.snp.makeConstraints {
                $0.edges.equalToSuperview()
                $0.height.equalTo(66)
            }
            tableView.tableFooterView = footerView
        } else {
            guard medicalDisclaimerView.superview != view else { return }
            tableView.tableFooterView = nil
            view.addSubview(medicalDisclaimerView)
            medicalDisclaimerView.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalTo(ctaBackground.snp.top)
                $0.height.equalTo(66)
            }
        }
    }

    // MARK: Actions
    @objc private func didTapMedicalDisclaimerCTA(sender: UIButton) {
        modalView.show()
    }

    @objc func closeTouched() {
        dismiss(animated: true, completion: nil)
    }

    @objc func showInfoVC() {
        TBAnalyticsManager.logEventNamed(kAnalyticsEventContractionCounterInteraction,
                                         withProperties: ["selection": "learn more"])

        let infoVC = ContractionInfoViewController()
        AppRouter.shared.navigator.push(infoVC)
    }

    @objc func toggleContraction() {
        if ContractionDataManager.shared.inProgressContraction() != nil {
            TBAnalyticsManager.logEventNamed(kAnalyticsEventContractionCounterInteraction,
                                             withProperties: ["selection": "stop contraction"])

            ContractionDataManager.shared.stopCurrentContraction()
        } else {
            TBAnalyticsManager.logEventNamed(kAnalyticsEventContractionCounterInteraction,
                                             withProperties: ["selection": "start contraction"])

            ContractionDataManager.shared.startNewContraction()
            startContractionCounterTimer()
        }
        loadData()
        updateCTA()
        updateHeader()
    }

    @objc private func endSessionAction() {
        ContractionDataManager.shared.endSession()
        TBAnalyticsManager.logEventNamed(kAnalyticsEventContractionCounterInteraction,
                                         withProperties: ["selection": "end session"])
        loadData()
        updateCTA()
        updateHeader()
    }

    private func startContractionCounterTimer() {
        invalidateTimers()
        let timer = Timer(timeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            self.updateCTA()
            self.updateHeader()
        })
        contractionCounterTimer = timer
        RunLoop.current.add(timer, forMode: .common)
    }

    private func invalidateTimers() {
        contractionCounterTimer?.invalidate()
    }

    private func useDefaultConstraintsForCTA() {
        timeLabel.isHidden = true
        ctaLabel.isHidden = false
        endSessionCTA.isHidden = true
        let defaultToast = "Press “Start” when the contraction begins"
        let toastFont: TBFontType = UIDevice.isPad() ? .mulishLink2 : .mulishLink3
        ctaLabel.attributedText = defaultToast.attributedText(toastFont)
        ctaButton.setAttributedTitle("Start Contraction".attributedText(.mulishLink2,
                                                                        foregroundColor: .GlobalTextSecondary),
                                     for: .normal)
        ctaButton.type = .start
        ctaButton.snp.remakeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(46)
            $0.bottom.equalToSuperview().inset(36)
        }
        ctaLabel.snp.remakeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.bottom.equalTo(ctaButton.snp.top).offset(-12)
            $0.centerX.equalToSuperview()
        }
        ctaBackground.snp.remakeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(127)
        }
        if UIDevice.isPad() {
            ctaButton.snp.remakeConstraints {
                $0.size.equalTo(CGSize(width: 420, height: 40))
                $0.centerX.equalToSuperview()
                $0.bottom.equalToSuperview().inset(36)
            }
            ctaLabel.snp.remakeConstraints {
                $0.top.equalToSuperview().inset(20)
                $0.bottom.equalTo(ctaButton.snp.top).offset(-16)
                $0.centerX.equalToSuperview()
            }
            ctaBackground.snp.remakeConstraints {
                $0.bottom.leading.trailing.equalToSuperview()
                $0.height.equalTo(160)
            }
        }
    }

    private func useBeginningConstraintsForCTA() {
        timeLabel.isHidden = false
        ctaLabel.isHidden = false
        endSessionCTA.isHidden = false
        timeLabel.snp.remakeConstraints {
            $0.top.equalToSuperview().inset(8)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(CGSize(width: 84, height: 28))
        }
        ctaLabel.snp.remakeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(20)
        }
        ctaButton.snp.remakeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(46)
        }
        endSessionCTA.snp.remakeConstraints {
            $0.top.equalTo(ctaButton.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(CGSize(width: 85, height: 20))
        }
        ctaBackground.snp.remakeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(184)
        }
        if UIDevice.isPad() {
            timeLabel.snp.remakeConstraints {
                $0.top.equalToSuperview().inset(12)
                $0.centerX.equalToSuperview()
                $0.size.equalTo(CGSize(width: 102, height: 34))
            }
            ctaLabel.snp.remakeConstraints {
                $0.top.equalTo(timeLabel.snp.bottom).offset(16)
                $0.centerX.equalToSuperview()
                $0.height.equalTo(24)
            }
            ctaButton.snp.remakeConstraints {
                $0.top.equalTo(ctaLabel.snp.bottom).offset(12)
                $0.size.equalTo(CGSize(width: 420, height: 40))
                $0.centerX.equalToSuperview()
            }
            endSessionCTA.snp.remakeConstraints {
                $0.top.equalTo(ctaButton.snp.bottom).offset(18)
                $0.centerX.equalToSuperview()
                $0.size.equalTo(CGSize(width: 97, height: 24))
            }
            ctaBackground.snp.remakeConstraints {
                $0.bottom.leading.trailing.equalToSuperview()
                $0.height.equalTo(226)
            }
        }
    }

    private func useStopConstraintsForCTA() {
        timeLabel.isHidden = false
        ctaLabel.isHidden = true
        endSessionCTA.isHidden = false
        timeLabel.snp.remakeConstraints {
            $0.top.equalToSuperview().inset(8)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(CGSize(width: 84, height: 28))
        }
        ctaButton.snp.remakeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(46)
        }
        ctaBackground.snp.remakeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(167)
        }
        endSessionCTA.snp.remakeConstraints {
            $0.top.equalTo(ctaButton.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(CGSize(width: 85, height: 20))
        }
        if UIDevice.isPad() {
            timeLabel.snp.remakeConstraints {
                $0.top.equalToSuperview().inset(12)
                $0.centerX.equalToSuperview()
                $0.size.equalTo(CGSize(width: 102, height: 34))
            }
            ctaButton.snp.remakeConstraints {
                $0.top.equalTo(timeLabel.snp.bottom).offset(8)
                $0.size.equalTo(CGSize(width: 420, height: 40))
                $0.centerX.equalToSuperview()
            }
            endSessionCTA.snp.remakeConstraints {
                $0.top.equalTo(ctaButton.snp.bottom).offset(18)
                $0.centerX.equalToSuperview()
                $0.size.equalTo(CGSize(width: 97, height: 24))
            }
            ctaBackground.snp.remakeConstraints {
                $0.bottom.leading.trailing.equalToSuperview()
                $0.height.equalTo(182)
            }
        }
    }

    @objc func updateCTA() {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimumIntegerDigits = 2
        let toastFont: TBFontType = UIDevice.isPad() ? .mulishLink2 : .mulishLink3
        let timeFont: TBFontType = UIDevice.isPad() ? .mulishTitle3 : .mulishTitle4
        useDefaultConstraintsForCTA()
        guard !ContractionDataManager.shared.sessionEnds else { return }
        if ContractionDataManager.shared.inProgressContraction() == nil {
            let beginningToast = "since the beginning of last contraction"
            ctaButton.type = .start
            ctaButton.setAttributedTitle("Start Contraction".attributedText(.mulishLink2,
                                                                            foregroundColor: .GlobalTextSecondary),
                                         for: .normal)
            guard let secondsSince = ContractionDataManager.shared.timeSinceLastContraction(),
                  secondsSince < ContractionDataManager.shared.maxTimeBetween else {
                return
            }

            let timeString = Date.timeIntervalToString(timeInterval: Double(secondsSince)) ?? ""
            useBeginningConstraintsForCTA()
            timeLabel.attributedText = timeString.attributedText(timeFont,
                                                                 foregroundColor: .validationGreen,
                                                                 alignment: .left)
            ctaLabel.attributedText = beginningToast.attributedText(toastFont,
                                                                    alignment: .center)
        } else {
            let secondsSince = ContractionDataManager.shared.durationOfCurrentContraction()
            if secondsSince > ContractionDataManager.shared.maxDuration {
                deleteCurrentContraction()
                updateCTA()
                return
            }
            useStopConstraintsForCTA()
            ctaButton.type = .stop
            ctaButton.setAttributedTitle("Stop Contraction".attributedText(.mulishLink2,
                                                                           foregroundColor: .GlobalTextSecondary),
                                         for: .normal)
            let timeString = Date.timeIntervalToString(timeInterval: Double(secondsSince)) ?? ""
            timeLabel.attributedText = timeString.attributedText(timeFont,
                                                                 foregroundColor: .CornFlower,
                                                                 alignment: .left)
        }
    }

    private func updateHeader() {
        headerView.setup(totalDuration: ContractionDataManager.shared.totalDuration)
    }

    func updateEmptyView(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.1 : 0) {
            self.emptyView.alpha = self.sections.isEmpty ? 1 : 0
        }
    }

    // MARK: Tableview

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = sections[safe: section] else { return 0 }
        return sectionInfo.contractions.count
    }

    func titleForSection(section: Int) -> String {
        guard let sectionInfo = sections[safe: section] else { return "" }

        let todayString = ContractionDataManager.shared.dataString(from: Date())

        let dataString = sectionInfo.name

        let components = dataString.components(separatedBy: " ")
        guard components.count == 2 else {
            return ""
        }
        var dateString = components[0]
        var timeString = components[1]

        if let time = ContractionDataManager.shared.time(from: timeString) {
            timeString = time.convertTohhmmssa()
        } else {
            timeString = ""
        }

        if todayString == dateString {
            dateString = "Today"
        } else if let date = ContractionDataManager.shared.date(from: dateString) {
            dateString = dateFormatter.string(from: date).capitalized
        }

        return "\(dateString) Starting at \(timeString)"
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ContractionCounterSectionHeaderView.preferedHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: ContractionCounterSectionHeaderView.self)) as? ContractionCounterSectionHeaderView else {
            return ContractionCounterSectionHeaderView()
        }
        let font: TBFontType = UIDevice.isPad() ? .mulishLink3 : .mulishLink4
        header.titleLabel.attributedText = titleForSection(section: section).attributedText(font,
                                                                                            foregroundColor: .DarkGray600)
        header.clearButton.tag = section
        header.clearButton.addTarget(self, action: #selector(clearContractionsInSection), for: .touchUpInside)
        return header
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIDevice.isPad() ? 60 : 51
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ContractionTableViewCell.self, for: indexPath)
        guard let contraction = getContractionItem(for: indexPath) else {
            return ContractionTableViewCell()
        }
        let previousContraction = ContractionDataManager.shared.contractionBefore(contraction: contraction)
        cell.setup(contraction: contraction, previousContraction: previousContraction)
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: UIContextualAction.Style.normal, title: "Delete") { [weak self] _, _, complete in
            guard let self = self, let contraction = self.getContractionItem(for: indexPath) else { return }
            self.deleteContraction(contraction)
            complete(true)
        }
        delete.backgroundColor = .validationRed
        let action = UISwipeActionsConfiguration(actions: [delete])
        action.performsFirstActionWithFullSwipe = false
        return action
    }

    // MARK: Actions
    @objc func clearContractionsInSection(sender: UIButton) {
        let actionSheet = UIAlertController(title: "Are you sure you want to delete your contraction data?",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let delete = UIAlertAction(title: "Delete",
                                   style: .destructive) {[weak self] _ in
            guard let self = self else { return }
            guard let contractions = self.sections[safe: sender.tag]?.contractions as? [Contraction] else {
                return
            }
            ContractionDataManager.shared.delete(contractions: contractions)
            self.loadData()
        }
        actionSheet.addAction(delete)
        actionSheet.addAction(cancel)
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        AppRouter.shared.navigator.present(actionSheet)
    }

    private func deleteContraction(_ contraction: Contraction) {
        ContractionDataManager.shared.delete(contraction: contraction)
        loadData()
    }

    private func deleteCurrentContraction() {
        guard let currentContraction = ContractionDataManager.shared.inProgressContraction() else {
            return
        }
        deleteContraction(currentContraction)
    }
}

// MARK: - UIScrollViewDelegate
extension ContractionCounterViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard tableView.contentOffset.y >= (tableView.contentSize.height - tableView.frame.size.height) else {
            overlayView.isHidden = false
            return
        }
        overlayView.isHidden = true
    }
}

final class ContractionCounterSectionHeaderView: UITableViewHeaderFooterView {
    let titleLabel = UILabel()
    let clearButton: TBLinkButton = {
        let button = TBLinkButton()
        button.title = "Reset Counter"
        button.contentStyle = UIDevice.isPad() ? .small : .xsmall
        return button
    }()
    static let preferedHeight: CGFloat = UIDevice.isPad() ? 88 : 76
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .DarkGray200
        return view
    }()
    private let startTimeLabel: UILabel = UILabel()
    private let lengthLabel: UILabel = UILabel()
    private let frequencyLabel: UILabel = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    private func setupUI() {
        contentView.backgroundColor = .GlobalBackgroundPrimary
        let layoutGuide = UILayoutGuide()

        [titleLabel, clearButton, containerView].forEach(contentView.addSubview)
        [startTimeLabel, lengthLabel, frequencyLabel].forEach(containerView.addSubview)
        containerView.addLayoutGuide(layoutGuide)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(8)
            $0.height.equalTo(18)
            $0.leading.equalToSuperview().inset(20)
        }

        clearButton.snp.makeConstraints {
            $0.height.equalTo(UIDevice.isPad() ? 20 : 18)
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalTo(titleLabel)
        }

        containerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(UIDevice.isPad() ? 44 : 42)
            $0.bottom.equalToSuperview()
        }
        startTimeLabel.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 160, height: 16))
            $0.leading.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
        frequencyLabel.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 65, height: 16))
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
        layoutGuide.snp.makeConstraints {
            $0.leading.equalTo(startTimeLabel.snp.trailing)
            $0.trailing.equalTo(frequencyLabel.snp.leading)
        }
        lengthLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.size.equalTo(CGSize(width: 56, height: 16))
            $0.centerX.equalTo(layoutGuide)
        }
        let font: TBFontType = UIDevice.isPad() ? .mulishLink3 : .mulishLink4
        startTimeLabel.attributedText = "Start & Stop Time".attributedText(font)
        lengthLabel.attributedText = "Length".attributedText(font)
        frequencyLabel.attributedText = "Frequency".attributedText(font)

        if UIDevice.isPad() {
            titleLabel.snp.remakeConstraints {
                $0.top.equalToSuperview().inset(12)
                $0.height.equalTo(20)
                $0.centerX.equalToSuperview()
            }
            startTimeLabel.snp.remakeConstraints {
                $0.size.equalTo(CGSize(width: 182, height: 20))
                $0.leading.equalToSuperview().inset(110)
                $0.centerY.equalToSuperview()
            }
            lengthLabel.snp.remakeConstraints {
                $0.centerY.equalToSuperview()
                $0.size.equalTo(CGSize(width: 65, height: 20))
                $0.centerX.equalTo(layoutGuide)
            }
            frequencyLabel.snp.remakeConstraints {
                $0.size.equalTo(CGSize(width: 76, height: 20))
                $0.trailing.equalToSuperview().inset(110)
                $0.centerY.equalToSuperview()
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

final class ContractionTableViewCell: UITableViewCell {
    private let startTimeLabel = UILabel()
    private let lengthLabel = UILabel()
    private let frequencyLabel = UILabel()
    private let lineView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let superview else { return }
        for subview in superview.subviews where String(describing: subview).range(of: "UISwipeActionPullView") != nil {
            for view in subview.subviews where String(describing: view).range(of: "UISwipeActionStandardButton") != nil {
                for sub in view.subviews {
                    if let label = sub as? UILabel {
                        label.textColor = .OffWhite
                    }
                }
            }
        }
    }

    private func setupUI() {
        selectionStyle = .none
        let layoutGuide = UILayoutGuide()
        lineView.backgroundColor = .DarkGray200
        [startTimeLabel, lengthLabel, frequencyLabel, lineView].forEach(contentView.addSubview)
        contentView.addLayoutGuide(layoutGuide)
        startTimeLabel.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 162, height: 16))
            $0.leading.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
        frequencyLabel.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 65, height: 16))
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
        layoutGuide.snp.makeConstraints {
            $0.leading.equalTo(startTimeLabel.snp.trailing)
            $0.trailing.equalTo(frequencyLabel.snp.leading)
        }
        lengthLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.size.equalTo(CGSize(width: 56, height: 16))
            $0.centerX.equalTo(layoutGuide)
        }
        lineView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        if UIDevice.isPad() {
            startTimeLabel.snp.remakeConstraints {
                $0.size.equalTo(CGSize(width: 188, height: 20))
                $0.leading.equalToSuperview().inset(110)
                $0.centerY.equalToSuperview()
            }
            lengthLabel.snp.remakeConstraints {
                $0.centerY.equalToSuperview()
                $0.size.equalTo(CGSize(width: 65, height: 20))
                $0.centerX.equalTo(layoutGuide)
            }
            frequencyLabel.snp.remakeConstraints {
                $0.size.equalTo(CGSize(width: 76, height: 20))
                $0.trailing.equalToSuperview().inset(110)
                $0.centerY.equalToSuperview()
            }
        }
    }

    func setup(contraction: Contraction, previousContraction: Contraction?) {
        let startTimeString = contraction.startTime?.convertTohhmmssa() ?? ""
        var endTimeString = ""
        let font: TBFontType = UIDevice.isPad() ? .mulishBody3 : .mulishBody4
        if let endTime = contraction.endTime {
            endTimeString = endTime.convertTohhmmssa()
            startTimeLabel.attributedText = (startTimeString.lowercased() + " - " + endTimeString.lowercased()).attributedText(font)
            lengthLabel.attributedText = Date.timeIntervalToString(timeInterval: Double(contraction.duration ?? 0))?.attributedText(font)
        } else {
            endTimeString = "Counting"
            startTimeLabel.attributedText = (startTimeString.lowercased() + " - " + endTimeString).attributedText(font, additionalAttrsArray: [(endTimeString, [NSAttributedString.Key.foregroundColor: UIColor.DarkGray500])])
            lengthLabel.attributedText = endTimeString.attributedText(font, foregroundColor: .DarkGray500)
        }
        var frequencyString = ""
        if let previousContraction = previousContraction,
           let timeSince = contraction.timeSince(previousContraction: previousContraction) {
            if timeSince > 24 * 60 * 60 {
                frequencyString = "> 1 day"
            } else {
                frequencyString = Date.timeIntervalToString(timeInterval: Double(timeSince)) ?? ""
            }
        } else {
            frequencyString = "---"
        }
        frequencyLabel.attributedText = frequencyString.attributedText(font)
    }
}

final class ContractionCounterHeaderView: UIView {
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func setupUI() {
        backgroundColor = .Powder
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            let size = UIDevice.isPad() ? CGSize(width: 340, height: 36) : CGSize(width: 286, height: 34)
            $0.size.equalTo(size)
            $0.center.equalToSuperview()
        }
        setup(totalDuration: 0)
    }

    func setup(totalDuration: TimeInterval) {
        guard let timeString = Date.timeIntervalToString(timeInterval: totalDuration) else { return }
        let titleFont: TBFontType = UIDevice.isPad() ? .mulishTitle2 : .mulishTitle3
        titleLabel.attributedText = "Total duration: \(timeString)".attributedText(titleFont, alignment: .left)
    }
}

final class ContractionCounterCTA: UIButton {
    var type: CTAType {
        didSet {
            updateUI()
        }
    }

    override var isHighlighted: Bool {
        didSet {
            updateUI()
        }
    }

    init(type: CTAType) {
        self.type = type
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateUI() {
        switch type {
        case .start:
            backgroundColor = isHighlighted ? .PressCommonColor : .Navy
            setImage(TBIconList.start.image(color: .OffWhite), for: .normal)
            setImage(TBIconList.start.image(color: .OffWhite), for: .highlighted)
        case .stop:
            backgroundColor = isHighlighted ? .rgb174_047_051 : .rgb199_024_041
            setImage(TBIconList.stop.image(color: .OffWhite), for: .normal)
            setImage(TBIconList.stop.image(color: .OffWhite), for: .highlighted)
        }
    }
}

extension ContractionCounterCTA {
    enum CTAType {
        case start
        case stop
    }
}
