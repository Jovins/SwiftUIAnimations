//
//  LandmarkList.swift
//  Landmarks
//
//  Created by Jovins on 2021/7/23.
//

import SwiftUI

struct LandmarkList: View {
    
    @EnvironmentObject private var userData: UserData
    
    var body: some View {
        NavigationView {
            List {
                Toggle(isOn: $userData.showFavoritesOnly, label: {
                    Text("Show Favorites Only")
                })
                ForEach(self.userData.landmarks) { landmark in
                    
                    if !self.userData.showFavoritesOnly || landmark.isFavorite {
                        NavigationLink(
                        destination: LandmarkDetail(landmark: landmark)
                            .environmentObject(self.userData)) {
                            LandmarkRow(landmark: landmark)
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Landmarks"), displayMode: .large)
        }
    }
}

#if DEBUG
struct LandmarksList_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone SE", "iPhone XS Max"], id: \.self) { deviceName in
            LandmarkList()
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
        .environmentObject(UserData())
    }
}
#endif
