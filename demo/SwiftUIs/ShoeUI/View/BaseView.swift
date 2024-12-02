//
//  BaseView.swift
//  BaseView
//
//  Created by Jovins on 2021/8/31.
//

import SwiftUI

struct BaseView: View {
    
    @StateObject var baseData = BaseViewModel()
    
    // hide tab
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
       
        TabView(selection: self.$baseData.currentTab) {
            
            Home()
                .environmentObject(self.baseData)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.04))
                .tag(Tab.Home)
            Text("Heart")
                .tag(Tab.Heart)
            Text("ClipBoard")
                .tag(Tab.ClipBoard)
            Text("Person")
                .tag(Tab.Person)
        }
        .overlay (
            // Custom Tabbar
            HStack(spacing: 0) {
                TabbarButton(Tab: .Home)
                TabbarButton(Tab: .Heart)
                    .offset(x: -10)
                
                // center curved
                Button {
                    
                } label: {
                    Image("cart")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 26, height: 26)
                        .foregroundColor(.white)
                        .offset(x: -1)
                        .padding(18)
                        .background(Color("DarkBlue"))
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 5, y: 5)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: -5, y: -5)
                }
                .offset(y: -30)
                
                TabbarButton(Tab: .ClipBoard)
                    .offset(x: 10)
                TabbarButton(Tab: .Person)
            }
                .background(
                    Color.white
                    .clipShape(CustomCurveShape())
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: -5, y: -5)
                        .ignoresSafeArea(.container, edges: .bottom)
                )
            // hide tabbar when detail opens
                .offset(y: baseData.showDetail ? 200 : 0)
            ,alignment: .bottom)
    }
    
    @ViewBuilder
    func TabbarButton(Tab: Tab) -> some View {
        
        Button {
            withAnimation {
                self.baseData.currentTab = Tab
            }
        } label: {
            Image(Tab.rawValue)
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25, alignment: .center)
                .foregroundColor(self.baseData.currentTab == Tab ? Color("DarkBlue") : Color.gray.opacity(0.8))
                .frame(maxWidth: .infinity)
        }

    }
}

struct BaseView_Previews: PreviewProvider {
    static var previews: some View {
        BaseView()
    }
}
