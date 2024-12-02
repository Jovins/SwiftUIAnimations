//
//  DarkModeView.swift
//  SwiftUI-Awesome
//
//  Created by Jovins on 2021/7/28.
//

import SwiftUI

struct DarkModeView: View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        
        ZStack {
            Color(UIColor(named: "accentColor")!).edgesIgnoringSafeArea(.all)
            VStack(alignment: .center) {
                VStack(alignment: .leading) {
                    
                    Text("Mode is")
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(Color.orange)
                        .multilineTextAlignment(.leading)
                    Text(colorScheme == .light ? "Light   " : "Dark   ")
                        .font(colorScheme == .light ? Font.custom("Condiment-Regular", size: 98) : Font.custom("Superclarendon", size: 78))
                        .foregroundColor(Color.orange.opacity(0.75))
                        .multilineTextAlignment(.leading)
                        .padding(.top, 20)
                        .frame(width: 250)
                }
                .padding(.trailing, 80)
            }
        }
    }
}

#if DEBUG
struct DarkModeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DarkModeView()
                .environment(\.colorScheme, .light)

            DarkModeView()
                .environment(\.colorScheme, .dark)
        }
    }
}
#endif
