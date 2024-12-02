//
//  CustomTabbar.swift
//  SwiftUI-Awesome
//
//  Created by Jovins on 2021/8/20.
//

import SwiftUI

struct CustomTabbar: View {
    
    @State var index: Int = 0
    
    var body: some View {
        
        VStack {
            
            ZStack {
                if self.index == 0 {
                    Color.black.opacity(0.05).edgesIgnoringSafeArea(.top)
                } else if self.index == 1 {
                    Color.green.edgesIgnoringSafeArea(.top)
                } else if self.index == 2 {
                    Color.yellow.edgesIgnoringSafeArea(.top)
                } else {
                    Color.purple.edgesIgnoringSafeArea(.top)
                }
                
            }
            .edgesIgnoringSafeArea(.all)
            .padding(.bottom, -35)
            CustomTabs(index: self.$index)
        }
    }
}

struct CustomTabbar_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabbar()
    }
}

struct CustomTabs: View {
    
    @Binding var index: Int
    
    var body: some View {
        
        HStack {
            
            Button(action: {
                
                self.index = 0
            }) {
                Image("tab_home_selected")
            }
            .foregroundColor(Color.black.opacity(self.index == 0 ? 1 : 0.25))
            
            Spacer(minLength: 0)
            
            Button(action: {
                self.index = 1
            }) {
                Image("tab_moment_selected")
            }
            .foregroundColor(Color.black.opacity(self.index == 1 ? 1 : 0.25))
            .offset(x: 10)
            
            Spacer(minLength: 0)
            
            Button(action: {
                
            }) {
                Image("tab_add_selected").renderingMode(.template)
            }
            .frame(width: 44, height: 44, alignment: .center)
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(22)
            .offset(y: -24)
            
            Spacer(minLength: 0)
            
            Button(action: {
                self.index = 2
            }) {
                Image("tab_message_selected")
            }
            .foregroundColor(Color.black.opacity(self.index == 2 ? 1 : 0.25))
            .offset(x: -10)
            
            Spacer(minLength: 0)
            
            Button(action: {
                self.index = 3
            }) {
                Image("tab_add_mine")
            }
            .foregroundColor(Color.black.opacity(self.index == 3 ? 1 : 0.25))
        }
        .padding(.horizontal, 35)
        .padding(.top, 35)
        .background(Color.white)
        .clipShape(CShape())
    }
}

struct CShape: Shape {
    
    func path(in rect: CGRect) -> Path {
        
        return Path { path in
                
            path.move(to: CGPoint(x: 0, y: 35))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: 35))
            
            path.addArc(center: CGPoint(x: rect.width / 2, y: 35), radius: 35, startAngle: .zero, endAngle: .init(degrees: 180), clockwise: true)
        }
    }
}
