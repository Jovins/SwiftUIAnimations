//
//  Post.swift
//  ScrollowRefreshable
//
//  Created by Jovins on 2021/8/26.
//

import SwiftUI

struct Post: Hashable, Identifiable {
    
    var id: String = UUID().uuidString
    var img: String = ""
}
