//
//  ChartCurved.swift
//  SwiftUI-Charts
//
//  Created by Jovins on 2021/8/5.
//

import SwiftUI

struct ChartCurved: View {
    
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
            return AnyView(curvedPath(points: points)
                .stroke(color, style: StrokeStyle(lineWidth: width, lineJoin: .round)))
        case .filled(let color, let width):
            return AnyView(ZStack {
                curvedPathGradient(points: points)
                    .fill(LinearGradient(
                        gradient: .init(colors: [color.opacity(0.2), color.opacity(0.02)]),
                        startPoint: .init(x: 0.5, y: 1),
                        endPoint: .init(x: 0.5, y: 0)
                    ))
                curvedPath(points: points)
                    .stroke(color, style: StrokeStyle(lineWidth: width, lineJoin: .round))
            })
        case .customFilled(let color, let width, let fillGradient):
            return AnyView(ZStack {
                curvedPathGradient(points: points)
                    .fill(fillGradient)
                curvedPath(points: points)
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
    private func curvedPath(points: [CGPoint]) -> Path {
        
        func mid(_ point1: CGPoint, _ point2: CGPoint) -> CGPoint {
            
            return CGPoint(x: (point1.x + point2.x) / 2, y:(point1.y + point2.y) / 2)
        }
        
        func control(_ point1: CGPoint, _ point2: CGPoint) -> CGPoint {
            
            var controlPoint = mid(point1, point2)
            let delta = abs(point2.y - controlPoint.y)
            
            if point1.y < point2.y {
                controlPoint.y += delta
            } else if point1.y > point2.y {
                controlPoint.y -= delta
            }
            
            return controlPoint
        }
        
        var path = Path()
        guard points.count > 1 else {
            return path
        }
        
        var startPoint = points[0]
        path.move(to: startPoint)
        
        guard points.count > 2 else {
            path.addLine(to: points[1])
            return path
        }
        
        for i in 1..<points.count {
            let currentPoint = points[i]
            let midPoint = mid(startPoint, currentPoint)
            
            path.addQuadCurve(to: midPoint, control: control(midPoint, startPoint))
            path.addQuadCurve(to: currentPoint, control: control(midPoint, currentPoint))
            
            startPoint = currentPoint
        }
        
        return path
    }
    
    private func curvedPathGradient(points: [CGPoint]) -> Path {
        
        var path = curvedPath(points: points)
        guard let lastPoint = points.last else {
            return path
        }
        path.addLine(to: CGPoint(x: lastPoint.x, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: points[0].y))
        return path
    }
    
    private func currentValueLinePath(points: [CGPoint]) -> Path {
        
        var path = Path()
        guard let lastPoint = points.last else {
            return path
        }
        path.move(to: CGPoint(x: 0, y: lastPoint.y))
        path.addLine(to: lastPoint)
        return path
    }
}

extension ChartCurved: DataRepresentable { }
