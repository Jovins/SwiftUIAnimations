import UIKit
import RxSwift

final class ContractionInfoViewController: UIViewController {
    private lazy var infoTableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.delegate = self
        view.dataSource = self
        view.register(TBContractionCounterInfoCell.self)
        view.separatorStyle = .none
        return view
    }()
    private let getStartedCTA: TBCommonButton = {
        let button = TBCommonButton()
        button.buttonState = .primary
        button.buttonHeight = 46
        if UIDevice.isPad() {
            button.buttonWidth = 420
        }
        button.setTitle("Get Started", for: .normal)
        return button
    }()
    private let resetBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .lapis100
        return view
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
    private lazy var modalView: TBModalView = TBModalView.build(content: "Please note: The Bump and the materials and information it contains are not intended to, and do not constitute, medical or other health advice or diagnosis and should not be used as such. You should always consult with a qualified physician or health professional about your specific circumstances.", ctaType: .medicalDisclaimer, delegate: nil)
    private var contentHeight: CGFloat {
        let cell = TBContractionCounterInfoCell()
        let size = cell.systemLayoutSizeFitting(CGSize(width: UIDevice.width, height: CGFloat.greatestFiniteMagnitude))
        return size.height
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.adjustMedicalDisclaimerLayout()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        screenViewed()
    }

    private func setupUI() {
        title = "About Contractions"
        view.backgroundColor = .GlobalBackgroundPrimary
        navigationController?.navigationBar.topItem?.backButtonTitle = ""

        [infoTableView, resetBackground].forEach(view.addSubview)
        resetBackground.addSubview(getStartedCTA)

        infoTableView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(resetBackground.snp.top)
        }
        resetBackground.snp.makeConstraints {
            $0.height.equalTo(100)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        getStartedCTA.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }

        if UIDevice.isPad() {
            resetBackground.snp.remakeConstraints {
                $0.leading.trailing.bottom.equalToSuperview()
                $0.height.equalTo(136)
            }
            getStartedCTA.snp.remakeConstraints {
                $0.center.equalToSuperview()
            }
        }

        medicalDisclaimerCTA.addTarget(self, action: #selector(didTapMedicalDisclaimerCTA), for: .touchUpInside)
        getStartedCTA.addTarget(self, action: #selector(getStartedAction), for: .touchUpInside)
    }

    @objc private func getStartedAction(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func didTapMedicalDisclaimerCTA(sender: UIButton) {
        modalView.show()
    }

    private func adjustMedicalDisclaimerLayout() {
        let tableViewHeight = self.infoTableView.frame.height
        if contentHeight + self.medicalDisclaimerView.frame.height > tableViewHeight {
            guard infoTableView.tableFooterView == nil else { return }
            medicalDisclaimerView.removeFromSuperview()
            let footerView = UIView(frame: .init(x: 0, y: 0, width: UIDevice.width, height: 66))
            footerView.addSubview(medicalDisclaimerView)
            medicalDisclaimerView.snp.makeConstraints {
                $0.edges.equalToSuperview()
                $0.height.equalTo(66)
            }
            infoTableView.tableFooterView = footerView
        } else {
            guard medicalDisclaimerView.superview != view else { return }
            infoTableView.tableFooterView = nil
            view.addSubview(medicalDisclaimerView)
            medicalDisclaimerView.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalTo(resetBackground.snp.top)
                $0.height.equalTo(66)
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ContractionInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TBContractionCounterInfoCell = tableView.dequeueReusableCell(TBContractionCounterInfoCell.self, for: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
