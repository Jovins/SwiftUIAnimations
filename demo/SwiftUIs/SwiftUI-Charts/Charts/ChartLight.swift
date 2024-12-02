//
//  ChartLight.swift
//  SwiftUI-Charts
//
//  Created by Jovins on 2021/8/5.
//

import SwiftUI

struct ChartLight: View {
    
    private let datas: [Double]
    private let frame: CGRect
    private let offset: Double
    private let type: ChartVisualType
    private let lineType: ChartLineType
    private var points: [CGPoint] = []
    
    init(datas: [Double],
         frame: CGRect,
         type: ChartVisualType = .outline(color: .red, lineWidth: 2),
         offset: Double = 0,
         lineType: ChartLineType = .none) {
        
        self.datas = datas
        self.frame = frame
        self.type = type
        self.offset = offset
        self.lineType = lineType
        self.points = points(for: datas, frame: frame, offset: offset, lineWidth: lineWidth(type: type))
    }
    
    // MARK: - Views
    var body: some View {
        
        ZStack {
            chart
                .rotationEffect(.degrees(180), anchor: .center)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .drawingGroup()
            line
                .rotationEffect(.degrees(180), anchor: .center)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .drawingGroup()
        }
    }

    private var chart: some View {
        switch type {
        case .outline(let color, let width):
            
            return AnyView(linePath(points: self.points).stroke(color, style: StrokeStyle(lineWidth: width, lineJoin: .round)))
        case .filled(let color, let width):
            
            return AnyView(ZStack {
                linePathGradient(points: points)
                    .fill(LinearGradient(
                        gradient: .init(colors: [color.opacity(0.2), color.opacity(0.02)]),
                        startPoint: .init(x: 0.5, y: 1),
                        endPoint: .init(x: 0.5, y: 0)
                    ))
                linePath(points: points)
                    .stroke(color, style: StrokeStyle(lineWidth: width, lineJoin: .round))
            })
        case .customFilled(let color, let width, let fillGradient):
            
            return AnyView(ZStack {
                linePathGradient(points: points)
                    .fill(fillGradient)
                linePath(points: points)
                    .stroke(color, style: StrokeStyle(lineWidth: width, lineJoin: .round))
            })
        }
    }
    
    private var line: some View {
        
        switch lineType {
        case .none:
            return AnyView(EmptyView())
        case .line(let color, let width):
            return AnyView(
                currentValueLinePath(points: points)
                    .stroke(color, style: StrokeStyle(lineWidth: width))
            )
        case .dash(let color, let width, let dash):
            return AnyView(
                currentValueLinePath(points: points)
                    .stroke(color, style: StrokeStyle(lineWidth: width, dash: dash))
            )
        }
    }
    
    // MARK: - Private Func
    /// create line path
    private func linePath(points: [CGPoint]) -> Path {
     
        var path = Path()
        guard points.count > 1 else { return path }
        path.move(to: points[0])
        for i in 1..<points.count {
            path.addLine(to: points[i])
        }
        return path
    }
    
    /// put colour on path
    private func linePathGradient(points: [CGPoint]) -> Path {
        
        var path = linePath(points: points)
        guard let last = points.last else {
            return path
        }
        path.addLine(to: CGPoint(x: last.x, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: points[0].y))
        return path
    }

    private func currentValueLinePath(points: [CGPoint]) -> Path {
        
        var path = Path()
        guard let last = points.last else {
            return path
        }
        path.move(to: CGPoint(x: 0, y: last.y))
        path.addLine(to: last)
        return path
    }
}

extension ChartLight: DataRepresentable { }
