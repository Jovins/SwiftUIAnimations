//
//  ShinyTestView.swift
//  Shine
//
//  Created by Jovins on 2021/8/1.
//

import SwiftUI

struct ShinyTestView: View {
    
    var body: some View {
        
        ZStack(alignment: .center) {
            
            Text("shiny")
                .font(.largeTitle)
                .fontWeight(.bold).shiny()
                .background(
                    RoundedRectangle(cornerRadius: 14.0)
                        .frame(width: 200.0, height: 70.0)
                        .shiny(.hyperGlossy(UIColor.systemGray5)))
        }
    }
}

#if DEBUG
struct ShinyTestView_Previews: PreviewProvider {
    static var previews: some View {
        ShinyTestView()
    }
}
#endif
