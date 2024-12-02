//
//  ContentView.swift
//  SwiftUI-Menu
//
//  Created by Jovins on 2021/8/4.
//

import SwiftUI

struct ContentView: View {

    @State var isActive: Bool = false
    @ObservedObject var menuItem = MenuItem(menus: [MenuModel(color: .red, icon: "house.fill", menuView: AnyView(HomeView()), selected: true), MenuModel(color: .blue, icon: "car.fill", menuView: AnyView(CarView()), selected: false), MenuModel(color: .green, icon: "map.fill", menuView: AnyView(SimpleView()), selected: false)])
    
    var body: some View {
        ZStack {
            self.menuItem.selectedMenu.menuView
            ZStack {
                Color.black.opacity(self.isActive ? 0.2 : 0)
                VStack {
                    Spacer()
                    ZStack {
                        ForEach(0..<self.menuItem.menus.count) { index in
                            MenuButton(isActive: self.$isActive, menuItem: self.menuItem, currentIndex: index)
                        }
                        SelectedMenuButton(isActivated: $isActive, menuModel: self.menuItem.selectedMenu)
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(self.isActive ? .all : .horizontal)
        .animation(.spring())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
