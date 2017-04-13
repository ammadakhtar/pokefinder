//
//  Pokemon.swift
//  PokemonGo+
//
//  Created by Ammad on 14/04/2017.
//  Copyright © 2017 Ammad. All rights reserved.
//

import Foundation
class Pokemon {
    
     var name: String!
     var pokedexId: Int!
    init(name: String , pokedexId: Int) {
        self.name = name
        self.pokedexId = pokedexId
    }
}
