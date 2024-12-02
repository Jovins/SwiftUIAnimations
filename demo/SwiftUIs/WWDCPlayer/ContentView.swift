//
//  ContentView.swift
//  WWDCPlayer
//
//  Created by Jovins on 2021/7/22.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    
    @EnvironmentObject var userData: UserData
    let player = AVPlayer()
    let kWidth: CGFloat = UIScreen.main.bounds.width
    let kHeihgt: CGFloat = 9/16 * UIScreen.main.bounds.width
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack(alignment: .bottom) {
                    PlayerViewController(video: $userData.currentVideo)
                }
                .frame(width: kWidth, height: kHeihgt, alignment: .center)
                FavoriteToggleView()
                VideoListView()
            }
            .navigationBarTitle(Text(userData.currentVideo.title))
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif

struct FavoriteToggleView: View {
    
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        Toggle(isOn: $userData.showFavoriteOnly) {
            Text("Favorite Only")
                .foregroundColor(.yellow)
        }
        .padding([.leading, .trailing], 20)
    }
}

struct VideoListView: View {
    
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        List {
            ForEach(allWeekDays) { day in
                Section(header: Text(day.rawValue.uppercased()).fontWeight(.bold)) {
                    ForEach(self.userData.videos.filter { $0.weekDay == day }) { video in
                        if !self.userData.showFavoriteOnly || video.isFavorite {
                            VideoRow(video: video, isFavorite: video.isFavorite)
                        }
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
    }
}
