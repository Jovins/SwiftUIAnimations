import UIKit

final class TBFeedingTrackerUnitBarView: UIView {

    private let settingButton: TBLinkButton = {
        let button = TBLinkButton()
        button.title = "ml or oz."
        button.image = TBIconList.settings.image()
        button.colorStyle = .black
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        self.backgroundColor = .Beige
        settingButton.addTarget(self, action: #selector(didTapSetting(sender:)), for: .touchUpInside)
        addSubview(settingButton)
        settingButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
            $0.size.equalTo(CGSize(width: 91, height: 24))
        }
    }

    @objc private func didTapSetting(sender: UIButton) {
        AppRouter.navigateToMyAccount()
    }

}
