//
//  ContentView.swift
//  SwiftUI-Charts
//
//  Created by Jovins on 2021/8/5.
//

import SwiftUI

struct ContentView: View {
    var body: some View {

        ScrollView {
            LazyVStack {
                ForEach(ChartManager.shared.charts) { chart in
                    ContentRow(chart: chart)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ChartModel: Identifiable {
    
    let id = UUID()
    var datas: [Double] = []
    var type: ChartType = .line
    var visualType: ChartVisualType = .outline(color: .red, lineWidth: 2)
    var offset: Double = 0
    var lineType: ChartLineType = .none
}

class ChartManager {
    
    static let shared = ChartManager()
    var charts: [ChartModel] = [
        ChartModel(datas: [4, 8, 12, 10, 25], type: .line, visualType: .outline(color: .red, lineWidth: 2), offset: 0, lineType: .none),
        ChartModel(datas: [2, 17, 9, 23, 10], type: .curved, visualType: .outline(color: .orange, lineWidth: 2), offset: 0, lineType: .none),
        ChartModel(datas: [2, 17, 9, 23, 10], type: .curved, visualType: .outline(color: .green, lineWidth: 5), offset: 0, lineType: .none),
        ChartModel(datas: [2, 17, 9, 23, 10], type: .curved, visualType: .filled(color: .blue, lineWidth: 5), offset: 0, lineType: .none),
        ChartModel(datas: [2, 17, 9, 23, 10], type: .curved, visualType: .customFilled(color: .pink, lineWidth: 3, fillGradient: LinearGradient(gradient: .init(colors: [Color.orange.opacity(0.7), Color.orange.opacity(0.1)]), startPoint: .init(x: 0.5, y: 1), endPoint: .init(x: 0.5, y: 0))), offset: 0, lineType: .none),
        ChartModel(datas: [2, 17, 9, 23, 10], type: .curved, visualType: .filled(color: .purple, lineWidth: 3), offset: 0.2, lineType: .none),
        ChartModel(datas: [2, 17, 9, 23, 10], type: .curved, visualType: .filled(color: .green, lineWidth: 3), offset: 0.2, lineType: .line(color: .gray, lineWidth: 1)),
        ChartModel(datas: [2, 17, 9, 23, 10], type: .curved, visualType: .filled(color: .orange, lineWidth: 3), offset: 0.2, lineType: .dash(color: .gray, lineWidth: 1, dash: [5]))
    ]
}

