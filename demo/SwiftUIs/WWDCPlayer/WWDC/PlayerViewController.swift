//
//  PlayerViewController.swift
//  WWDCPlayer
//
//  Created by Jovins on 2021/7/22.
//

import SwiftUI
import AVKit

struct PlayerViewController: UIViewControllerRepresentable {
    
    @Binding var video: Video
    private let player = AVPlayer()
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        
        let playerVC = AVPlayerViewController()
        playerVC.player = self.player
        return playerVC
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        
        guard let url = URL(string: video.url) else { return }
        resetPlayer(uiViewController)
        let item = AVPlayerItem(url: url)
        uiViewController.player?.replaceCurrentItem(with: item)
    }
    
    func resetPlayer(_ vc: AVPlayerViewController) {
        vc.player?.pause()
        vc.player?.replaceCurrentItem(with: nil)
    }
}
