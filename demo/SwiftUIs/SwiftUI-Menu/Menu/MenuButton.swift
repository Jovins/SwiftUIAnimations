//
//  MenuButton.swift
//  SwiftUI-Menu
//
//  Created by Jovins on 2021/8/4.
//

import SwiftUI

struct MenuButton: View {
    
    @Binding var isActive: Bool
    @ObservedObject var menuItem: MenuItem
    var currentIndex: Int
    
    var body: some View {
        let menu = self.menuItem.menus[self.currentIndex]
        Circle()
            .fill(menu.color)
            .frame(width: self.isActive ? 50 : 20, height: self.isActive ? 50 : 20)
            .shadow(radius: 5)
            .overlay(Image(systemName: menu.icon))
            .foregroundColor(.white)
            .offset(x: self.isActive ? menuOffset().x : 0, y: self
                    .isActive ? menuOffset().y : -10)
            .onTapGesture {
                self.isActive.toggle()
                self.updateSelected()
            }
    }
    
    func updateSelected() {
        let menu = self.menuItem.menus[self.currentIndex]
        for i in 0..<self.menuItem.menus.count {
            self.menuItem.menus[i].selected = menu.id == self.menuItem.menus[i].id
        }
    }
    
    func menuOffset() -> (x: CGFloat, y: CGFloat) {
        switch self.menuItem.menus.count {
        case 1:
            return (0, 0)
        case 2:
            switch currentIndex {
            case 0:
                return (-70, -70)
            default:
                return (70, -70)
            }
        case 3:
            switch currentIndex {
            case 0:
                return (-70, -70)
            case 1:
                return (0, -110)
            default:
                return (70, -70)
            }
        case 4:
            switch currentIndex {
            case 0:
                return (-90, -40)
            case 1:
                return (-45, -110)
            case 2:
                return (45, -110)
            default:
                return (90, -40)
            }
        default:
            switch currentIndex {
            case 0:
                return (-100, -20)
            case 1:
                return (-70, -80)
            case 2:
                return (0, -110)
            case 3:
                return (70, -80)
            default:
                return (100, -20)
            }
        }
    }
}


struct SelectedMenuButton: View {
    
    @Binding var isActivated: Bool
    var menuModel: MenuModel
    
    var body: some View {
        Circle()
            .fill(menuModel.color)
            .frame(width: isActivated ? 50 : 65, height: isActivated ? 50 : 65)
            .shadow(radius: 5)
            .overlay(Image(systemName: menuModel.icon))
            .foregroundColor(.white)
            .offset(x: 0, y: isActivated ? -20 : -10)
            .onTapGesture {
                self.isActivated.toggle()
        }
    }
}
