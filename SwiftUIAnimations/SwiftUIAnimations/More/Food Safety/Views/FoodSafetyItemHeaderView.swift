import UIKit

class FoodSafetyItemHeaderView: UITableViewHeaderFooterView {

    let itemDescriptionLabel = UILabel(frame: CGRect.zero)
    let itemDisclaimerTextView = UITextView(frame: CGRect.zero)
    let dividerView = UIView(frame: CGRect.zero)

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        contentView.backgroundColor = .GlobalBackgroundPrimary

        itemDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        itemDescriptionLabel.numberOfLines = 0
        contentView.addSubview(itemDescriptionLabel)

        itemDisclaimerTextView.translatesAutoresizingMaskIntoConstraints = false
        itemDisclaimerTextView.isEditable = false
        itemDisclaimerTextView.isScrollEnabled = false
        itemDisclaimerTextView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.GlobalTextPrimary]
        itemDisclaimerTextView.isSelectable = true
        itemDisclaimerTextView.backgroundColor = .GlobalBackgroundPrimary
        itemDisclaimerTextView.textContainerInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: -5)
        contentView.addSubview(itemDisclaimerTextView)

        dividerView.translatesAutoresizingMaskIntoConstraints = false
        dividerView.backgroundColor = .rgb216_216_216
        contentView.addSubview(dividerView)
        itemDescriptionLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(20)
        }
        itemDisclaimerTextView.snp.makeConstraints {
            $0.top.equalTo(itemDescriptionLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-25)
        }
        dividerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }

    func setup(details: String?, sourceDetails: String?, sourceText: String?, sourceURL: String?) {
        if let details = details {
            itemDescriptionLabel.attributedText = "Special Note: \(details)".attributedText(.mulishLink3,
                                                                                            alignment: .center,
                                                                                            lineBreakMode: .byWordWrapping)
        }

        itemDisclaimerTextView.text = ""

        var sourceString = ""
        if let sourceDetails = sourceDetails {
            if sourceDetails.count > 0 {
                sourceString = sourceString + " \(sourceDetails)"
            }
        }

        if let sourceText = sourceText {
            if sourceText.count > 0 {
                sourceString = sourceString + " \(sourceText)"
            }
        }

        var linkAttrs: [(String, [NSAttributedString.Key: Any])] = []
        if let sourceURL = sourceURL,
           let sourceText = sourceText,
           !sourceURL.trimmed.isEmpty,
           !sourceText.trimmed.isEmpty {
            linkAttrs = [sourceText.linkAttrs(fontType: .mulishLink4, url: sourceURL, showUnderline: true)]
        }
        if sourceString.count > 0 {
            sourceString = "Source:\r" + sourceString
            itemDisclaimerTextView.attributedText = sourceString.attributedText(.mulishLink3,
                                                                                alignment: .center,
                                                                                additionalAttrsArray: linkAttrs)
        }
    }
}
