//
//  ContentView.swift
//  FocusedObject
//
//  Created by Jovins.Huang on 2024/7/18.
//

import SwiftUI
import SwiftData

struct ContentView: View {

    @StateObject var focusModel = FocusModel()
    var body: some View {
        VStack {
            /// focusedSceneObject 在场景聚焦时便会自动提供数据，与当前视图是否可聚焦无关
            Text("Please Input: ")
                .focusedSceneObject(focusModel)
            TextEditor(text: $focusModel.text)
        }
    }
}

#Preview {
    ContentView()
}
