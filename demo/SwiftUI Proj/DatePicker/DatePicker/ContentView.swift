//
//  ContentView.swift
//  DatePicker
//
//  Created by Jovins.Huang on 2024/7/18.
//

import SwiftUI
import SwiftData

struct ContentView: View {

    @State private var date: Date = .now
    
    var body: some View {
        NavigationStack {
            DateTextField(date: $date) { date in
                return date.formatted()
            }
            .navigationTitle("Date Picker")
        }
    }
}

#Preview {
    ContentView()
}
