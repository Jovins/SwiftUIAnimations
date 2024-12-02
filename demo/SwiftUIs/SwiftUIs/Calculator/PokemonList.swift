//
//  PokemonList.swift
//  SwiftUIs
//
//  Created by Jovins on 2021/6/28.
//

import Foundation
import SwiftUI

struct PokemonList: View {
    
    @State var expandingIndex: Int?
    @State var searchText: String = ""
    
    var body: some View {
        
        ScrollView {
            LazyVStack {
                TextField("搜索", text: $searchText)
                    .frame(height: 40)
                    .padding(.horizontal, 25)
                ForEach(PokemonViewModel.all) { pokemon in
                    PokemonInfoRow(model: pokemon,
                                   expanded: self.expandingIndex == pokemon.id)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.55, dampingFraction: 0.425, blendDuration: 0)) {
                                if self.expandingIndex == pokemon.id {
                                    self.expandingIndex = nil
                                } else {
                                    self.expandingIndex = pokemon.id
                                }
                            }
                        }
                }
            }
        }
//        .overlay(
//            VStack {
//                Spacer()
//                PokemonInfoPanel(model: .sample(id: 1))
//            }.edgesIgnoringSafeArea(.bottom)
//        )
    }
}

