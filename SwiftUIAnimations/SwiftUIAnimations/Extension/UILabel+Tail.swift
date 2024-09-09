import Foundation

extension UILabel {
    /// add content to UIlabel at tail, please make sure line break mode is .byCharWrapping
    /// - Parameters:
    ///   - trailingText: like '...'
    ///   - moreText: like 'more'
    ///   - moreAttributedText: like 'more.attributedString', if this param not nil, it will instead of moreText
    ///   - moreTextColor: change moreText & moreAttributedText color
    func addTrailing(with trailingText: String,
                     moreText: String,
                     moreAttributedText: NSAttributedString? = nil,
                     moreTextColor: UIColor) {
        guard let text = self.text else { return }
        let readMoreText: String = trailingText + moreText
        let lengthForVisibleString: Int = self.vissibleTextLength
        let mutableString: String = text
        let trimmedString: String? = (mutableString as NSString).replacingCharacters(in: NSRange(location: lengthForVisibleString, length: ((text.count) - lengthForVisibleString)), with: "")
        guard let trimmed = trimmedString else { return }
        let readMoreLength: Int = (readMoreText.count)
        guard let trimmedForReadMore: String? = (trimmed as NSString).replacingCharacters(in: NSRange(location: (trimmed.count - readMoreLength), length: readMoreLength), with: "") + trailingText else { return }
        let answerAttributed = trimmedForReadMore?.attributedText(.mulishBody3, lineBreakMode: self.lineBreakMode)
        guard  let moreAttributedText = moreAttributedText else {
            guard let readMoreAttributed = moreText.attributedText(.mulishBody3, foregroundColor: moreTextColor, lineBreakMode: self.lineBreakMode) else { return }
            answerAttributed?.append(readMoreAttributed)
            self.attributedText = answerAttributed
            return
        }
        answerAttributed?.append(moreAttributedText)
        self.attributedText = answerAttributed
    }
    var vissibleTextLength: Int {
        guard let text = self.text else { return 0 }
        let labelWidth: CGFloat = self.frame.size.width
        let labelHeight: CGFloat = self.frame.size.height
        let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)
        let attributes = self.attributedText?.attributes(at: 0, effectiveRange: nil)
        guard let attributedText = self.attributedText else { return text.count }
        let boundingRect: CGRect = attributedRect(attributedText, sizeConstraint)
        if boundingRect.size.height > labelHeight {
            var index: Int = 0
            var prev: Int = 0
            let characterSet = CharacterSet.whitespacesAndNewlines
            var subAttributedStr: NSAttributedString
            repeat {
                prev = index
                index += 1
                subAttributedStr = (text as NSString).substring(to: index).attributedText(.mulishBody3, lineBreakMode: self.lineBreakMode) ?? NSAttributedString()
            } while index != NSNotFound &&
                    index < text.count &&
            attributedRect(subAttributedStr, sizeConstraint).size.height <= labelHeight
            return prev
        }
        return text.count
    }
    func attributedRect(_ attributedString: NSAttributedString?, _ sizeConstraint: CGSize) -> CGRect {
        guard let attributedString = attributedString else { return .zero }
        return attributedString.boundingRect(
            with: sizeConstraint,
            options: .usesLineFragmentOrigin,
            context: nil)
    }
}
