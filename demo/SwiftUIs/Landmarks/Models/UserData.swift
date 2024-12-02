//
//  UserData.swift
//  Landmarks
//
//  Created by Jovins on 2021/7/22.
//

import Combine
import SwiftUI

final class UserData: ObservableObject {
    
    @Published var showFavoritesOnly = false
    @Published var landmarks = landmarkData
}
