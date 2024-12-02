//
//  StaggeredGrid.swift
//  ScrollowRefreshable
//
//  Created by Jovins on 2021/8/26.
//

import SwiftUI

struct StaggeredGrid<Content: View, T: Identifiable>: View  where T : Hashable {
    
    // it will return each object from collection to build View...
    var content: (T) -> Content
    var list : [T]
    var columns: Int
    var showsIndicator: Bool
    var spacing: CGFloat
    
    // Init...
    init(columns: Int, showsIndicator: Bool = false, spacing: CGFloat = 10 ,list: [T], @ViewBuilder content: @escaping (T) -> Content) {
        self.content = content
        self.list = list
        self.columns = columns
        self.showsIndicator = showsIndicator
        self.spacing = spacing
    }
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: self.showsIndicator) {
            HStack(alignment: .top) {
                ForEach(setupGrids(), id: \.self) { data in
                    LazyVStack(spacing: self.spacing) {
                        ForEach(data) { obj in
                            content(obj)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }
    
    func setupGrids() -> [[T]] {
        
        var gridArray: [[T]] = Array(repeating: [], count: self.columns)
        var currentIndex: Int = 0
        for obj in self.list {
            
            gridArray[currentIndex].append(obj)
            if currentIndex == (columns - 1) {
                currentIndex = 0
            } else {
                currentIndex += 1
            }
        }
        return gridArray
    }
}

struct StaggeredGrid_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
