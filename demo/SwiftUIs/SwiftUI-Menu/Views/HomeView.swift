//
//  HomeView.swift
//  SwiftUI-Menu
//
//  Created by Jovins on 2021/8/4.
//

import SwiftUI

struct HomeView: View {
    
    @State var isShowing: Bool = false
    var body: some View {
        
        NavigationView {
            ZStack {
                Color(.white)
                    .edgesIgnoringSafeArea(.all)
                NavigationLink(destination: Text("Push View"), isActive: $isShowing) {
                    EmptyView()
                }
                Text("Home View")
                    .navigationBarTitle(Text("Circle Menus"))
                    .navigationBarItems(trailing: Button(action: {
                        self.isShowing = true
                    }, label: {
                        Text("Push")
                    }))
            }
        }
    }
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
#endif
