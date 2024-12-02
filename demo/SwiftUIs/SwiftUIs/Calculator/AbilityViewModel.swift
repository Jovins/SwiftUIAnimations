//
//  AbilityViewModel.swift
//  SwiftUIs
//
//  Created by Jovins on 2021/6/28.
//

import Foundation

struct AbilityViewModel: Identifiable, Codable {
    
    let ability: Ability
    var id: Int { ability.id }
    var name: String { ability.names.CN }
    var nameEN: String { ability.names.EN }
    var descriptionText: String { ability.flavorTextEntries.CN.newlineRemoved }
    var descriptionTextEN: String { ability.flavorTextEntries.EN.newlineRemoved }
    
    init(ability: Ability) {
        self.ability = ability
    }
}

extension AbilityViewModel: CustomStringConvertible {
    var description: String {
        "AbilityViewModel - \(id) - \(self.name)"
    }
}
