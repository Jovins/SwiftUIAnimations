import UIKit

protocol TBKickCounterAboutPageDelegate: AnyObject {
    func didTapStartAction()
}

final class TBKickCounterAboutPageViewController: UIViewController {
    private var linkAttributedString: NSMutableAttributedString? {
        let attributedString = "Read How to Do Kick Counts to learn more about what to know and what your doctor might recommend.".attributedText(.mulishBody3, additionalAttrsArray: ["How to Do Kick Counts".linkAttrs(fontType: .mulishLink3, url: TBURLConstant.howToDoKickCounter, showUnderline: true)])
        return attributedString
    }
    private lazy var dataSoures: [(attributed: NSMutableAttributedString?, isTextLink: Bool)] = [
        ("The Bump's Kick Counter is a tool you can use to track baby's kicks as you enter your third trimester. There are several methods doctors may use to perform kick counts—and there’s no one “best” method. Talk to your doctor about the method you should use and the frequency.\n\nTo start a session, tap the feet each time you feel baby kick. To stop the session, tap Finish. Today’s Kicks log will show the number of kicks and the length of time of the session. To see kick sessions from previous days, select View Kicks History.\n\nHelpful tips: if you start a session accidentally, you can tap Reset to clear the current session. Swipe left to remove a session from today’s or the history kick log.\n".attributedText(.mulishBody3), false),
        (linkAttributedString, true)
    ]
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(TBAboutPageTableViewCell.self)
        tableView.backgroundColor = .GlobalBackgroundPrimary
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
        return tableView
    }()
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .Powder
        view.addShadow(with: UIColor.DarkGray400, alpha: 0.25, radius: 4, offset: CGSize(width: 0, height: -4))
        return view
    }()
    private let startCTA: TBCommonButton = {
        let button = TBCommonButton()
        button.setTitle("Get Started", for: .normal)
        button.buttonWidthStyle = .fixed
        button.buttonWidth = UIDevice.isPad() ? 420 : UIDevice.width - 40
        button.setImage(TBIconList.start.image(), for: [.normal, .highlighted, .disabled])
        return button
    }()
    private let medicalDisclaimerCTA: UIButton = {
        let titleAttributedString = "Medical Disclaimer".attributedText(.mulishLink4, foregroundColor: .DarkGray600, additionalAttrsArray: [("Medical Disclaimer", [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])])
        let button = UIButton()
        button.setAttributedTitle(titleAttributedString, for: .normal)
        button.tb.expandTouchingArea(UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        return button
    }()
    private lazy var modalView: TBModalView = {
        let view = TBModalView.build(content: "Please note: The Bump and the materials and information it contains are not intended to, and do not constitute, medical or other health advice or diagnosis and should not be used as such. You should always consult with a qualified physician or health professional about your specific circumstances.", ctaType: .medicalDisclaimer, delegate: self)
        return view
    }()

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
        UIScreen.main.bounds.height - UIDevice.navigationBarHeight - medicalDisclaimerHeight - 108
    }
    private let medicalDisclaimerHeight: CGFloat = 66
    weak var delegate: TBKickCounterAboutPageDelegate?

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
        navigationItem.title = "How to Use the Kick Counter"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        [tableView, containerView].forEach(view.addSubview)
        containerView.addSubview(startCTA)
        containerView.snp.makeConstraints {
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(108)
        }
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(8)
            $0.bottom.equalTo(containerView.snp.top)
        }
        startCTA.snp.makeConstraints {
            $0.top.equalToSuperview().inset(24)
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
        delegate?.didTapStartAction()
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapMedicalDisclaimerCTA() {
        modalView.show()
    }
}

// MARK: - UITableViewDataSource
extension TBKickCounterAboutPageViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSoures.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(TBAboutPageTableViewCell.self, for: indexPath)
        cell.setupData(data: dataSoures[indexPath.row])
        return cell
    }
}

// MARK: - TBModalViewDelegate
extension TBKickCounterAboutPageViewController: TBModalViewDelegate {
    func didTapBottomCTA(_ modal: TBModalView, actionString: String?) {
        guard let url = URL(string: TBURLConstant.howToDoKickCounter) else { return }
        AppRouter.navigateToDeepLinkUrl(url)
        modalView.dismiss()
    }
}
