//
//  MenuModel.swift
//  SwiftUI-Menu
//
//  Created by Jovins on 2021/8/4.
//

import SwiftUI

struct MenuModel {
    
    let id = UUID()
    let color: Color
    let icon: String
    let menuView: AnyView
    var selected: Bool
}
