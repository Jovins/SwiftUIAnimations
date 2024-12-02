//
//  VideoRow.swift
//  WWDCPlayer
//
//  Created by Jovins on 2021/7/22.
//

import SwiftUI

struct VideoRow: View {
    
    @EnvironmentObject var userData: UserData
    
    var video: Video
    var isFavorite: Bool = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                TitleText(text: video.title)
                    .padding(.bottom, 2)
                HStack {
                    DescriptionText(text: "Session \(video.id)")
                    DescriptionText(text: ".")
                    DescriptionText(text: video.platformString)
                }
            }
            Spacer()
            HStack(spacing: 16) {
                if userData.currentVideo == video {
                    Image(systemName: "music.mic")
                }
                Image(systemName: video.isFavorite ? "star.fill" : "star")
                    .foregroundColor(video.isFavorite ? Color.yellow : Color.gray)
                    .onTapGesture {
                        self.setFavorite(video: self.video)
                    }
            }
        }
        .padding([.top, .bottom], 10)
        .onTapGesture {
            self.setCurrentVideo(video: self.video)
        }
    }
    
    func setCurrentVideo(video: Video) {
        guard self.userData.currentVideo != self.video else {
            return
        }
        self.userData.currentVideo = self.video
    }
    
    func setFavorite(video: Video) {
        guard let index = userData.videos.firstIndex (where: { $0 == video }) else {
            return
        }
        self.userData.videos[index].isFavorite.toggle()
    }
}

#if DEBUG
struct VideoRow_Previews : PreviewProvider {
    static var previews: some View {
        VideoRow(video: videoList[0])
            .environmentObject(UserData())
    }
}
#endif

struct TitleText: View {
    
    let text: String
    var body: some View {
        Text(text)
            .foregroundColor(.primary)
            .bold()
    }
}

struct DescriptionText: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.footnote)
            .fontWeight(.semibold)
            .foregroundColor(.secondary)
    }
}
