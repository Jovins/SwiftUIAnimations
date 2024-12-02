//
//  WeekDay.swift
//  WWDCPlayer
//
//  Created by Jovins on 2021/7/22.
//

import SwiftUI

enum WeekDay: String, CaseIterable, Identifiable {
    
    var id: String {
        return self.rawValue
    }
    case monday
    case tuesday
    case wednesday
    case trursday
    case friday
}

let allWeekDays = WeekDay.allCases
