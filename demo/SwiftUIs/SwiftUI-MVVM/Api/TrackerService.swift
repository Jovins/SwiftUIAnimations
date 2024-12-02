//
//  TrackerService.swift
//  SwiftUI-MVVM
//
//  Created by Jovins on 2021/7/28.
//

import Foundation

enum TrackEventType {
    
    case listView
}

protocol TrackerType {
    
    func log(type: TrackEventType)
}

final class TrackerService: TrackerType {
    
    func log(type: TrackEventType) {
        
    }
}
