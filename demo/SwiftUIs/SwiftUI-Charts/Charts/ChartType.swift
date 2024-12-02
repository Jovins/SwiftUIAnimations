//
//  ChartType.swift
//  SwiftUI-Charts
//
//  Created by Jovins on 2021/8/5.
//

import SwiftUI

enum ChartType {
    case line
    case curved
}

enum ChartVisualType {
    case outline(color: Color, lineWidth: CGFloat)
    case filled(color: Color, lineWidth: CGFloat)
    case customFilled(color: Color, lineWidth: CGFloat, fillGradient: LinearGradient)
}

enum ChartLineType {
    case none
    case line(color: Color, lineWidth: CGFloat)
    case dash(color: Color, lineWidth: CGFloat, dash: [CGFloat])
}
