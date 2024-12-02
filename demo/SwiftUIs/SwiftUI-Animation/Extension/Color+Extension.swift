//
//  Color+Extension.swift
//  SwiftUI-Animation
//
//  Created by Jovins on 2021/7/23.
//

import SwiftUI

extension Color {
    
    static let background: Color = Color(UIColor.systemBackground)
    static let label: Color = Color(UIColor.label)
    
    static let chatBackground: Color = Color(r: 41, g: 121, b: 255.0)
    static let buttonBackground: Color = Color(r: 144.0, g: 202.0, b: 249.0)
    
    static let wifiBackground: Color = Color(r: 5, g: 23, b: 46)
    static let wifiShadow: Color = Color(r: 13, g: 50, b: 125)
    
    static let wifiConnected: Color = Color(r: 170, g: 255, b: 197)
    
    static let expandingBackground: Color = Color(r: 3, g: 247, b: 235)
    static let expandingAccent: Color = Color(r: 186, g: 38, b: 75)
    
    static let circleTrackStart: Color = Color(r: 237, g: 242, b: 255)
    static let circleTrackEnd: Color = Color(r: 235, g: 248, b: 255)
    
    static let circleRoundStart: Color = Color(r: 71, g: 198, b: 255)
    static let circleRoundEnd: Color = Color(r: 90, g: 131, b: 255)
    
    static let pillColor: Color = Color(r: 242, g: 53, b: 174)
    
    static let likeBackground: Color = Color(r: 49, g: 28, b: 78)
    static let likeOverlay: Color = Color(r: 64, g: 49, b: 82)
    
    static let likeColor: Color = Color(r: 254, g: 140, b: 100)
    
    static let submitColor: Color = Color(r: 110, g: 80, b: 249)
    
    static let materialBlack: Color = Color(r: 18, g: 18, b: 18)
    static let offWhite: Color = Color(r: 225, g: 225, b: 235)
    
    init(r: Double, g: Double, b: Double) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0)
    }
}

extension Color {
    
    // eg: Color(hex: 0x5a5a5a)
    init(hex: Int, alpha: Double = 1) {
        let components = (
            R: Double((hex >> 16) & 0xff) / 255,
            G: Double((hex >> 08) & 0xff) / 255,
            B: Double((hex >> 00) & 0xff) / 255
        )
        self.init(
            .sRGB,
            red: components.R,
            green: components.G,
            blue: components.B,
            opacity: alpha
        )
    }
}

// Foundation
extension Double {
    
    func clean(places: Int) -> String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(format: "%.\(places)f", self)
    }
}

