import UIKit

final class TBFeedingTrackerAboutPageViewController: UIViewController {

    private var linkAttributedString: NSMutableAttributedString? {
        let additionalAttrsArray = ["Bottle Feeding Guide".linkAttrs(fontType: .mulishLink3, url: TBURLConstant.bottleFeedingURL, showUnderline: true),
                                    "Breast Feeding Guide".linkAttrs(fontType: .mulishLink3, url: TBURLConstant.breastFeedingURL, showUnderline: true),
                                    "Newborn and Baby Guide".linkAttrs(fontType: .mulishLink3, url: TBURLConstant.newbornBabyGuideURL, showUnderline: true),
                                    "Exclusive Pumping".linkAttrs(fontType: .mulishLink3, url: TBURLConstant.pumpingURL, showUnderline: true),
                                    "Combination Pumping".linkAttrs(fontType: .mulishLink3, url: TBURLConstant.combinePumpingURL, showUnderline: true),
                                    "How Much To Feed a Newborn".linkAttrs(fontType: .mulishLink3, url: TBURLConstant.feedNewbornURL, showUnderline: true),
                                    "Overfeeding".linkAttrs(fontType: .mulishLink3, url: TBURLConstant.overfeedingURL, showUnderline: true),
                                    "Baby Spit-up".linkAttrs(fontType: .mulishLink3, url: TBURLConstant.babySpitupURL, showUnderline: true),
                                    "Baby Poop 101".linkAttrs(fontType: .mulishLink3, url: TBURLConstant.babyPoopURL, showUnderline: true),
                                    "Baby Diarrhea".linkAttrs(fontType: .mulishLink3, url: TBURLConstant.babyDiarrheaURL, showUnderline: true)]

        let attributedString = "To learn more about these topics, you can visit these guides and articles. Visit The Bump’s Bottle Feeding Guide, Breast Feeding Guide and Newborn and Baby Guide. And read more about Exclusive Pumping, Combination Pumping, How Much To Feed a Newborn, Overfeeding, Baby Spit-up, Baby Poop 101, and Baby Diarrhea.".attributedText(.mulishBody3, additionalAttrsArray: additionalAttrsArray)
        return attributedString
    }
    private lazy var dataSoures: [(attributed: NSMutableAttributedString?, isTextLink: Bool)] = [
        ("The Bump’s Feeding Tracker is a tool to track baby’s feeding (nursing and bottle), pumping, and baby’s output.\n\nTo get started, choose the activity type. If you need to make a change to an activity, select the pencil next to that activity to edit available both at the bottom of each activity tab and in the History tab. To delete an activity you can choose delete from an edit activity screen or swipe left on that activity in the History tab.".attributedText(.mulishBody3), false),
        (linkAttributedString, true)
    ]
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(TBAboutPageTableViewCell.self)
        tableView.backgroundColor = .GlobalBackgroundPrimary
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        tableView.dataSource = self
        return tableView
    }()
    private let medicalDisclaimerView: TBMedicalDisclaimerView = TBMedicalDisclaimerView()
    private let medicalDisclaimerHeight: CGFloat = 66
    private var tableViewContentHeight: CGFloat {
        var cellHeight: CGFloat = 0
        dataSoures.forEach { datasource in
            let cell = TBAboutPageTableViewCell()
            cell.setupData(data: datasource)
            cellHeight += cell.contentView.systemLayoutSizeFitting(CGSize(width: UIDevice.width - 40, height: CGFloat.greatestFiniteMagnitude)).height
        }
        return cellHeight
    }
    private var tableViewHeight: CGFloat {
        UIScreen.main.bounds.height - UIDevice.navigationBarHeight - medicalDisclaimerHeight
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if TBMedicalDisclaimerDisplayHelper.shouldAutomaticallyShow(inPosition: .feedingTracker) {
            medicalDisclaimerView.show()
        }
    }

    private func setupUI() {
        view.backgroundColor = .GlobalBackgroundPrimary
        navigationItem.title = "How to Use the Feeding Tracker"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        setupFeedingTrackerLeftNavigationItem(model: TBFeedingTrackerNavigationBarModel(type: .back))
        [tableView].forEach(view.addSubview)
        tableView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(8)
        }

        if tableViewContentHeight < tableViewHeight {
            view.addSubview(medicalDisclaimerView)
            medicalDisclaimerView.snp.makeConstraints {
                $0.leading.trailing.bottom.equalToSuperview()
                $0.height.equalTo(medicalDisclaimerHeight)
            }
        } else {
            medicalDisclaimerView.frame = CGRect(origin: .zero, size: CGSize(width: UIDevice.width, height: medicalDisclaimerHeight))
            tableView.tableFooterView = medicalDisclaimerView
        }
    }
}

extension TBFeedingTrackerAboutPageViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSoures.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(TBAboutPageTableViewCell.self, for: indexPath)
        cell.setupData(data: dataSoures[indexPath.row])
        return cell
    }
}
