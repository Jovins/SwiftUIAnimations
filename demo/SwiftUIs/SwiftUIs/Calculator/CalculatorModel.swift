//
//  CalculatorModel.swift
//  SwiftUIs
//
//  Created by Jovins on 2021/6/25.
//

import Foundation
import SwiftUI
import Combine

class CalculatorModel: ObservableObject {
    
    @Published var brain: CalculatorBrain = .left("0")
    @Published var history: [CalculatorButtonItem] = []
    
    /// temporaryKept来暂存“被回溯”的操作
    var temporaryKept: [CalculatorButtonItem] = []
    
    /// historyDetail 将 history 数组中所记录的操作步骤的描述连接起来
    /// 作为履历的输出字符串
    var historyDetail: String {
        history.map { $0.description }.joined()
    }
    
    /// 滑块的最大值应当是 history 和 temporaryKept 两个数组元素数量的和
    var totalCount: Int {
        history.count + temporaryKept.count
    }
    
    /// 使用 slidingIndex 表示当前滑块表示的 index 值
    var slidingIndex: Float = 0 {
        didSet {
            /// 滑块值变动时被调用
            keepHistory(upTo: Int(slidingIndex))
        }
    }
    
    // MARK: - Method
    func apply(_ item: CalculatorButtonItem) {
        
        brain = brain.apply(item)
        history.append(item)
        temporaryKept.removeAll()
        slidingIndex = Float(totalCount)
    }
    
    /// 根据 history 重新计算当前 brain 的状态
    func keepHistory(upTo index: Int) {
        
        precondition(index <= totalCount, "Out of index")
        let total = history + temporaryKept
        history = Array(total[..<index])
        temporaryKept = Array(total[index...])
        // 更新UI
        brain = history.reduce(CalculatorBrain.left("0"), { result, item in
            result.apply(item)
        })
    }
}
