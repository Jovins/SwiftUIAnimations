//
//  UpdateStore.swift
//  SwiftUI-DesignCode
//
//  Created by Jovins on 2021/7/22.
//

import Combine
import SwiftUI

class UpdateStore: ObservableObject {
    
    var willChange = PassthroughSubject<Void, Never>()
    
    var updates: [Update] {
        didSet {
            willChange.send()
        }
    }
    
    init(updates: [Update] = []) {
        self.updates = updates
    }
}
