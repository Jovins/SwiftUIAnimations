//
//  UnidirectionalDataFlowType.swift
//  SwiftUI-MVVM
//
//  Created by Jovins on 2021/7/28.
//

import Foundation

protocol UnidirectionalDataFlowType {
    
    associatedtype InputType
    func apply(_ input: InputType)
}
