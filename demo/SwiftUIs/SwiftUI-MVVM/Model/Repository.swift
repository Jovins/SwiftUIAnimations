//
//  Repository.swift
//  SwiftUI-MVVM
//
//  Created by Jovins on 2021/7/28.
//

import SwiftUI

struct Repository: Decodable, Hashable, Identifiable {

    var id: Int64
    var fullName: String
    var description: String?
    var stargazersCount: Int = 0
    var owner: User
}
