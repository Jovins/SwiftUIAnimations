//
//  ChartLightView.swift
//  SwiftUI-Charts
//
//  Created by Jovins on 2021/8/5.
//

import SwiftUI

struct ChartLightView: View {
    
    private let datas: [Double]
    private let type: ChartType
    private let visualType: ChartVisualType
    private let offset: Double
    private let lineType: ChartLineType
    
    init(datas: [Double],
         type: ChartType = .line,
         visualType: ChartVisualType = .outline(color: .red, lineWidth: 2),
         offset: Double = 0,
         lineType: ChartLineType = .none) {
        self.datas = datas
        self.type = type
        self.visualType = visualType
        self.offset = offset
        self.lineType = lineType
    }
    
    var body: some View {
        GeometryReader { reader in
            chart(withFrame: CGRect(x: 0,
                                    y: 0,
                                    width: reader.frame(in: .local).width ,
                                    height: reader.frame(in: .local).height))
        }
    }
    
    private func chart(withFrame frame: CGRect) -> AnyView {
        
        switch type {
        case .line:
            return AnyView(ChartLight(datas: self.datas, frame: frame, type: self.visualType, offset: self.offset, lineType: self.lineType))
        case .curved:
            return AnyView(ChartCurved(datas: self.datas, frame: frame, type: self.visualType, offset: self.offset, lineType: self.lineType))
        }
    }
}
