import UIKit

final class TBAddWidgetViewController: UIViewController {

    private var widgetImageHeight: CGFloat {
        return UIDevice.width * 183 / 375
    }
    private var containerHeight: CGFloat {
        return min(468 + widgetImageHeight, UIDevice.height)
    }
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .GlobalBackgroundPrimary
        view.drawRoundedCorners(corners: [.topLeft, .topRight], size: CGSize(width: UIDevice.width, height: containerHeight), radius: 8)
        view.addShadow(with: UIColor.rgb084_084_084, alpha: 0.25, radius: 8, offset: CGSize(width: 0, height: -4))
        return view
    }()
    private let topLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.DarkGray300
        view.cornerRadius = 2
        return view
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "How to add a widget to your phone".attributedText(.mulishLink1)
        return label
    }()
    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Receive updates for both you and baby directly on your phone's screen using The Bump widget".attributedText(.mulishBody3)
        label.numberOfLines = 0
        return label
    }()
    private let widgetImageView: SDAnimatedImageView = {
        let imageView = SDAnimatedImageView()
        imageView.backgroundColor = .Beige
        imageView.contentMode = .scaleAspectFill
        imageView.cornerRadius = 4
        let path: String = Bundle.main.path(forResource: "Widget Gif", ofType: "gif") ?? ""
        let url = URL(fileURLWithPath: path)
        do {
            let gifData = try Data(contentsOf: url)
            imageView.image = SDAnimatedImage(data: gifData)
        } catch {
            print(error.localizedDescription)
        }
        return imageView
    }()
    private let stackViewStep1: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        let stackTitleLabel = UILabel()
        stackTitleLabel.attributedText = "Step 1:".attributedText(.mulishLink3)
        let stackSubtitleLabel = UILabel()
        stackSubtitleLabel.numberOfLines = 0
        stackSubtitleLabel.attributedText = "On your home screen, press and hold anywhere on the screen until your icons start to shake.".attributedText(.mulishBody3)
        [stackTitleLabel, stackSubtitleLabel].forEach(stack.addArrangedSubview)
        return stack
    }()
    private let stackViewStep2: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 1.2
        let stackTitleLabel = UILabel()
        stackTitleLabel.attributedText = "Step 2:".attributedText(.mulishLink3)
        let stackSubtitleLabel = UILabel()
        stackSubtitleLabel.numberOfLines = 0
        stackSubtitleLabel.attributedText = "Click the + in the top left corner and select The Bump from the widgets list.".attributedText(.mulishBody3)
        [stackTitleLabel, stackSubtitleLabel].forEach(stack.addArrangedSubview)
        return stack
    }()
    private let stackViewStep3: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        let stackTitleLabel = UILabel()
        stackTitleLabel.attributedText = "Step 3:".attributedText(.mulishLink3)

        let attachmentAttributedString = NSMutableAttributedString()
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = TBIconList.plugs.image()
        imageAttachment.bounds = CGRect(x: 0, y: -2, width: 16, height: 16)
        let imageAttributedString = NSAttributedString(attachment: imageAttachment)
        attachmentAttributedString.append(imageAttributedString)

        let trailingAttachment = NSTextAttachment(image: UIImage(color: .clear) ?? UIImage())
        trailingAttachment.bounds = CGRect(x: 0, y: -2, width: 3.4, height: 16)
        let trailingAttributed = NSAttributedString(attachment: trailingAttachment)
        attachmentAttributedString.append(trailingAttributed)

        let attributedString = "Select Add Widget.".attributedText(.mulishBody3, additionalAttrsArray: [("Add Widget.", [NSAttributedString.Key.font: TBFontType.mulishLink3.font])])
        attributedString?.insert(attachmentAttributedString, at: 7)

        let stackSubtitleLabel = UILabel()
        stackSubtitleLabel.numberOfLines = 0
        stackSubtitleLabel.attributedText = attributedString
        [stackTitleLabel, stackSubtitleLabel].forEach(stack.addArrangedSubview)
        return stack
    }()
    private let gotItCTA: UIButton = {
        let button = UIButton()
        button.setAttributedTitle("Got It".attributedText(.mulishLink2, additionalAttrsArray: [("Got It", [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])]), for: .normal)
        button.tb.expandTouchingArea(UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showContainerView()
    }

    private func setupUI() {
        view.backgroundColor = UIColor.GlobalBackgroundSecondary.withAlphaComponent(0.5)
        view.addSubview(containerView)
        containerView.frame = CGRect(origin: CGPoint(x: 0, y: UIDevice.height), size: CGSize(width: UIDevice.width, height: containerHeight))
        [topLine, titleLabel, contentStackView, stackViewStep3, gotItCTA].forEach(containerView.addSubview)
        topLine.snp.makeConstraints {
            $0.top.equalToSuperview().inset(8)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(CGSize(width: 44, height: 4))
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(topLine.snp.bottom).offset(13)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        widgetImageView.snp.makeConstraints {
            $0.height.equalTo(widgetImageHeight)
        }
        [subtitleLabel, widgetImageView, stackViewStep1, stackViewStep2].forEach(contentStackView.addArrangedSubview)
        contentStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        stackViewStep3.snp.makeConstraints {
            $0.top.equalTo(contentStackView.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        gotItCTA.snp.makeConstraints {
            $0.top.equalTo(stackViewStep3.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(CGSize(width: 44, height: 24))
        }
        gotItCTA.addTarget(self, action: #selector(didTapToDismiss), for: .touchUpInside)
    }

    private func showContainerView() {
        UIView.animate(withDuration: 0.25) {
            self.containerView.frame = CGRect(origin: CGPoint(x: 0, y: UIDevice.height - self.containerHeight),
                                              size: CGSize(width: UIDevice.width, height: self.containerHeight))
        }
    }

    @objc private func didTapToDismiss() {
        view.backgroundColor = UIColor.clear
        UIView.animate(withDuration: 0.25) {
            self.containerView.frame = CGRect(origin: CGPoint(x: 0, y: UIDevice.height),
                                              size: CGSize(width: UIDevice.width, height: self.containerHeight))
        } completion: { _ in
            self.dismiss(animated: true)
        }
    }
}
