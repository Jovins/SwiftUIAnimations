import UIKit

protocol FoodSafetyTermsTableViewCellDelegate: class {
    func didTapShowButtonToExpand()
}

final class FoodSafetyTermsTableViewCell: UITableViewCell {
    private let termsDescription = "Do not consider the information expressed here as medical advice. You should consult with your healthcare provider about your specific health needs (even if it’s something you have raed on this platform). You should always speak with your doctor before you start, stop, or change any part of your diet, care plan or treatment. This platform does not recommend or endorse any specific foods, tests, physicians, products, procedures, or other information that may be mentioned on or through this platform. For more information, please visit our Terms of Use."
    private let termsLinkText = "Terms of Use."
    weak var delegate: FoodSafetyTermsTableViewCellDelegate?
    var isExpaned = false
    private let topSpaceInset = CGFloat(8+4) // MARK: 4 means searchbar bottom white space
    private let topSpace = UIView()
    private var textView = UITextView()
    private let gradientBackgroundView = UIView()
    private let detailsTextViewGradient: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.frame = CGRect(x: 0.0, y: 0.0, width: UIDevice.width, height: 100.0)
        layer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        layer.locations = [0.0, UIDevice.isPad() ? 0.7 : 0.65]
        return layer
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
    private let bottomLine: UIView = {
        let line = UIView()
        line.backgroundColor = .DarkGray300
        return line
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func setupUI() {
        layoutMargins = .zero
        preservesSuperviewLayoutMargins = false
        separatorInset = .zero
        selectionStyle = .none
        backgroundColor = .Beige
        setupTopSpace()
        setupDesc()
        if !UIDevice.isPad() {
            setupGradientView()
        }
    }
    private func setupTopSpace() {
        topSpace.backgroundColor = .GlobalBackgroundPrimary
        contentView.addSubview(topSpace)
        topSpace.snp.updateConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(4)
        }
    }
    private func setupDesc() {
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = UIColor.clear
        textView.textContainerInset = .zero
        contentView.addSubview(textView)
        textView.delegate = self
        textView.textContainer.maximumNumberOfLines = UIDevice.isPad() ? 0 : 6
        let linkAttributes = [termsLinkText.linkAttrs(fontType: .mulishLink3, url: TBURLConstant.termsUrl, showUnderline: true)]
        let attributedStr = termsDescription
            .attributedText(
                .mulishBody3,
                additionalAttrsArray: linkAttributes)
        textView.attributedText = attributedStr
        textView.linkTextAttributes = [.foregroundColor: UIColor.GlobalTextPrimary, .underlineStyle: NSUnderlineStyle.single.rawValue]
        textView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: topSpaceInset,
                                                           left: 20,
                                                           bottom: UIDevice.isPad() ? 8 : 20,
                                                           right: 20))
        }
    }
    private func setupGradientView() {
        gradientBackgroundView.backgroundColor = .GlobalBackgroundPrimary
        gradientBackgroundView.isUserInteractionEnabled = false
        contentView.addSubview(gradientBackgroundView)
        gradientBackgroundView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(100)
        }
        gradientBackgroundView.layer.mask = detailsTextViewGradient
        gradientBackgroundView.addSubview(bottomLine)
        bottomLine.snp.makeConstraints {
            $0.bottom.left.right.equalToSuperview()
            $0.height.equalTo(1)
        }
        contentView.addSubview(actionButton)
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
        textView.textContainer.maximumNumberOfLines = isExpaned ? 0 : 6
        textView.invalidateIntrinsicContentSize()
        if isExpaned {
            textView.snp.remakeConstraints {
                $0.edges.equalToSuperview().inset(UIEdgeInsets(top: topSpaceInset, left: 20, bottom: 60, right: 20))
            }
        } else {
            textView.snp.remakeConstraints {
                $0.edges.equalToSuperview().inset(UIEdgeInsets(top: topSpaceInset, left: 20, bottom: 20, right: 20))
            }
        }
        textView.layoutIfNeeded()
        delegate?.didTapShowButtonToExpand()
    }
}

extension FoodSafetyTermsTableViewCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        AppRouter.navigateToBrowser(url: URL.absoluteString) { setting in
            setting.title = "TERMS OF USE"
            return setting
        }
        return false
    }
}
