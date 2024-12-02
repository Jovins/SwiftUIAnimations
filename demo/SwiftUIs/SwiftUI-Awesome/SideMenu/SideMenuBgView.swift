//
//  SideMenuBgView.swift
//  SwiftUI-Awesome
//
//  Created by Jovins on 2021/8/1.
//

import SwiftUI

struct SideMenuBgView: View {
    var body: some View {
        ZStack {
            Color(hex: 0xDAA520)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

#if DEBUG
struct SideMenuBgView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuBgView()
    }
}
#endif
