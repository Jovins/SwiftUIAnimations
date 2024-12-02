//
//  FocusedObjectApp.swift
//  FocusedObject
//
//  Created by Jovins.Huang on 2024/7/18.
//

import SwiftUI
import SwiftData

@main
struct FocusedObjectApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
                .scenePadding()
        }
        .commands {
            FocusCommand()
        }
    }
}
