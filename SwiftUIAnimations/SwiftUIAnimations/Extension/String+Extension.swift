import Foundation
import UIKit
extension String {
    func regularization(of string: String) -> String? {
        let tempString = self as NSString
        let range = tempString.range(of: string, options: .regularExpression, range: NSRange(location: 0, length: tempString.length))

        guard range.length != 0 else { return nil }
        let newString = tempString.substring(with: range)
        return newString
    }

    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }

    func deletingSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        return String(self.dropLast(suffix.count))
    }

    func deletingBothEndsCharacters(_ characters: String) -> String {
        let newString = deletingPrefix(characters)
        guard newString.hasSuffix(characters)  else { return newString }
        return String(newString.dropLast(characters.count))
    }

    func dropSuffixSymbol() -> String {
        let suffixSymbolList = ["?", "!", "."]
        guard suffixSymbolList.first(where: {hasSuffix($0)}) != nil else { return self }
        return String(self.dropLast())
    }

    func convertHtml() -> NSAttributedString {
        guard let data = data(using: .utf8) else {
            return NSAttributedString()
        }

        do {
            return try NSAttributedString(data: data,
                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }

    func convertToAttributedString(_ font: UIFont, color: UIColor, lineHeight: CGFloat, alignment: NSTextAlignment = .left, paragraphSpacingBefore: CGFloat = 0.0) -> NSMutableAttributedString {
        let style = NSMutableParagraphStyle()
        style.minimumLineHeight = lineHeight
        style.maximumLineHeight = lineHeight
        style.alignment = alignment
        style.paragraphSpacingBefore = paragraphSpacingBefore

        return NSMutableAttributedString(string: self,
                                         attributes: [NSAttributedString.Key.font: font,
                                                      NSAttributedString.Key.foregroundColor: color,
                                                      NSAttributedString.Key.paragraphStyle: style])
    }

    var wordCount: Int {
        return components(separatedBy: " ").count
    }

    private var convertHtmlToNSAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else {
            return nil
        }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    public func insertImageWithHTML(imageURL: String) -> String {
        return "\(self)<br><img src=\"\(imageURL)\" alt=\"\" class=\"embedImage-img importedEmbed-img\"></img>"
    }

    public func convertHtmlToAttributedStringWithCSS(font: (body: UIFont?, link: UIFont?)?,
                                                     fontSize: (body: CGFloat?, link: CGFloat?)?,
                                                     csscolor: (body: String?, link: String?),
                                                     lineheight: (body: CGFloat?, link: CGFloat?),
                                                     textAlign: (body: String?, link: String?) = ("left", "left")) -> NSAttributedString? {
        guard let font = font, let fontSize = fontSize  else {
            return convertHtmlToNSAttributedString
        }

        let modifiedString = """
                <style>
                body {\
                    font-family: '\(font.body?.fontName ?? "")';\
                    font-size:\(fontSize.body ?? 0)px;\
                    color: \(csscolor.body ?? "white");\
                    line-height: \(lineheight.body ?? 0)px;\
                    text-align: \(textAlign.body ?? "left");\
                }\
                </style><style>\
                a {\
                    font-family: '\(font.link?.fontName ?? UIFont.link.fontName)';\
                    font-size:\(fontSize.link ?? UIFont.linkFontSize)px;\
                    line-height:\(lineheight.link ?? UIFont.linkLineHeight)px;\
                    text-align:\(textAlign.link ?? "left");\
                }\
                </style>\(self)
        """
        guard let data = modifiedString.data(using: .utf8) else {
            return nil
        }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }

    init?(htmlEncodedString: String) {
        guard let encodedString = htmlEncodedString.encodedHTMLString() else { return nil }
        self.init(encodedString)
    }

    public var trimmed: String {
        return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    public var trimAllWhitespaces: String {
            return components(separatedBy: .whitespaces).joined()
    }

    public var isH2: Bool {
        return hasPrefix("##") && !hasPrefix("###")
    }

    public var isH3: Bool {
        return hasPrefix("##") && !hasPrefix("####")
    }

    public var isTitle: Bool {
        return hasPrefix("#")
    }

    public var convertSpecialCharacters: String {
        var newString = self
        let char_dictionary = [
            "&amp;": "&",
            "&nbsp;": " "
        ]

        for (escaped_char, unescaped_char) in char_dictionary {
            newString = newString.replacingOccurrences(of: escaped_char, with: unescaped_char, options: NSString.CompareOptions.literal, range: nil)
        }
        return newString
    }

    public func stitchedAbsoluteURLString(baseURL: String) -> String {
        if contains("href=\"../../") {
            return replacingOccurrences(of: "href=\"../../", with: "href=\"\(baseURL)")
        } else if contains("<a href=") && !contains("<a href=\"http") {
            return replacingOccurrences(of: "href=\"", with: "href=\"\(baseURL)")
        }

        return self
    }

    var containsRichText: Bool {
        return  contains("<img src=")
            || contains("<div class=")
            || contains("span style=")
            || contains("href=")
    }

    func encodedHTMLString() -> String? {
        guard let data = data(using: .utf8) else {
            return nil
        }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return nil
        }

        return attributedString.string
    }

    func encodedHTMLStringToAttributeString() -> NSMutableAttributedString? {
        guard let data = data(using: .utf8) else {
            return nil
        }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        guard let attributedString = try? NSMutableAttributedString(data: data, options: options, documentAttributes: nil) else {
            return nil
        }

        return attributedString
    }

    func parsedHTMLTag() -> String {
        guard contains("</") else { return self }
        return encodedHTMLString() ?? self
    }

    func ranges(of searchString: String) -> [NSRange] {
        var originaString  = NSString(string: self)
        var replaceStr = Array(repeating: " ",
                               count: NSString(string: searchString).length).joined(separator: "")
        if searchString == replaceStr { replaceStr = replaceStr.lowercased() }
        var allRange: [NSRange] = []
        while originaString.range(of: searchString).location != NSNotFound {
            let range = originaString.range(of: searchString)
            allRange.append(NSRange(location: range.location, length: range.length))
            let string = originaString.replacingCharacters(in: NSRange(location: range.location, length: range.length),
                                                           with: replaceStr)
            originaString = NSString(string: string)
        }

        return allRange
    }

    func attributedText(_ fontType: TBFontType,
                        foregroundColor: UIColor? = .GlobalTextPrimary,
                        alignment: NSTextAlignment = .left,
                        lineBreakMode: NSLineBreakMode = .byWordWrapping,
                        baselineOffset: CGFloat = 0,
                        paragraphSpacing: CGFloat = 0,
                        paragraphSpacingBefore: CGFloat = 0,
                        additionalAttrsArray: [(String, [NSAttributedString.Key: Any])] = []) -> NSMutableAttributedString? {
        var attributedString = NSMutableAttributedString.initWithString(self,
                                                                        fontType: fontType,
                                                                        foregroundColor: foregroundColor ?? .GlobalTextPrimary,
                                                                        alignment: alignment,
                                                                        lineBreakMode: lineBreakMode,
                                                                        baselineOffset: baselineOffset,
                                                                        paragraphSpacing: paragraphSpacing,
                                                                        paragraphSpacingBefore: paragraphSpacingBefore)
        attributedString = attributedString.letterSpacing(fontType.letterSpacing)
        guard !additionalAttrsArray.isEmpty else { return attributedString }
        additionalAttrsArray.forEach { additionalAttrs in
            let (text, attrs) = additionalAttrs
            let ranges = attributedString.string.ranges(of: text)
            ranges.forEach { range in
                attributedString.addAttributes(attrs,
                                               range: range)
            }
        }

        return attributedString
    }

    func boldAttrs(fontType: TBFontType) -> (String, [NSAttributedString.Key: Any]) {
        return (self, AdditionalFontType.bold(font: fontType).attrs)
    }

    func linkAttrs(fontType: TBFontType,
                   url: String? = nil, showUnderline: Bool = false) -> (String, [NSAttributedString.Key: Any]) {
        guard let url = url else {
            return (self, AdditionalFontType.link(fontType: fontType, showUnderline: showUnderline).attrs)
        }

        return (self, AdditionalFontType.link(fontType: fontType, url: url, showUnderline: showUnderline).attrs)
    }

    func convertHttpToHttps() -> URL? {
        guard hasPrefix("http://") else {
            return URL(string: self)
        }

        let newUrlString = replacingOccurrences(of: "http://", with: "https://")
        return URL(string: newUrlString)
    }

    func clippedByWords(target: String, backwardOffset: Int, limitedCount: Int) -> String {
        let rangeOfTarget = range(of: target, options: .caseInsensitive)

        var endRange: Range<String.Index>?
        var startRange: Range<String.Index>?
        var targetWordRange: Range<String.Index>?

        var targetWord: String = target
        var counter = 0

        let maxOffset = backwardOffset < 0 ? startIndex : endIndex
        let backwardIndex =  index(rangeOfTarget?.lowerBound ?? startIndex, offsetBy: backwardOffset, limitedBy: maxOffset) ?? startIndex

        enumerateSubstrings(in: startIndex..., options: .byWords) { (text, range, _, _) in
            if startRange != nil {
                counter += text?.count ?? 0
            }

            guard startRange == nil
                || targetWordRange == nil
                || limitedCount >= counter else { return }

            endRange = range

            if let rangeOfTarget = rangeOfTarget,
                range.contains(rangeOfTarget.lowerBound), targetWordRange == nil {
                targetWord = text ?? ""
                targetWordRange = range
            } else if rangeOfTarget == nil, targetWordRange == nil {
                targetWordRange = range
                targetWord = target
            }

            if range.contains(backwardIndex) || range.lowerBound > backwardIndex,
                startRange == nil {
                startRange = range
                counter += text?.count ?? 0
            }
        }

        guard let startR = startRange, let endR = endRange, let targetWordR = targetWordRange else { return self }

        let start = min(startR.lowerBound, targetWordR.lowerBound)
        var end = endR.upperBound

        if !(endIndex > end) {
            end = endR.lowerBound
        }

        let clippedBody = start == end ? targetWord : String(self[start...end])
        return clippedBody
    }

    var isBulletListMarkdown: Bool {
        return hasPrefix("-")
    }

    var isBulletListString: Bool {
        return hasPrefix("•")
    }

    var isBulletList: Bool {
        return isBulletListString || isBulletListMarkdown
    }

    var isListOfLinks: Bool {
        do {
            let singlelineListRegrex = try NSRegularExpression(pattern: "^( )*\\[[^)]*\\)", options: [])
            let inlineListRegrex = try NSRegularExpression(pattern: "(> )+\\[[^)]*\\)", options: [])
            let urlRegrex = try NSRegularExpression(pattern: "(http|https):\\/\\/([\\w-]+\\.)+[\\w-]+(:\\d+)?(\\/[\\w- ./?%&=]*)?", options: [])

            let range = NSRange(location: 0, length: self.count)
            let singlelineLinks = singlelineListRegrex.matches(in: self, options: [], range: range)
            let inlineLinks = inlineListRegrex.matches(in: self, options: [], range: range)
            let urlLinks = urlRegrex.matches(in: self, options: [], range: range)
            return singlelineLinks.count + inlineLinks.count + urlLinks.count > 0
        } catch {
            return false
        }
    }

    var isStrongTitle: Bool {
        let strongMark = "**"
        guard hasPrefix(strongMark) && hasSuffix(strongMark) else { return false }
        let newText = trimmingCharacters(in: .controlCharacters).deletingBothEndsCharacters(strongMark)
        return !newText.contains(strongMark)
    }

    var isMarkdownLink: Bool {
        let regex = #"^\[.+?\]\([^\s]+?\)$"#
        return self.range(of: regex, options: .regularExpression) != nil
    }

    var isMarkdownJumplink: Bool {
        return self.contains("](#")
    }

    var capitalizedWithoutPreposition: String {
        let wordsNoNeedToCap = Set(["in", "on", "with", "by", "for", "at", "about", "under", "of", "to", "from", "over", "or", "the"])
        let wordNeedToLowercase = Set(["1st", "2nd", "3rd"])
        var stringArray = self.components(separatedBy: " ")
        stringArray = stringArray.map {
            wordsNoNeedToCap.contains($0.lowercased()) ? $0.lowercased() : $0.capitalized
        }
        if let firstString = stringArray.first?.capitalized {
            stringArray[0] = firstString
        }
        if let lastString = stringArray.last?.capitalized {
            stringArray[stringArray.count-1] = lastString
        }
        stringArray.enumerated().forEach { (index, obj) in
            if wordNeedToLowercase.contains(obj.lowercased()) {
                stringArray[index] = obj.lowercased()
            }
        }
        let resultString = stringArray.joined(separator: " ")
        return resultString
    }

    func convertDealsHtmlToAttributedString() -> NSMutableAttributedString? {

        var html = self
        if html.contains("</span>") {
            html = replacingOccurrences(of: "</?span[^>]*>", with: "", options: .regularExpression, range: nil)
        }
        let pattern = "(<div.*?>)(.*?)(</div>)"
        guard let regrex = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }

        let results = regrex.matches(in: html, options: [], range: NSRange(location: 0, length: html.count))
        var resultArray = results.compactMap { (html as NSString).substring(with: $0.range) }
        if resultArray.isEmpty {
            resultArray.append(html)
        }
        var stringArray = [String]()
        var supLocations = [Int]()
        for result in resultArray {
            var string = result.replacingOccurrences(of: "</?div[^>]*>", with: "", options: .regularExpression, range: nil)
            string = string.replacingOccurrences(of: "<br\\s*/?>", with: "\n", options: .regularExpression, range: nil)
            string = string.replacingOccurrences(of: "<sup>", with: "")
            if let range = string.range(of: "</sup>") {
                let location = string.distance(from: description.startIndex, to: range.lowerBound) - 1
                supLocations.append(location)
                string = string.replacingOccurrences(of: "</sup>", with: "")
            }
            stringArray.append(string)
        }
        var firstAttribute = NSMutableAttributedString(string: stringArray.first ?? "")
        let firstStyle = NSMutableParagraphStyle()
        firstStyle.alignment = .center
        firstAttribute.addAttributes([NSAttributedString.Key.font: TBFontType.mulishBody2.font,
                                      NSAttributedString.Key.foregroundColor: UIColor.GlobalTextPrimary,
                                      NSAttributedString.Key.paragraphStyle: firstStyle],
                                                            range: NSRange(location: 0, length: firstAttribute.length))
        firstAttribute.setSuperscriptWithIndex(indexs: [supLocations.first ?? -1], fontType: TBFontType.mulishBody2)

        if stringArray.first != stringArray.last {
            var lastAttribute = NSMutableAttributedString(string: "\n" + (stringArray.last ?? ""))
            let lastStyle = NSMutableParagraphStyle()
            lastStyle.alignment = .center
            lastStyle.paragraphSpacingBefore = 12
            lastAttribute.addAttributes([NSAttributedString.Key.font: TBFontType.mulishBody4.font,
                                          NSAttributedString.Key.foregroundColor: UIColor.DarkGray600,
                                         NSAttributedString.Key.paragraphStyle: lastStyle],
                                                                range: NSRange(location: 0, length: lastAttribute.length))
            firstAttribute.append(lastAttribute)
        }
        return firstAttribute.setSuperscriptWithIndex(indexs: [supLocations.last ?? -1], fontType: TBFontType.mulishBody2)
    }

    func covertHtmlTagToAttributedString(fontType: TBFontType,
                                         foregroundColor: UIColor = .GlobalTextPrimary,
                                         alignment: NSTextAlignment = .left,
                                         lineBreakMode: NSLineBreakMode = .byWordWrapping) -> NSMutableAttributedString? {

        let htmlString = self.replacingOccurrences(of: "<br\\s*/?>", with: "\n", options: .regularExpression, range: nil)
        let replaceString = htmlString.replacingOccurrences(of: "<[^<>]+>", with: "", options: .regularExpression, range: nil)
        let attributedString = replaceString.attributedText(fontType, foregroundColor: foregroundColor, alignment: alignment, lineBreakMode: lineBreakMode)

        let htmlRegex = "<[^>]+>(.*?)</[^>]+>"
        guard let regex = try? NSRegularExpression(pattern: htmlRegex, options: []) else { return attributedString }
        let results = regex.matches(in: htmlString, range: NSRange(location: 0, length: htmlString.utf16.count))

        for result in results {
            guard let rangeHtml = Range(result.range(at: 0), in: htmlString),
                  let range = Range(result.range(at: 1), in: htmlString) else { continue }
            let rangeHtmlString = htmlString[rangeHtml]
            let rangeString = String(htmlString[range])

            if rangeHtmlString.contains("<strong>") || rangeHtmlString.contains("<b>") {
                if let range = attributedString?.string.ranges(of: rangeString).first,
                   let boldFont = UIFont(name: UIFont.mulishBoldName, size: fontType.style.fontSize) {
                    attributedString?.addAttributes([NSAttributedString.Key.font: boldFont], range: range)
                }
            }
            if rangeHtmlString.contains("<i>") ||
               rangeHtmlString.contains("<em>") ||
               rangeHtmlString.contains("<cite>") ||
               rangeHtmlString.contains("<dfn>") {
                if let range = attributedString?.string.ranges(of: rangeString).first {
                    var italicFont: UIFont?
                    if fontType.font.fontName.contains("Regular") {
                        italicFont = UIFont(name: UIFont.mulishItalicName, size: fontType.style.fontSize)
                    } else if fontType.font.fontName.contains("Bold") {
                        italicFont = UIFont(name: UIFont.mulishBoldItalicName, size: fontType.style.fontSize)
                    } else if fontType.font.fontName.contains("Black") {
                        italicFont = UIFont(name: UIFont.mulishBlackItalicName, size: fontType.style.fontSize)
                    }
                    attributedString?.addAttributes([NSAttributedString.Key.font: italicFont ?? fontType.font], range: range)
                }
            }
            if rangeHtmlString.contains("<u>") {
                if let range = attributedString?.string.ranges(of: rangeString).first {
                    attributedString?.addAttributes([NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: range)
                }
            }
            if rangeHtmlString.contains("<sup>") {
                if let ranges = attributedString?.string.ranges(of: rangeString) {
                    ranges.forEach { range in
                        let offset = fontType.lineHeight / 3
                        let font = UIFont(name: fontType.font.fontName, size: fontType.style.fontSize * 0.8)
                        attributedString?.addAttributes([.font: font, .baselineOffset: offset], range: range)
                    }
                }
            }
            if rangeHtmlString.contains("<sub>") {
                if let ranges = attributedString?.string.ranges(of: rangeString) {
                    ranges.forEach { range in
                        let offset = fontType.lineHeight / 3
                        let font = UIFont(name: fontType.font.fontName, size: fontType.style.fontSize * 0.8)
                        attributedString?.addAttributes([.font: fontType.font, .baselineOffset: -offset], range: range)
                    }
                }
            }
        }
        return attributedString
    }

    var extractURLs: [URL] {
        let pattern = #"(?i)\b((?:https?|ftp)://|www\.)\S+\b"#
        guard let detector = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }
        let range = NSRange(self.startIndex..<self.endIndex, in: self)
        let matches = detector.matches(in: self, options: [], range: range)
        let urls = matches.compactMap { match -> URL? in
            guard let urlRange = Range(match.range, in: self) else {
                return nil
            }
            return URL(string: String(self[urlRange]))
        }
        return urls
    }

    var excludedDomainsForSkimlinks: Bool {
        let excludedDomains = ["amazon.com", "thebump.com", "theknot.com"]
        return excludedDomains.filter { contains($0) }.isEmpty
    }

    var removeAllWhitespaces: String {
        return self.filter({!$0.isWhitespace})
    }

    func addSkimlinks(slug: String) -> String {
        guard excludedDomainsForSkimlinks,
              let encodedURL = addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        else { return self }

        let skimlinkString = "https://go.skimresources.com/?id=\(kArtcleSkimlinkID)&url=\(encodedURL)&sref=\(slug)&xcust=ios"
        return skimlinkString
    }

    var csvFriendly: String {
        return "\"" + self + "\""
    }

    var convertToVersion: TBVersion? {
        let components = self.components(separatedBy: ".")
        guard components.count == 3,
              let major = Int(components[0]),
              let minor = Int(components[1]),
              let patch = Int(components[2]) else {
            return nil
        }
        return TBVersion(major: major, minor: minor, patch: patch)
    }

    func isNewerVersionThan(version: String) -> Bool {
        if let version1 = self.convertToVersion,
           let version2 = version.convertToVersion {
            return version1 > version2
        }
        return false
    }

    func isMatchingPattern(pattern: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
            let range = NSRange(location: 0, length: self.count)
            let matches = regex.numberOfMatches(in: self, options: [], range: range)
            return matches > 0
        } catch {
            return false
        }
    }

}

extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        switch self {
        case .some(let string):
            return string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .none:
            return true
        }
    }
}
