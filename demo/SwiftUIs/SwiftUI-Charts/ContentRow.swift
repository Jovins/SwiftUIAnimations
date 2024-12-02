//
//  ContentRow.swift
//  SwiftUI-Charts
//
//  Created by Jovins on 2021/8/5.
//

import SwiftUI

struct ContentRow: View {
    
    let chart: ChartModel
    
    var body: some View {
        Color(hex: 0xEFEFEF).edgesIgnoringSafeArea(.all)
        ZStack {
            ChartLightView(datas: self.chart.datas,
                           type: self.chart.type,
                           visualType: self.chart.visualType,
                           offset: self.chart.offset,
                           lineType: self.chart.lineType)
                .frame(height: 120, alignment: .center)
                .padding(.all, 16)
                .shadow(color: .pink, radius: 8)
        }
        .foregroundColor(.blue)
        .padding(.all, 16)
        .cornerRadius(16)
        .shadow(color: .orange, radius: 8)
    }
}
