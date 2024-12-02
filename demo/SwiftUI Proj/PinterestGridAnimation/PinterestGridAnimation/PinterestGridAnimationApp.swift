//
//  PinterestGridAnimationApp.swift
//  PinterestGridAnimation
//
//  Created by Jovins.Huang on 2024/7/17.
//

import SwiftUI
import SwiftData

@main
struct PinterestGridAnimationApp: App {

    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase, { oldValue, newValue in
            switch newValue {
            case .active:
                print("active")
            case .background:
                print("background")
            case .inactive:
                print("inactive")
            @unknown default:
                fatalError()
            }
        })
    }
}
