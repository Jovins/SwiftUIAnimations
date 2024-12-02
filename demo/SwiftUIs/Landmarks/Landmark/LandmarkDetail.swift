//
//  LandmarkDetail.swift
//  Landmarks
//
//  Created by Jovins on 2021/7/23.
//

import SwiftUI

struct LandmarkDetail: View {
    
    @EnvironmentObject var userData: UserData
    var landmark: Landmark
    var landmarkIndex: Int {
        self.userData.landmarks.firstIndex(where: { $0.id == landmark.id }) ?? 0
    }
    
    var body: some View {
        VStack {
            MapView(coordinate: self.landmark.locationCoordinate)
                .edgesIgnoringSafeArea(.top)
                .frame(height: 300)
            CircleImage(image: self.landmark.image(forSize: 250))
                .offset(x: 0, y: -130)
                .padding(.bottom, -130)
            VStack(alignment: .leading) {
                HStack {
                    Text(verbatim: self.landmark.name)
                        .font(.title)
                    Button(action: {
                        self.userData.landmarks[self.landmarkIndex].isFavorite.toggle()
                    }) {
                        if self.userData.landmarks[self.landmarkIndex].isFavorite {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        } else {
                            Image(systemName: "star")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                HStack(alignment: .top) {
                    Text(verbatim: self.landmark.park)
                        .font(.subheadline)
                    Spacer()
                    Text(verbatim: self.landmark.state)
                        .font(.subheadline)
                }
            }
            .padding()
            Spacer()
        }
    }
}

#if DEBUG
struct LandmarkDetail_Preview: PreviewProvider {
    static var previews: some View {
        let userData = UserData()
        return LandmarkDetail(landmark: userData.landmarks[0])
            .environmentObject(userData)
    }
}
#endif
