import UIKit
@objc extension UIColor {
    public convenience init?(hex: String) {
        guard hex.hasPrefix("#"), hex.count == 7 else { return nil }
        let start = hex.index(hex.startIndex, offsetBy: 1)
        let hexColor = String(hex[start...])
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0

        if scanner.scanHexInt64(&hexNumber) {
            let red = CGFloat((hexNumber & 0xFF0000) >> 16)
            let green = CGFloat((hexNumber & 0x00FF00) >> 8)
            let blue = CGFloat((hexNumber & 0x0000FF))
            self.init(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1)
            return
        }

        return nil
    }

    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: red / 255.0,
                       green: green / 255.0,
                       blue: blue / 255.0,
                       alpha: alpha)
    }

    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0

        return NSString(format: "#%06x", rgb) as String
    }

    static func OffWhite(alpha: CGFloat) -> UIColor {
        return .OffWhite.withAlphaComponent(alpha)
    }

    static func black(alpha: CGFloat) -> UIColor {
        return rgb(red: 0, green: 0, blue: 0, alpha: alpha)
    }

    static var rgb245_244_244: UIColor { rgb(red: 245, green: 244, blue: 244) }
    static var rgb245_245_245: UIColor { rgb(red: 245, green: 245, blue: 245) }
    static var rgb000_122_119: UIColor { rgb(red: 0, green: 122, blue: 119) } // similar: Teal
    static var rgb194_056_063: UIColor { rgb(red: 194, green: 56, blue: 63) }
    static var rgb216_216_216: UIColor { rgb(red: 216, green: 216, blue: 216) }
    static var rgb229_229_229: UIColor { rgb(red: 229, green: 229, blue: 229) }
    static var rgb153_153_153: UIColor { rgb(red: 153, green: 153, blue: 153) }
    static var rgb245_246_248: UIColor { rgb(red: 245, green: 246, blue: 248) }
    static var rgb255_142_096: UIColor { rgb(red: 255, green: 142, blue: 096) }
    static var rgb155_155_155: UIColor { rgb(red: 155, green: 155, blue: 155) }
    static var rgb036_211_206: UIColor { rgb(red: 36, green: 211, blue: 206) }
    static var rgb255_110_110: UIColor { rgb(red: 255, green: 110, blue: 110) }
    static var rgb215_14_145: UIColor { rgb(red: 215, green: 14, blue: 145) }
    static var rgb242_159_038: UIColor { rgb(red: 242, green: 159, blue: 038) }
    static var rgb143_143_143: UIColor { rgb(red: 143, green: 143, blue: 143) }
    static var rgb246_246_248: UIColor { rgb(red: 246, green: 246, blue: 248) }
    static var rgb041_155_152: UIColor { rgb(red: 41, green: 155, blue: 152) }
    static var rgb066_103_178: UIColor { rgb(red: 066, green: 103, blue: 178) }
    static var rgb238_240_246: UIColor { rgb(red: 238, green: 240, blue: 246) }
    static var rgb078_078_078_025: UIColor { rgb(red: 078, green: 078, blue: 078, alpha: 0.25) }
    static var rgb218_136_140: UIColor { rgb(red: 218, green: 136, blue: 140) }
    static var rgb159_159_159: UIColor { rgb(red: 235, green: 233, blue: 228, alpha: 0.25) }
    static var rgb019_136_023: UIColor { rgb(red: 019, green: 136, blue: 23) }
    static var rgb228_017_014: UIColor { rgb(red: 228, green: 017, blue: 014) }
    static var rgb210_210_210: UIColor { rgb(red: 210, green: 210, blue: 210) }
    static var rgb184_184_184: UIColor { rgb(red: 184, green: 184, blue: 184) }
    static var rgb173_173_173: UIColor { rgb(red: 173, green: 173, blue: 173) }
    static var rgb255_205_051: UIColor { rgb(red: 255, green: 205, blue: 051) }
    static var rgb199_024_041: UIColor { rgb(red: 199, green: 024, blue: 041) }
    static var rgb174_047_051: UIColor { rgb(red: 174, green: 047, blue: 051) }
    static var rgb207_014_140: UIColor { rgb(red: 207, green: 014, blue: 140) }
    static var rgb051_051_051: UIColor { rgb(red: 051, green: 051, blue: 051) }
    static var rgb084_084_084: UIColor { rgb(red: 084, green: 084, blue: 084) }
}
