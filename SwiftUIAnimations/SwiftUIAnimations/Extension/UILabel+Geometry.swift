import UIKit

extension UILabel {

    /// Locate the index of the nearest character to a given point in an UILabel
    /// - parameter point: The point to locate the character near
    /// - returns: The index of the character, if present
    /// - note: This method only returns a value when `attributedText` has been set
    func indexOfAttributedTextCharacterAtPoint(point: CGPoint) -> Int? {
        guard let attributedText = attributedText else {
            return nil
        }
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: self.bounds.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = self.numberOfLines
        textContainer.lineBreakMode = self.lineBreakMode
        layoutManager.addTextContainer(textContainer)

        return layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
    }

}
