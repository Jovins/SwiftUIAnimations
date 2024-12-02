//
//  ScrollowRefreshable.swift
//  ScrollowRefreshable
//
//  Created by Jovins on 2021/8/26.
//

import SwiftUI

// run XCode 13, iOS 15
struct ScrollowRefreshable<Content: View>: View {
    
    var content: Content
    var onRefresh: () async -> ()
    
    init(title: String, tintColor: Color, @ViewBuilder content: @escaping () -> Content, onRefresh: @escaping () async ->()) {
        self.content = content()
        self.onRefresh = onRefresh
        
        // Modify Refreshable Appearance
        UIRefreshControl.appearance().attributedTitle = NSAttributedString(string: title, attributes: [.font: UIFont.boldSystemFont(ofSize: 15), .foregroundColor: UIColor(tintColor)])
        UIRefreshControl.appearance().tintColor = UIColor(tintColor)
    }
    
    var body: some View {
        List {
            content
                .listRowSeparatorTint(.clear)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
        .listStyle(.plain)
        .refreshable {
            await onRefresh()
        }
    }
}

struct ScrollowRefreshable_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
