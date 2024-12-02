//
//  PokemonSpecies.swift
//  SwiftUIs
//
//  Created by Jovins on 2021/6/28.
//

import Foundation
import SwiftUI

struct PokemonSpecies: Codable {
    
    struct Color: Codable {
        
        let name: Name
        enum Name: String, Codable {
            case black, blue, brown, gray, green, pink, purple, red, white, yellow
            var color: SwiftUI.Color {
                return SwiftUI.Color("pokemon-\(rawValue)")
            }
        }
    }
    
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
    
    struct Genus: Codable, LanguageTextEntry {
        
        let genus: String
        let language: Language
        var text: String { genus }
    }
    
    let color: Color
    let names: [Name]
    let genera: [Genus]
    let flavorTextEntries: [FlavorTextEntry]
}
