import Foundation
import SnapKit
import UIKit

@objc final class TBCommunityWelcomeViewController: UIViewController {

    private let welcomeBackgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: UIDevice.isPad() ? "community_welcome_background_ipad" : "community_welcome_background"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private let phoneImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: UIDevice.isPad() ? "community_welcome_phone_ipad" : "community_welcome_phone"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .GlobalBackgroundPrimary
        view.addShadow(with: .black, alpha: 0.05, radius: 12, offset: CGSize(width: -1, height: -1))
        return view
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        let fontType: TBFontType = .mulishTitle1
        label.attributedText = "Welcome!".attributedText(fontType, alignment: .center)?.letterSpacing(-0.5)
        return label
    }()
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        let fontType: TBFontType = .mulishBody1
        label.attributedText = "The Bump Community is a place to share your experiences, dreams, and concerns with other Bump members who really understand what you’re going through.".attributedText(fontType, alignment: .center)
        return label
    }()
    private let exploreButton: TBCommonButton = {
        let button = TBCommonButton()
        button.buttonState = .primary
        button.buttonWidthStyle = .fixed
        button.setTitle("Explore Forums", for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        UIDevice.isPad() ? setupIpadUI() : setupIphoneUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    private func setupIphoneUI() {
        view.backgroundColor = .GlobalBackgroundPrimary
        let layout = UILayoutGuide()

        [welcomeBackgroundImageView, phoneImageView, bottomView].forEach(view.addSubview)
        [titleLabel, descriptionLabel, exploreButton].forEach(bottomView.addSubview)

        exploreButton.addTarget(self, action: #selector(exploreAction), for: .touchUpInside)

        view.addLayoutGuide(layout)
        welcomeBackgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        layout.snp.makeConstraints {
            $0.width.equalTo(1)
            $0.top.equalToSuperview()
            $0.bottom.equalTo(bottomView.snp.top)
        }
        phoneImageView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(52)
            $0.centerY.equalTo(layout)
        }
        bottomView.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(346)
            $0.leading.bottom.trailing.equalToSuperview()
        }
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(36)
            $0.height.equalTo(56)
        }
        descriptionLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
        }
        exploreButton.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(80)
            $0.bottom.equalToSuperview().inset(48)
        }
    }

    private func setupIpadUI() {
        view.backgroundColor = .GlobalBackgroundPrimary
        let layout = UILayoutGuide()

        [welcomeBackgroundImageView, phoneImageView, bottomView].forEach(view.addSubview)
        [titleLabel, descriptionLabel, exploreButton].forEach(bottomView.addSubview)

        exploreButton.addTarget(self, action: #selector(exploreAction), for: .touchUpInside)

        view.addLayoutGuide(layout)
        welcomeBackgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        bottomView.snp.makeConstraints {
            $0.height.equalTo(430)
            $0.leading.bottom.trailing.equalToSuperview()
        }
        layout.snp.makeConstraints {
            $0.width.equalTo(1)
            $0.top.equalToSuperview()
            $0.bottom.equalTo(bottomView.snp.top)
        }
        phoneImageView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(180)
            $0.centerY.equalTo(layout)
        }
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(64)
            $0.height.equalTo(70)
        }
        descriptionLabel.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 600, height: 102))
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(36)
        }
        exploreButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(220)
            $0.bottom.equalToSuperview().inset(64)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        bottomView.tb.addRoundedCorners(byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 36, height: 36))
    }

    @objc func exploreAction() {
        TBCommunityDataManager.sharedInstance().setUserHasSeenCommunityOnboarding()
        self.dismiss(animated: true, completion: nil)
    }
}
