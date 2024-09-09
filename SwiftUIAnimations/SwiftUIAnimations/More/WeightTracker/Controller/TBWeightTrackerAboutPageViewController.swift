import UIKit

final class TBWeightTrackerAboutPageViewController: UIViewController {

    private var linkAttributedString: NSMutableAttributedString? {
        let additionalAttrsArray = ["Weight Gain During Pregnancy".linkAttrs(fontType: .mulishLink3, url: TBURLConstant.weightGainURL, showUnderline: true),
                                    "American College of Obstetricians and Gynecologists".linkAttrs(fontType: .mulishLink3, url: TBURLConstant.weightGainWebURL, showUnderline: true)]
        let attributedString = "You can read Weight Gain During Pregnancy for more information on what to expect and find additional information from the American College of Obstetricians and Gynecologists (ACOG).".attributedText(.mulishBody3, additionalAttrsArray: additionalAttrsArray)
        return attributedString
    }
    private var importantNoteAttributedString: NSMutableAttributedString? {
        let additionalAttrsArray = ["this help article".linkAttrs(fontType: .mulishLink3, url: TBURLConstant.enablingiCloudBackUp, showUnderline: true)]
        let attributedString = "Your data privacy is our top priority. All weight information you enter is saved on your phone. To ensure you do not lose any historical information please make sure your iCloud backup is enabled for The Bump. You can learn more about enabling iCloud back up for The Bump App in this help article.".attributedText(.mulishBody3, additionalAttrsArray: additionalAttrsArray)
        return attributedString
    }
    private lazy var dataSoures: [(attributed: NSMutableAttributedString?, isTextLink: Bool)] = [
        ("\nImportant Note:".attributedText(.mulishLink3), false),
        (importantNoteAttributedString, true),
        ("\nDescription:".attributedText(.mulishLink3), false),
        ("The Bump’s Weight Tracker is a tool you can use to track your weight gain during pregnancy. To start, enter your current weight into the tracker. You can also log earlier weights by entering past dates. Each time you weigh yourself enter your updated weight on The Bump app to keep a record of your progress.\n\nTo edit or delete an entry, tap the pencil in the Weight History table. To delete all of your weight entries and start over, select \"Delete All Weight Tracker Data\" located under the Weight Gain Chart.\n\nConsult your doctor for clear guidance on what your weight-gain goals should be, based on your starting weight, BMI and any additional medical factors. Don’t worry if your weight gain fluctuates a bit from week to week, but contact your doctor if you suddenly gain or lose weight, especially in the third trimester.\n".attributedText(.mulishBody3), false),
        (linkAttributedString, true)
    ]
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(TBAboutPageTableViewCell.self)
        tableView.backgroundColor = .GlobalBackgroundPrimary
        tableView.separatorStyle = .none
        tableView.dataSource = self
        return tableView
    }()
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .Beige
        view.addShadow(with: UIColor.DarkGray400, alpha: 0.25, radius: 4, offset: CGSize(width: 0, height: -4))
        return view
    }()
    private let startCTA: TBCommonButton = {
        let title: String = "Get Started"
        let button = TBCommonButton()
        button.buttonWidthStyle = .stretch
        button.setTitle(title, for: .normal)
        return button
    }()
    private let medicalDisclaimerCTA: UIButton = {
        let titleAttributedString = "Medical Disclaimer".attributedText(.mulishLink4, foregroundColor: .DarkGray600, additionalAttrsArray: [("Medical Disclaimer", [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])])
        let button = UIButton()
        button.setAttributedTitle(titleAttributedString, for: .normal)
        button.tb.expandTouchingArea(UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        return button
    }()
    private let modalView = TBModalView.build(content: "Please note: The Bump and the materials and information it contains are not intended to, and do not constitute, medical or other health advice or diagnosis and should not be used as such. You should always consult with a qualified physician or health professional about your specific circumstances.", ctaType: .medicalDisclaimer)

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
        UIScreen.main.bounds.height - UIDevice.navigationBarHeight - medicalDisclaimerHeight - 100
    }
    private let medicalDisclaimerHeight: CGFloat = 66

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        screenViewed()
    }

    private func setupUI() {
        view.backgroundColor = .GlobalBackgroundPrimary
        navigationItem.title = "About The Weight Tracker"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        [tableView, containerView].forEach(view.addSubview)
        containerView.addSubview(startCTA)
        containerView.snp.makeConstraints {
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(8)
            $0.bottom.equalTo(containerView.snp.top)
        }
        startCTA.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.centerX.equalToSuperview()
        }

        if tableViewContentHeight < tableViewHeight {
            let footerView: UIView = UIView()
            footerView.backgroundColor = .GlobalBackgroundPrimary
            view.addSubview(footerView)
            footerView.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalTo(containerView.snp.top)
                $0.height.equalTo(medicalDisclaimerHeight)
            }
            footerView.addSubview(medicalDisclaimerCTA)
            medicalDisclaimerCTA.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.bottom.equalToSuperview().inset(24)
                $0.size.equalTo(CGSize(width: 118, height: 18))
            }
        } else {
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: UIDevice.width - 28, height: medicalDisclaimerHeight))
            tableView.tableFooterView = footerView
            footerView.addSubview(medicalDisclaimerCTA)
            medicalDisclaimerCTA.snp.makeConstraints {
                $0.centerX.equalToSuperview().offset(-6)
                $0.bottom.equalToSuperview().inset(24)
                $0.size.equalTo(CGSize(width: 118, height: 18))
            }
        }
        startCTA.addTarget(self, action: #selector(didTapStart), for: .touchUpInside)
        medicalDisclaimerCTA.addTarget(self, action: #selector(didTapMedicalDisclaimerCTA), for: .touchUpInside)
    }

    @objc private func didTapStart() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func didTapMedicalDisclaimerCTA() {
        modalView.show()
    }
}

// MARK: - UITableViewDataSource
extension TBWeightTrackerAboutPageViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSoures.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(TBAboutPageTableViewCell.self, for: indexPath)
        cell.setupData(data: dataSoures[indexPath.row])
        return cell
    }
}
