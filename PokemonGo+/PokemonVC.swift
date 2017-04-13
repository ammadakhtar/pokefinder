//
//  PokemonVC.swift
//  PokemonGo+
//
//  Created by Ammad on 13/04/2017.
//  Copyright © 2017 Ammad. All rights reserved.
//

import UIKit

class ViewController2: UIViewController  , UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout ,UISearchBarDelegate {
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var searchbar: UISearchBar!
    var pokemon = [Pokemon]()
    var filteredpokemon = [Pokemon]()
    var inSearchMode = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        collection.delegate = self
        collection.dataSource = self
        searchbar.delegate = self
        searchbar.returnKeyType = UIReturnKeyType.done
        parseCSV()
    }

    func parseCSV() {
        
        let path = Bundle.main.path(forResource: "pokemon", ofType: "csv")!
        do {
            
            let csv = try CSV(contentsOfURL: path)
            let rows = csv.rows
            for row in rows {
                let pokeID = Int(row["id"]!)!
                let name = row["identifier"]!
                let poke = Pokemon(name: name, pokedexId: pokeID)
                pokemon.append(poke)
            }
        }
        catch let error as NSError
        {
            print(error.description)
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pokeCell", for: indexPath) as? PokeCell {
            let poke : Pokemon!
            if inSearchMode
            {
                poke = filteredpokemon[indexPath.row]
                cell.configureCell(poke)
            }
            else {
                poke = pokemon[indexPath.row]
                cell.configureCell(poke)
            }
            return cell
        }
        else
        {
            return UICollectionViewCell()
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if inSearchMode
        {
            return filteredpokemon.count
        }
        
        return pokemon.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let poke : Pokemon!
        if inSearchMode {
            poke = filteredpokemon[indexPath.row]
            
        }
        else {
            poke = pokemon[indexPath.row]
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       return CGSize(width: 65, height: 75)
    }

    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == ""
        {
            searchBar.perform(#selector(self.resignFirstResponder), with: nil, afterDelay: 0.1)
            inSearchMode = false
            collection.reloadData()
            view.endEditing(true)
            
        }
        else
        {
            inSearchMode = true
            let lower = searchBar.text!.lowercased()
            filteredpokemon = pokemon.filter({$0.name.range(of: lower) != nil})
            collection.reloadData()
        }
    }

}




extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
