//
//  ExperimentService.swift
//  SwiftUI-MVVM
//
//  Created by Jovins on 2021/7/28.
//

import Foundation

enum ExperimentKey: String {
    
    case showIcon
}

protocol ExperimentServiceType {
    
    func experiment(for key: ExperimentKey) -> Bool
}

final class ExperimentService: ExperimentServiceType {
    
    func experiment(for key: ExperimentKey) -> Bool {
        
        return true
    }
}
