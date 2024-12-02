//
//  ContentViewRow.swift
//  SwiftUI-Animation
//
//  Created by Jovins on 2021/7/23.
//

import SwiftUI

struct ContentViewRow: View {
    
    var title: String
    var body: some View {
        
        HStack {
            Text(self.title)
                .font(.subheadline)
                .foregroundColor(.black)
                .fontWeight(.light)
                .padding(.leading, 16)
                .padding(8)
            Spacer()
        }
    }
}

#if DEBUG
struct ContentViewRow_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewRow(title: "Test")
    }
}
#endif
