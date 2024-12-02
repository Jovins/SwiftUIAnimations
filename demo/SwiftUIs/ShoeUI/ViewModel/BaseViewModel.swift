//
//  BaseViewModel.swift
//  BaseViewModel
//
//  Created by Jovins on 2021/8/31.
//

import SwiftUI

class BaseViewModel: ObservableObject {
    
    // tab...
    @Published var currentTab: Tab = .Home
    @Published var homeTab = "Sneakers"
    // Detail
    @Published var currentProduct: Product?
    @Published var showDetail: Bool = false
}

enum Tab: String {
    
    case Home = "home"
    case Heart = "heart"
    case ClipBoard = "clipboard"
    case Person = "person"
}

