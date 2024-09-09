import Foundation

extension NSAttributedString {
    var minimumWidth: CGFloat {
        let rect = self.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 22), options: .usesLineFragmentOrigin, context: nil)
        let width = ceil(rect.size.width ?? 0) + 40
        return width < 160 ? 160 : width
    }

    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        return ceil(self.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude),
                          options: .usesLineFragmentOrigin, context: nil).height)
    }

    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        return ceil(self.boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: height),
                          options: .usesLineFragmentOrigin, context: nil).width)
    }

    static func linkAttrsForUILabel(fontType: TBFontType, url: String, fontColor: UIColor = .GlobalTextPrimary) -> [NSAttributedString.Key: Any] {
        var links: [NSAttributedString.Key: Any] = [.font: fontType.font,
                                                    .foregroundColor: fontColor,
                                                    .underlineStyle: NSUnderlineStyle.single.rawValue,
                                                    .attachment: url]
        return links
    }
}
