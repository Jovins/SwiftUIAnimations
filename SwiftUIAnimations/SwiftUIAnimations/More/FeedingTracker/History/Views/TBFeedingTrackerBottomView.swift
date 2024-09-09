import UIKit

final class TBFeedingTrackerBottomView: UIView {

    private let startCTA: TBCommonButton = {
        let button = TBCommonButton()
        button.isHidden = true
        return button
    }()
    private let medicalDisclaimerView: TBMedicalDisclaimerView = {
        let view = TBMedicalDisclaimerView()
        view.topInset = 0
        return view
    }()
    private let contentStackView: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()
    private var type: FeedingTrackerToolType?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .GlobalBackgroundPrimary
        addSubview(contentStackView)
        contentStackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(24)
        }
        medicalDisclaimerView.snp.makeConstraints {
            $0.height.equalTo(18)
        }
        [startCTA, medicalDisclaimerView].forEach(contentStackView.addArrangedSubview)
    }

    @objc private func didStartCTA() {
        guard let type else { return }
        AppRouter.navigateToFeedingTracker(with: type, action: .push, sourceType: ScreenAnalyticsSourceType.babyTracker)
    }

    func setButtonTitle(with type: FeedingTrackerToolType? = nil) {
        self.type = type
        guard let type else {
            startCTA.isHidden = true
            addShadow(with: UIColor.clear, alpha: 0.25, radius: 4, offset: CGSize(width: 0, height: -4))
            return
        }
        addShadow(with: UIColor.DarkGray400, alpha: 0.25, radius: 4, offset: CGSize(width: 0, height: -4))
        var title: String
        switch type {
        case .nursing:
            title = "Start a Nursing Session"
        case .bottle:
            title = "Start a Bottle Session"
        case .pumping:
            title = "Start a Pumping Session"
        case .diapers:
            title = "Add a Diaper Change"
        }
        startCTA.isHidden = false
        startCTA.buttonWidthStyle = .hug
        startCTA.buttonState = .primary
        startCTA.setImage(TBIconList.add.image(sizeOption: .normal, color: .OffWhite), for: [.normal])
        startCTA.setTitle(title, for: .normal)
        startCTA.addTarget(self, action: #selector(didStartCTA), for: .touchUpInside)
    }
}
