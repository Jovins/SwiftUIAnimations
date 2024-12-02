//
//  LandmarkRow.swift
//  Landmarks
//
//  Created by Jovins on 2021/7/23.
//

import SwiftUI

struct LandmarkRow: View {
    
    var landmark: Landmark
    var body: some View {
        
        HStack {
            self.landmark.image(forSize: 50)
                .cornerRadius(8)
            Text(verbatim: self.landmark.name)
            Spacer()
            if self.landmark.isFavorite {
                Image(systemName: "star.fill")
                    .imageScale(.medium)
                    .foregroundColor(.yellow)
            }
        }
    }
}

#if DEBUG
struct LandmarkRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LandmarkRow(landmark: landmarkData[0])
            LandmarkRow(landmark: landmarkData[1])
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
#endif
