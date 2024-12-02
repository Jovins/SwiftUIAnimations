//
//  UserData.swift
//  WWDCPlayer
//
//  Created by Jovins on 2021/7/22.
//

import SwiftUI
import Combine

final class UserData: ObservableObject  {
    
    @Published var showFavoriteOnly = false
    @Published var videos = videoList
    @Published var currentVideo = videoList[0]
}
