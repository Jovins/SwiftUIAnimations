//
//  SideMenu.swift
//  SwiftUI-Awesome
//
//  Created by Jovins on 2021/8/1.
//

import UIKit
import SwiftUI

struct SideMenu: View {
    
    @State var isActive: Bool = false
    
    var body: some View {
        ZStack {
            SideMenuBgView()
            ZStack {
                RoundedRectangle(cornerRadius: self.isActive ? 32 : 0)
                    .foregroundColor(Color(hex: 0x90EE90))
                    .shadow(radius: self.isActive ? 16 : 0)
                VStack {
                    HStack {
                        Button(action: { self.isActive.toggle() }, label: {
                            Image(uiImage: menuListImage)
                                .accentColor(.white)
                                .frame(width: 40, height: 40, alignment: .center)
                                .scaleEffect(self.isActive ? 1.2 : 1.0)
                        })
                        .padding(.top, 64)
                        .padding(.leading, 24)
                        Spacer()
                    }
                    Spacer()
                }
            }
            .offset(x: self.isActive ? 320 : 0)
            .scaleEffect(self.isActive ? 0.8 : 1)
            .animation(.spring(response: 0.5)).edgesIgnoringSafeArea(.all)
        }
    }
}

#if DEBUG
struct SideMenu_Previews: PreviewProvider {
    static var previews: some View {
        SideMenu()
    }
}
#endif

let menuListImage: UIImage = UIImage(named: "menu.list")!
    .withConfiguration(UIImage.SymbolConfiguration(pointSize: 32, weight: .regular, scale: .medium))
