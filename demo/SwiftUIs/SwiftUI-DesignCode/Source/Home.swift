//
//  Home.swift
//  SwiftUI-DesignCode
//
//  Created by Jovins on 2021/7/22.
//

import SwiftUI

let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0

struct Home: View {
    
    @State var show: Bool = false
    @State var showProfile: Bool = false
    @State var showUpdate = false
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            HomeList()
                .blur(radius: self.show ? 20 : 0)
                .scaleEffect(self.showProfile ? 0.95 : 1)
                .animation(.default)
            
            Button(action: { self.showUpdate.toggle() }) {
               CircleButton(icon: "bell")
                  .sheet(isPresented: self.$showUpdate) { UpdateList() }
            }
            .offset(x: 150, y: self.showProfile ? statusBarHeight : 80)
            .animation(.spring())
        }
        .background(Color("background"))
        .edgesIgnoringSafeArea(.all)
    }
}

#if DEBUG
struct Home_Previews: PreviewProvider {
   static var previews: some View {
      Home()
         .previewDevice("iPhone X")
   }
}
#endif

struct CircleButton: View {

   var icon = "person.crop.circle"
   var body: some View {
      return HStack {
         Image(systemName: icon)
            .foregroundColor(.primary)
      }
      .frame(width: 44, height: 44)
      .background(Color("button"))
      .cornerRadius(30)
      .shadow(color: Color("buttonShadow"), radius: 20, x: 0, y: 20)
   }
}
