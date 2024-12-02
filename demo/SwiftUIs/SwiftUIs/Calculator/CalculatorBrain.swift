//
//  CalculatorBrain.swift
//  SwiftUIs
//
//  Created by Jovins on 2021/6/24.
//

import Foundation
import SwiftUI

enum CalculatorBrain {
    
    case left(String)
    case leftOp(left: String, op: CalculatorButtonItem.Op)
    case leftOpRight(left: String, op: CalculatorButtonItem.Op, right: String)
    case error
    
    var output: String {
        let result: String
        switch self {
        case .left(let left):
            result = left
        case .leftOp(let left, _):
            result = left
        case .leftOpRight(_, _, let right):
            result = right
        case .error:
            return "Error"
        }
        guard let value = Double(result) else {
            return "Error"
        }
        return formatter.string(from: value as NSNumber)!
    }
    
    @discardableResult // 取消返回值警告
    func apply(_ item: CalculatorButtonItem) -> CalculatorBrain {
        switch item {
        case .digit(let num):
//            if case .left(let value) = self, value != "0" {
//                return .left("\(num)")
//            }
            return apply(num)
        case .dot:
            return applyDot()
        case .op(let op):
            return apply(op)
        case .command(let command):
            return apply(command)
        }
    }
    
    /// 输入数字处理
    private func apply(_ num: Int) -> CalculatorBrain {
        switch self {
        case .left(let left):
            return .left(left.apply(num)) // 数据拼数据
        case .leftOp(let left, let op):
            return .leftOpRight(left: left, op: op, right: "0".apply(num))
        case .leftOpRight(let left, let op, let right):
            return .leftOpRight(left: left, op: op, right: right.apply(num))
        case .error:
            return .left("0".apply(num))
        }
    }
    
    /// 输入小数点处理
    private func applyDot() -> CalculatorBrain {
        switch self {
        case .left(let left):
            return .left(left.applyDot())
        case .leftOp(let left, let op):
            return .leftOpRight(left: left, op: op, right: "0".applyDot())
        case .leftOpRight(let left, let op, let right):
            return .leftOpRight(left: left, op: op, right: right.applyDot())
        case .error:
            return .left("0".applyDot())
        }
    }
    
    /// 输入符号处理
    private func apply(_ op: CalculatorButtonItem.Op) -> CalculatorBrain {
        switch self {
        case .left(let left):
            switch op {
            case .plus, .minus, .multiply, .divide:
                return .leftOp(left: left, op: op)
            case .equal:
                return self
            }
        case .leftOp(let left, let curOp):
            switch op {
            case .plus, .minus, .multiply, .divide:
                return .leftOp(left: left, op: op)
            case .equal:
                if let result = curOp.calculate(left, right: left) {
                    return .leftOp(left: result, op: curOp)
                } else {
                    return .error
                }
            }
        case .leftOpRight(let left, let curOp, let right):
            switch op {
            case .plus, .minus, .multiply, .divide:
                if let result = curOp.calculate(left, right: right) {
                    return .leftOp(left: result, op: op)
                } else {
                    return .error
                }
            case .equal:
                if let result = curOp.calculate(left, right: right) {
                    return .left(result)
                } else {
                    return .error
                }
            }
        case .error:
            return self
        }
    }
    
    /// 其他命令
    private func apply(_ command: CalculatorButtonItem.Command) -> CalculatorBrain {
        switch command {
        case .clear:
            return .left("0")
        case .flip:
            switch self {
            case .left(let left):
                return .left(left.flipped())
            case .leftOp(let left, let op):
                return .leftOpRight(left: left, op: op, right: "-0")
            case .leftOpRight(let left, let op, let right):
                return .leftOpRight(left: left, op: op, right: right.flipped())
            case .error:
                return .left("-0")
            }
        case .percent:
            switch self {
            case .left(let left):
                return .left(left.percentaged())
            case .leftOp:
                return self
            case .leftOpRight(let left, let op, let right):
                return .leftOpRight(left: left, op: op, right: right.percentaged())
            case .error:
                return .left("-0")
            }
        }
    }
}

/// 限制小数点为8位
var formatter: NumberFormatter = {
    let f = NumberFormatter()
    f.minimumFractionDigits = 0
    f.maximumFractionDigits = 8
    f.numberStyle = .decimal
    return f
}()

extension String {
    
    /// 是否包含小数点
    var containsDot: Bool {
        return contains(".")
    }
    
    /// 前缀是否是 "-"
    var startWithNegative: Bool {
        return starts(with: "-")
    }
    
    /// 拼接
    func apply(_ num: Int) -> String {
        return self == "0" ? "\(num)" : "\(self)\(num)"
    }
    
    /// 拼接小数点
    func applyDot() -> String {
        return containsDot ? self : "\(self)."
    }
    
    func flipped() -> String {
        if startWithNegative {
            var s = self
            s.removeFirst()
            return s
        } else {
            return "-\(self)"
        }
    }
    
    /// 百分比
    func percentaged() -> String {
        return String(Double(self)! / 100)
    }
}

extension CalculatorButtonItem.Op {
    
    func calculate(_ left: String, right: String) -> String? {
        
        guard let left = Double(left), let right = Double(right) else {
            return nil
        }
        let result: Double?
        switch self {
        case .plus:
            result = left + right
        case .minus:
            result = left - right
        case .multiply:
            result = left * right
        case .divide:
            result = right == 0 ? nil : left / right
        case .equal:
            fatalError()
        }
        /// 遍历输出可选字符串
        return result.map { String($0) }
    }
}
