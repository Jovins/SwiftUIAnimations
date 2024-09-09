import UIKit

protocol FoodSafetyCategoryDetailHeaderDelegate: class {
    func actionButtonDidTap()
    func linkDidTap(_ URL: URL)
}

final class FoodSafetyCategoryDetailHeaderView: UIView {
    private var fullContentsHeight = 0
    private let shortContentHeight = 290
    private let leftGap = 20
    weak var delegate: FoodSafetyCategoryDetailHeaderDelegate?
    private var isExpaned: Bool = false
    let foodCategory: TBFoodSafetyCategory
    let detailsTextViewGradient = CAGradientLayer()
    private let topImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    private let detailLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    private let actionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setAttributedTitle("Show More".attributedText(.mulishLink3, foregroundColor: .Magenta), for: .normal)
        button.setAttributedTitle("Show Less".attributedText(.mulishLink3, foregroundColor: .Magenta), for: .selected)
        button.setImage(TBIconList.caretDown.image(sizeOption: .small,
                                                   color: .Magenta), for: .normal)
        button.setImage(TBIconList.caretUp.image(sizeOption: .small,
                                                 color: .Magenta), for: .selected)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        button.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        button.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        button.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        return button
    }()
    init(with foodCategory: TBFoodSafetyCategory) {
        self.foodCategory = foodCategory
        super.init(frame: CGRect(x: 0,
                                  y: 0,
                                  width: Int(UIScreen.main.bounds.width),
                                  height: shortContentHeight))
        clipsToBounds = true
        backgroundColor = .GlobalBackgroundPrimary
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private var uiComponents = [UIView]()
    private let width = UIScreen.main.bounds.width
    private let textCalculateSize = CGSize(width: UIScreen.main.bounds.width-40, height: CGFloat(MAXFLOAT))
    private let imageHeight = 130
    private func setupUI() {
        setupCover()
        setupDetailContent()
        setupSourceContent()
        uiComponents.forEach {
            addSubview($0)
        }
        setupAdvisoriesContent()
        setupGradient()
        fullContentsHeight += 60
        if UIDevice.isPad() {
            didTapActionButton()
        }
    }
    private func  setupCover() {
        topImageView.frame = CGRect(x: 0, y: 0, width: Int(width), height: imageHeight)
        if let imageURL = foodCategory.imageUrl, let categoryImageURL = URL(string: imageURL) {
            topImageView.sd_setImage(with: categoryImageURL)
        }
        uiComponents.append(topImageView)
        fullContentsHeight += imageHeight
    }
    private func setupDetailContent() {
        fullContentsHeight += 12
        detailLabel.attributedText = foodCategory.description?.trimmed.attributedText(.mulishBody3,
                                                                                  lineBreakMode: .byWordWrapping,
                                                                                  paragraphSpacing: 8)
        var size = detailLabel.sizeThatFits(textCalculateSize)
        detailLabel.frame = CGRect(x: leftGap,
                                   y: fullContentsHeight,
                                   width: Int(width)-leftGap*2,
                                   height: Int(size.height))
        uiComponents.append(detailLabel)
        fullContentsHeight += Int(size.height)
        fullContentsHeight += 16
    }
    private func setupSourceContent() {
        guard let sources = foodCategory.sources, !sources.isEmpty else {
            return
        }
        let titleLabel = UILabel()
        titleLabel.attributedText = "Source:".attributedText(.mulishLink3, lineBreakMode: .byWordWrapping)
        var size = titleLabel.sizeThatFits(textCalculateSize)
        titleLabel.frame = CGRect(x: leftGap, y: fullContentsHeight, width: Int(width)-leftGap*2, height: Int(size.height))
        uiComponents.append(titleLabel)
        fullContentsHeight += Int(size.height)
        for source in sources {
            guard let sourceName = source.sourceName, let sourceUrl = source.sourceUrl else { continue }
            var linkAttrs: [(String, [NSAttributedString.Key: Any])] = [sourceName.linkAttrs(fontType: .mulishLink4, url: sourceUrl, showUnderline: true)]
            let textView = UITextView()
            textView.delegate = self
            textView.isScrollEnabled = false
            textView.isEditable = false
            textView.textContainerInset = UIEdgeInsets.zero
            textView.attributedText = sourceName.attributedText(.mulishLink4,
                                                                lineBreakMode: .byWordWrapping,
                                                                additionalAttrsArray: linkAttrs)
            textView.linkTextAttributes = [.foregroundColor: UIColor.GlobalTextPrimary, .underlineStyle: NSUnderlineStyle.single.rawValue]
            let tmpsize = textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.width-20, height: CGFloat(MAXFLOAT)))
            textView.frame = CGRect(x: leftGap-5, y: fullContentsHeight, width: Int(width)-(leftGap-10)*2, height: Int(tmpsize.height))
            fullContentsHeight += Int(tmpsize.height)
            uiComponents.append(textView)
        }
        fullContentsHeight += 24
    }
    private func setupAdvisoriesContent() {
        let advisoriesTitleLabel = UILabel()
        advisoriesTitleLabel.attributedText = "Advisories:".attributedText(.mulishLink3, paragraphSpacingBefore: 20)
        var size = advisoriesTitleLabel.sizeThatFits(textCalculateSize)
        advisoriesTitleLabel.frame = CGRect(x: leftGap, y: fullContentsHeight, width: Int(width)-leftGap*2, height: Int(size.height))
        fullContentsHeight += Int(size.height)

        let iconCookBackgroundView = UIView()
        iconCookBackgroundView.backgroundColor = UIColor.DarkGray600
        iconCookBackgroundView.cornerRadius = 10
        let iconLimitBackgroundView = UIView()
        iconLimitBackgroundView.backgroundColor = UIColor.DarkGray600
        iconLimitBackgroundView.cornerRadius = 10
        let iconPasteurizeBackgroundView = UIView()
        iconPasteurizeBackgroundView.backgroundColor = UIColor.DarkGray600
        iconPasteurizeBackgroundView.cornerRadius = 10

        let iconCook = UIImageView(image: TBIconList.cookCircle.image(color: .SunFlower))
        let iconLimit = UIImageView(image: TBIconList.limitCircle.image(color: .SunFlower))
        let iconPasteurize = UIImageView(image: TBIconList.pasteurizeCircle.image(color: .SunFlower))

        let titleCook = UILabel()
        titleCook.attributedText = "Cook".attributedText(.mulishBody3)
        let titleLimit = UILabel()
        titleLimit.attributedText = "Limit".attributedText(.mulishBody3)
        let titlePasteurize = UILabel()
        titlePasteurize.attributedText = "Pasteurize".attributedText(.mulishBody3)
        [advisoriesTitleLabel, iconCookBackgroundView, iconLimitBackgroundView, iconPasteurizeBackgroundView,
         iconCook, iconLimit, iconPasteurize, titleCook, titleLimit, titlePasteurize].forEach {
            addSubview($0)
        }
        iconCook.snp.makeConstraints {
            $0.left.equalToSuperview().offset(leftGap)
            $0.top.equalTo(advisoriesTitleLabel.snp.bottom).offset(4)
            $0.size.equalTo(CGSize(width: 24, height: 24))
        }
        iconCookBackgroundView.snp.makeConstraints {
            $0.center.equalTo(iconCook)
            $0.size.equalTo(20)
        }
        titleCook.snp.makeConstraints {
            $0.left.equalTo(iconCook.snp.right).offset(4)
            $0.centerY.equalTo(iconCook)
        }
        iconLimit.snp.makeConstraints {
            $0.left.equalTo(titleCook.snp.right).offset(24)
            $0.centerY.equalTo(iconCook)
            $0.size.equalTo(CGSize(width: 24, height: 24))
        }
        iconLimitBackgroundView.snp.makeConstraints {
            $0.center.equalTo(iconLimit)
            $0.size.equalTo(20)
        }
        titleLimit.snp.makeConstraints {
            $0.left.equalTo(iconLimit.snp.right).offset(4)
            $0.centerY.equalTo(iconCook)
        }
        iconPasteurize.snp.makeConstraints {
            $0.left.equalTo(titleLimit.snp.right).offset(24)
            $0.top.equalTo(advisoriesTitleLabel.snp.bottom).offset(4)
            $0.size.equalTo(CGSize(width: 24, height: 24))
        }
        iconPasteurizeBackgroundView.snp.makeConstraints {
            $0.center.equalTo(iconPasteurize)
            $0.size.equalTo(20)
        }
        titlePasteurize.snp.makeConstraints {
            $0.left.equalTo(iconPasteurize.snp.right).offset(4)
            $0.centerY.equalTo(iconCook)
        }
        fullContentsHeight += 28
    }
    private func setupGradient() {
        let gradientBG = UIView()
        gradientBG.backgroundColor = .GlobalBackgroundPrimary
        addSubview(gradientBG)
        gradientBG.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(100)
        }
        detailsTextViewGradient.frame = CGRect(x: 0, y: 0, width: Int(width), height: 100)
        detailsTextViewGradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        detailsTextViewGradient.locations = [0.0, UIDevice.isPad() ? 0.7 : 0.65]
        gradientBG.layer.mask = detailsTextViewGradient
        addSubview(actionButton)
        actionButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-16)
        }
        actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
    }
    @objc private func didTapActionButton() {
        isExpaned = !isExpaned
        actionButton.isSelected = isExpaned
        detailsTextViewGradient.isHidden = isExpaned
        frame = CGRect(x: 0,
                       y: 0,
                       width: Int(UIScreen.main.bounds.width),
                       height: isExpaned ? fullContentsHeight : shortContentHeight)
        delegate?.actionButtonDidTap()
    }
}

extension FoodSafetyCategoryDetailHeaderView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        delegate?.linkDidTap(URL)
        return false
    }
}
