//
//  Ability.swift
//  SwiftUIs
//
//  Created by Jovins on 2021/6/28.
//

import Foundation

struct Ability: Codable {
    
    let id: Int
    let names: [Name]
    let flavorTextEntries: [FlavorTextEntry]
    
    struct Name: Codable, LanguageTextEntry {
        let name: String
        let language: Language
        var text: String { name }
    }
    
    struct FlavorTextEntry: Codable, LanguageTextEntry {
        let flavorText: String
        let language: Language
        var text: String { flavorText }
    }
}
