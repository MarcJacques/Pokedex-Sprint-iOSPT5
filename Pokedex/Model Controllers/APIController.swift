//
//  APIController.swift
//  Pokedex
//
//  Created by Marc Jacques on 3/22/20.
//  Copyright © 2020 Marc Jacques. All rights reserved.
//

import Foundation
enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

enum NetworkError: Error {
    case encodingError
    case responseError
    case otherError(Error)
    case noData
    case badDecode
    case noToken // No bearer token
}

class APIController {
    let baseURL = URL(string: "https://pokeapi.co/api/v2/")!
    
    var pokemon: [Poke] = []
    
    private var readingListURL: URL? {
        let fileManager = FileManager.default
        guard let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documents.appendingPathComponent("pokemon.plist")
    }
    
    init() {
        loadFromPersistentStore()
    }
    
    func getPokemon(with searchTerm: String, completion: @escaping (Result<Poke, NetworkError>) -> Void) {
        let searchURL = baseURL
            .appendingPathComponent("pokemon")
            .appendingPathComponent(searchTerm)
        
        
        var request = URLRequest(url: searchURL)
        request.httpMethod = HTTPMethod.get.rawValue
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error searching for pokemon on line \(#line) in \(#file): \(error)")
                completion(.failure(.otherError(error)))
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from searching for pokemon")
                completion(.failure(.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                
                var newPokemon = try decoder.decode(Pokemon.self, from: data)
                newPokemon.name = newPokemon.name.capitalized
                let poke = self.convertToPoke(pokemon: newPokemon)
                self.pokemon.append(poke)
                self.pokemon.sort { $0.id < $1.id }
                
                self.saveToPersistentStore()
                
                completion(.success(poke))
                return
            } catch {
                NSLog("Error decoding pokemon on line \(#line): \(error)")
                completion(.failure(.badDecode))
                return
            }
        }.resume()
    }
    
    func deletePokemon(index: Int) {
        pokemon.remove(at: index)
        saveToPersistentStore()
    }
    
    func convertToPoke(pokemon: Pokemon) -> Poke {
        guard let url = URL(string: pokemon.sprites.frontImage),
            let imageData = try? Data(contentsOf: url) else { fatalError() }
        let tempPoke = Poke(name: pokemon.name, id: pokemon.id, abilities: pokemon.abilities, types: pokemon.types, image: imageData)
        return tempPoke
    }
    
    func saveToPersistentStore() {
        guard let url = readingListURL else { return }
        
        do {
            let encoder = PropertyListEncoder()
            let data = try encoder.encode(pokemon)
            try data.write(to: url)
        } catch {
            print("Error saving pokemon data: \(error)")
        }
    }
    
    func loadFromPersistentStore() {
        let fileManager = FileManager.default
        guard let url = readingListURL, fileManager.fileExists(atPath: url.path) else { return }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            pokemon = try decoder.decode([Poke].self, from: data)
        } catch {
            print("Error loading pokemon data: \(error)")
        }
    }
    
}
