//
//  ContentView.swift
//  Attribute wrapper
//
//  Created by Jovins.Huang on 2024/7/18.
//

import SwiftUI
import SwiftData

struct ContentView: View {

    // @AccessibilityFocusState(for: .switchControl) var focusField: FocusField?
    @AccessibilityFocusState(for: .voiceOver) var focused: FocusField?

    var body: some View {
        VStack(spacing: 16) {
            Button("Press me") {
                print("Press")
                focused = .press
            }
            .accessibilityFocused($focused, equals: .press)

            Button("Click me") {
                print("Click")
            }
            .accessibilityFocused($focused, equals: .click)
        }
    }
}

enum FocusField: Hashable {
    case press
    case click
}

#Preview {
    ContentView()
}
