//
//  UIColor+Extension.swift
//  Shine
//
//  Created by Jovins on 2021/8/1.
//

import UIKit

extension UIColor {
    
    var redValue: CGFloat{ return CIColor(color: self).red }
    var greenValue: CGFloat{ return CIColor(color: self).green }
    var blueValue: CGFloat{ return CIColor(color: self).blue }
    var alphaValue: CGFloat{ return CIColor(color: self).alpha }
}

extension UIColor {
    
    /// Init color with hex code
    /// - Parameter value: hex code (eg. 0x003300)
    /// - Returns: UIColor
    convenience init(hex: UInt32) {
        self.init(
            CGFloat((hex & 0xFF0000) >> 16),    // red
            CGFloat((hex & 0xFF00) >> 8),       // green
            CGFloat((hex & 0xFF))               // blue
        )
    }
    
    convenience init(_ r256: CGFloat, _ g256: CGFloat, _ b256: CGFloat, alpha: CGFloat = 1) {
        self.init(red: r256 / 255.0, green: g256 / 255.0, blue: b256 / 255.0, alpha: alpha)
    }
}
