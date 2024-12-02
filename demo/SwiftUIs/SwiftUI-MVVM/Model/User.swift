//
//  User.swift
//  SwiftUI-MVVM
//
//  Created by Jovins on 2021/7/28.
//

import Foundation
import SwiftUI

struct User: Decodable, Hashable, Identifiable {
    
    var id: Int64
    var login: String
    var avatarUrl: URL
}
