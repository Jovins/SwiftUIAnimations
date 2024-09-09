import UIKit

class FoodSafetyItemRestrictionTableViewCell: UITableViewCell {

    let restrictionIconContainerView = UIView(frame: CGRect.zero)
    let restrictionIconImageView = UIImageView(frame: CGRect.zero)
    let restrictionTitleLabel = UILabel(frame: CGRect.zero)
    let restrictionDetailLabel = UILabel(frame: CGRect.zero)
    let restrictionDisclaimerTextView = UITextView(frame: CGRect.zero)
    let underLine = UIView(frame: CGRect.zero)

    var isLastCell = false {
        didSet {
            updateBottomSpaceStyle()
        }
    }
    var isFirstCell = true {
        didSet {
            updateTopSpaceStyle()
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        contentView.backgroundColor = .GlobalBackgroundPrimary

        restrictionIconContainerView.translatesAutoresizingMaskIntoConstraints = false
        restrictionIconContainerView.layer.cornerRadius = 18
        restrictionIconContainerView.layer.masksToBounds = true
        contentView.addSubview(restrictionIconContainerView)

        restrictionIconImageView.translatesAutoresizingMaskIntoConstraints = false
        restrictionIconImageView.contentMode = .scaleAspectFit
        restrictionIconContainerView.addSubview(restrictionIconImageView)

        restrictionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        restrictionTitleLabel.numberOfLines = 0
        contentView.addSubview(restrictionTitleLabel)

        restrictionDetailLabel.translatesAutoresizingMaskIntoConstraints = false
        restrictionDetailLabel.numberOfLines = 0
        contentView.addSubview(restrictionDetailLabel)

        restrictionDisclaimerTextView.translatesAutoresizingMaskIntoConstraints = false
        restrictionDisclaimerTextView.isEditable = false
        restrictionDisclaimerTextView.isScrollEnabled = false
        restrictionDisclaimerTextView.backgroundColor = .GlobalBackgroundPrimary
        restrictionDisclaimerTextView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.GlobalTextPrimary]
        restrictionDisclaimerTextView.isSelectable = true
        contentView.addSubview(restrictionDisclaimerTextView)
        underLine.translatesAutoresizingMaskIntoConstraints = false
        underLine.isHidden = true
        underLine.backgroundColor = .rgb216_216_216
        contentView.addSubview(underLine)
        restrictionIconContainerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(36)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(CGSize(width: 36, height: 36))
        }
        restrictionIconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(CGSize(width: 36, height: 36))
        }
        restrictionTitleLabel.snp.makeConstraints {
            $0.top.equalTo(restrictionIconContainerView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        restrictionDetailLabel.snp.makeConstraints {
            $0.top.equalTo(restrictionTitleLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        restrictionDisclaimerTextView.snp.makeConstraints {
            $0.top.equalTo(restrictionDetailLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-20)
        }
        underLine.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    func updateBottomSpaceStyle() {
        underLine.isHidden = isLastCell
    }
    func updateTopSpaceStyle() {
        restrictionIconContainerView.snp.updateConstraints {
            $0.top.equalToSuperview().offset(isFirstCell ? 22.5 : 37.5)
        }
    }

    func setup(imageURL: String?, placeholderImage: UIImage?, imageBackgroundHex: String?, title: String?, details: String?, sourceDetails: String?, sourceText: String?, sourceURL: String?) {
        if let imageBackgroundHex = imageBackgroundHex {
            restrictionIconContainerView.backgroundColor = UIColor(hex: imageBackgroundHex, alpha: 1)
        } else {
            restrictionIconContainerView.backgroundColor = .GlobalBackgroundPrimary
        }

        restrictionIconImageView.image = nil
        if let imageURL = imageURL {
            restrictionIconImageView.sd_setImage(with: URL(string: imageURL),
                                                 placeholderImage: placeholderImage,
                                                 options: .retryFailed)
        } else {
            restrictionIconImageView.image = placeholderImage
        }

        if let title = title {
            restrictionTitleLabel.attributedText = title.capitalizedWithoutPreposition.attributedText(.mulishLink2,
                                                                                                      alignment: .center)
        } else {
            restrictionTitleLabel.text = ""
        }

        restrictionDetailLabel.attributedText = details?.attributedText(.mulishBody3, alignment: .center)

        restrictionDisclaimerTextView.text = ""

        var sourceString = ""
        if let sourceDetails = sourceDetails, !sourceDetails.trimmed.isEmpty {
            sourceString = sourceString + " \(sourceDetails)"
        }

        if let sourceText = sourceText, !sourceText.trimmed.isEmpty {
            sourceString = sourceString + " \(sourceText)"
        }

        var linkAttrs: [(String, [NSAttributedString.Key: Any])] = []
        if sourceString.count > 0 {
            sourceString = "Source:\r" + sourceString
            if let sourceURL = sourceURL,
               let sourceText = sourceText,
               !sourceText.trimmed.isEmpty,
               !sourceURL.trimmed.isEmpty {
                linkAttrs = [sourceText.linkAttrs(fontType: .mulishLink4, url: sourceURL, showUnderline: true)]
            }

            restrictionDisclaimerTextView.attributedText = sourceString.attributedText(.mulishLink3,
                                                                                       alignment: .center,
                                                                                       additionalAttrsArray: linkAttrs)
        }
    }
}
