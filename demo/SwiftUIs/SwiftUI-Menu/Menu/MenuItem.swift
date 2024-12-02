//
//  MenuItem.swift
//  SwiftUI-Menu
//
//  Created by Jovins on 2021/8/4.
//

import SwiftUI

class MenuItem: ObservableObject {
    
    @Published var menus: [MenuModel]
    
    var selectedMenu: MenuModel {
        
        guard let selected = menus.filter({$0.selected}).first  else {
            fatalError("You need to set one of the MenuModel in MenuItem.menus as selected: true")
        }
        return selected
    }
    
    init(menus: [MenuModel]) {
        self.menus = menus
    }
}
