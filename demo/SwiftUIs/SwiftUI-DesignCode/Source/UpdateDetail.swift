//
//  UpdateDetail.swift
//  SwiftUI-DesignCode
//
//  Created by Jovins on 2021/7/22.
//

import SwiftUI

struct UpdateDetail: View {
    
    var title = "SwiftUI"
    var text = "Loading..."
    var image = "Illustration1"
    
    var body: some View {
        
        VStack(spacing: 16.0) {
            Text(self.title)
                .font(.largeTitle)
                .fontWeight(.heavy)
            Image(self.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 200)
            Text(self.text)
                .lineLimit(nil)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            Spacer()
        }
        .padding(30.0)
    }
}

#if DEBUG
struct UpdateDetail_Previews: PreviewProvider {
   static var previews: some View {
      UpdateDetail()
   }
}
#endif
