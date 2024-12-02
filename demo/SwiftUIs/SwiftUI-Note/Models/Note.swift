//
//  Note.swift
//  SwiftUI-Note
//
//  Created by Jovins on 2021/7/21.
//

import SwiftUI

struct Note: Hashable, Codable, Identifiable {
    
    let id = UUID()
    var text: String = ""
    var date = Date()
}
