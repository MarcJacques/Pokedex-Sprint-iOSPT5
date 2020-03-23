//
//  PokemonDetailViewController.swift
//  Pokedex
//
//  Created by Marc Jacques on 3/22/20.
//  Copyright © 2020 Marc Jacques. All rights reserved.
//

import UIKit

class PokemonDetailViewController: UIViewController {

    var apiController: APIController?
        var pokemon: Poke?
        
        @IBOutlet weak var pokemonSearchBar: UISearchBar!
        @IBOutlet weak var nameLabel: UILabel!
        @IBOutlet weak var pokemonImageView: UIImageView!
        @IBOutlet weak var pokemonBackgroundImageView: UIImageView!
        @IBOutlet weak var pokemonCardImageView: UIImageView!
        @IBOutlet weak var idLabel: UILabel!
        @IBOutlet weak var idNumberLabel: UILabel!
        @IBOutlet weak var abilitiesListLabel: UILabel!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            setUI()
            
            pokemonSearchBar.delegate = self
            updateViews()
            // Do any additional setup after loading the view.
        }
        
        func setUI() {
            navigationController?.navigationBar.barTintColor = .top
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.bot]
            navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.bot]
            
            pokemonSearchBar.barTintColor = .mid
            pokemonSearchBar.setTextFieldColor(color: .bot)
            
            if let backColor = typeColor() {
                view.backgroundColor = backColor
            } else {
                view.backgroundColor = .bot
            }
        }
        
        func updateViews() {
            if let pokemon = pokemon {
                unhide()
                setUI()
                
                nameLabel.text = pokemon.name
                idNumberLabel.text = "\(pokemon.id)"
                abilitiesListLabel.text = getAbilitiesString()
                
                pokemonImageView.image = UIImage(data: pokemon.image)
                pokemonBackgroundImageView.image = UIImage(named: "Background")
                
            } else {
                nameLabel.isHidden = true
                idLabel.isHidden = true
                idNumberLabel.isHidden = true
                abilitiesListLabel.isHidden = true
                pokemonCardImageView.image = nil
            }
        }
        
        func unhide() {
            nameLabel.isHidden = false
            idLabel.isHidden = false
            idNumberLabel.isHidden = false
            abilitiesListLabel.isHidden = false
            pokemonCardImageView.image = UIImage(named: "card")
        }
        
        func getAbilitiesString() -> String {
            guard let pokemon = pokemon else { return "" }
            
            var abilities = ""
            for ability in 0...pokemon.abilities.count - 1 {
                if ability == pokemon.abilities.count - 1 {
                    abilities += "\(pokemon.abilities[ability].ability.name.capitalized)"
                } else {
                    abilities += "\(pokemon.abilities[ability].ability.name.capitalized)\n\n"
                }
            }
            return abilities
        }
        
        func typeColor() -> UIColor? {
            if let pokemon = pokemon {
                var index: Int = 0
                if pokemon.types.count == 2 { index = 1 }
                if pokemon.types[index].type.name == "bug" {
                    return UIColor(red:0.63, green:0.92, blue:0.00, alpha:1.00)
                } else if pokemon.types[index].type.name == "dark" {
                    pokemonCardImageView.image = UIImage(named: "darkCard")
                    return UIColor(red:0.11, green:0.13, blue:0.12, alpha:1.00)
                } else if pokemon.types[index].type.name == "dragon" {
                    return UIColor(red:0.41, green:0.39, blue:0.20, alpha:1.00)
                } else if pokemon.types[index].type.name == "electric" {
                    pokemonCardImageView.image = UIImage(named: "lightningCard")
                    return UIColor(red:1.00, green:0.89, blue:0.00, alpha:1.00)
                } else if pokemon.types[index].type.name == "fairy" {
                    return UIColor(red:1.00, green:0.22, blue:0.64, alpha:1.00)
                } else if pokemon.types[index].type.name == "fighting" {
                    return UIColor(red:0.87, green:0.47, blue:0.07, alpha:1.00)
                } else if pokemon.types[index].type.name == "fire" {
                    pokemonCardImageView.image = UIImage(named: "fireCard")
                    return UIColor(red:1.00, green:0.23, blue:0.00, alpha:1.00)
                } else if pokemon.types[index].type.name == "flying" {
                    return UIColor(red:0.91, green:0.78, blue:0.87, alpha:1.00)
                } else if pokemon.types[index].type.name == "ghost" {
                    return UIColor(red:0.60, green:0.19, blue:0.60, alpha:1.00)
                } else if pokemon.types[index].type.name == "grass" {
                    return UIColor(red:0.61, green:0.87, blue:0.49, alpha:1.00)
                } else if pokemon.types[index].type.name == "ground" {
                    return UIColor(red:0.95, green:0.58, blue:0.19, alpha:1.00)
                } else if pokemon.types[index].type.name == "ice" {
                    return UIColor(red:0.46, green:0.61, blue:0.91, alpha:1.00)
                } else if pokemon.types[index].type.name == "normal" {
                    return UIColor(red:0.92, green:0.91, blue:0.91, alpha:1.00)
                } else if pokemon.types[index].type.name == "poison" {
                    return UIColor(red:0.54, green:0.31, blue:0.47, alpha:1.00)
                } else if pokemon.types[index].type.name == "psychic" {
                    return UIColor(red:0.72, green:0.54, blue:0.80, alpha:1.00)
                } else if pokemon.types[index].type.name == "rock" {
                    return UIColor(red:0.86, green:0.55, blue:0.09, alpha:1.00)
                } else if pokemon.types[index].type.name == "steel" {
                    return UIColor(red:0.90, green:0.87, blue:0.85, alpha:1.00)
                } else if pokemon.types[index].type.name == "water" {
                    pokemonCardImageView.image = UIImage(named: "waterCard")
                    return UIColor(red:0.00, green:0.61, blue:0.87, alpha:1.00)
                } else {
                    return nil
                }
            }
            return nil
        }
    }

    extension PokemonDetailViewController: UISearchBarDelegate {
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            guard let apiController = apiController,
                let searchTerm = pokemonSearchBar.text else { return }
            
            apiController.getPokemon(with: searchTerm.lowercased(), completion: { (result) in
                DispatchQueue.main.async {
                    do {
                        self.pokemon = try result.get()
                        self.updateViews()
                        self.pokemonSearchBar.endEditing(true)
                    } catch {
                        NSLog("Error fetching pokemon info: \(error)")
                        self.pokemonSearchBar.endEditing(true)
                        let alert = UIAlertController(title: "No Results", message: "Unable to find pokemon with name or ID: \"\(searchTerm)\". Please try again", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                }
            })
        }
    }
