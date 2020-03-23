//
//  PokedexTableViewController.swift
//  Pokedex
//
//  Created by Marc Jacques on 3/22/20.
//  Copyright © 2020 Marc Jacques. All rights reserved.
//

import UIKit

class PokedexTableViewController: UITableViewController {
        
        @IBOutlet var pokeballTextView: UITableView!
        
        let apiController = APIController()

        override func viewDidLoad() {
            super.viewDidLoad()
            setUI()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(true)
            tableView.reloadData()
        }
        
        func setUI() {
            if #available(iOS 13.0, *) {
                let navBarAppearance = UINavigationBarAppearance()
                navBarAppearance.configureWithOpaqueBackground()
                navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
                navBarAppearance.backgroundColor = .top
                navigationController?.navigationBar.standardAppearance = navBarAppearance
                navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
            } else {
                navigationController?.navigationBar.barTintColor = .top
                navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.bot]
                navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.bot]
            }
            navigationController?.navigationBar.tintColor = .bot
            view.backgroundColor = .bot
        }

        // MARK: - Table view data source
        override func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }

        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return apiController.pokemon.count
        }

        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PokeCell", for: indexPath)

            let tempPokemon = apiController.pokemon[indexPath.row]
            cell.textLabel?.text = tempPokemon.name
            
            cell.backgroundColor = .bot
            
            cell.imageView?.image = UIImage(data: tempPokemon.image)
            
            
            return cell
        }
        
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                apiController.deletePokemon(index: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }

        // MARK: - Navigation
        // In a storyboard-based application, you will often want to do a little preparation before navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "ShowSearchSegue" {
                guard let detailVC = segue.destination as? PokemonDetailViewController else { return }
                detailVC.apiController = apiController
            } else if segue.identifier == "ShowPokeDetailSegue" {
                guard let detailVC = segue.destination as? PokemonDetailViewController,
                    let indexPath = tableView.indexPathForSelectedRow else { return }
               detailVC.pokemon = apiController.pokemon[indexPath.row]
            }
        }
    }
