//
//  DataRepresentable.swift
//  SwiftUI-Charts
//
//  Created by Jovins on 2021/8/5.
//

import Foundation
import CoreGraphics

protocol DataRepresentable {
    
    func points(for data: [Double], frame: CGRect, offset: Double, lineWidth: CGFloat) -> [CGPoint]
    func lineWidth(type: ChartVisualType) -> CGFloat
}

extension DataRepresentable {
    
    func points(for data: [Double], frame: CGRect, offset: Double, lineWidth: CGFloat) -> [CGPoint] {
        
        var points: [CGPoint] = []
        var vector = Math.stretchOut(Math.norm(data))
        if offset != 0 {
            vector = Math.stretchIn(vector, offset: offset)
        }
        
        let isEqual: Bool = equalValues(in: vector)
        for i in 0..<vector.count {
            let x = frame.size.width / CGFloat(vector.count - 1) * CGFloat(i)
            let y = isEqual ? frame.size.height / 2 : (frame.size.height - lineWidth) * CGFloat(vector[i]) + lineWidth / 2
            points.append(CGPoint(x: x, y: y))
        }
        return points
    }
    
    func lineWidth(type: ChartVisualType) -> CGFloat {
        
        switch type {
        case .outline(_, let lineWidth):
            return lineWidth
        case .filled(_, let lineWidth):
            return lineWidth
        case .customFilled(_, let lineWidth, _):
            return lineWidth
        }
    }
    
    private func equalValues(in vector: [Double]) -> Bool {
        
        guard let prev = vector.first else {
            return true
        }
        for value in vector {
            if value != prev {
                return false
            }
        }
        return true
    }
}
