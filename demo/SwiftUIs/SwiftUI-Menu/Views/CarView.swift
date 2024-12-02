//
//  CarView.swift
//  SwiftUI-Menu
//
//  Created by Jovins on 2021/8/4.
//

import SwiftUI

struct CarView: View {
    
    var body: some View {
        ZStack {
            Color(.blue)
                .edgesIgnoringSafeArea(.all)
            Image(systemName: "car.fill").font(.largeTitle)
                .foregroundColor(.white)
        }
    }
}

#if DEBUG
struct CarView_Previews: PreviewProvider {
    static var previews: some View {
        CarView()
    }
}
#endif
