//
//  FocusCommand.swift
//  FocusedObject
//
//  Created by Jovins.Huang on 2024/7/18.
//

import SwiftUI

class FocusModel: ObservableObject {
    @Published var text: String = ""
}

struct FocusCommand: Commands {
    
    @FocusedObject var focusModel: FocusModel?

    var body: some Commands {
        CommandMenu("Action") {
            Button("Clean") {
                focusModel?.text = ""
            }
        }
    }
}
