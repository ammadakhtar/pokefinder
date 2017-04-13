//
//  Pokemon.swift
//  PokemonGo+
//
//  Created by Ammad on 14/04/2017.
//  Copyright © 2017 Ammad. All rights reserved.
//

import UIKit

class PokeCell: UICollectionViewCell {
    
    @IBOutlet weak var thumgImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    
    
    var pokemon : Pokemon!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 5.0
    }
    
    func configureCell(_ pokemon: Pokemon) {
        self.pokemon = pokemon
        nameLbl.text = pokemon.name.capitalized
        thumgImg.image = UIImage(named: "\(pokemon.pokedexId)")
        print(pokemon.pokedexId)
    }
    
    
}
