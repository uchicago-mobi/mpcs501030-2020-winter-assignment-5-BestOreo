//
//  DataManager.swift
//  assignment_5
//
//  Created by 葛帅琦 on 2/9/20.
//  Copyright © 2020 Shuaiqi Ge. All rights reserved.
//

import UIKit

public class DataManager {
  
    // MARK: - Singleton Stuff
    public static let sharedInstance = DataManager()
    var placesDict: Array = [Dictionary<String, Any>]()
    let favoritesDefaults = UserDefaults.standard
    var favoritesList: [String] = Array()
  
    //This prevents others from using the default '()' initializer
    fileprivate init() {
        loadAnnotationFromPlist()
        loadFavoriteFromDefault()
        print(favoritesDefaults.dictionaryRepresentation().keys)
        print(favoritesDefaults.dictionaryRepresentation().keys.count)
    }
    
    func loadFavoriteFromDefault() {
        if !favoritesDefaults.dictionaryRepresentation().keys.contains("FavoritePlaces") {
            favoritesDefaults.set([], forKey: "FavoritePlaces")
        }
        for place in favoritesDefaults.stringArray(forKey: "FavoritePlaces") ?? [String]() {
            favoritesList.append(place)
        }
    }
      
    func loadAnnotationFromPlist() {
        let dictionary = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Data", ofType: "plist")!);
        for place in (dictionary?["places"] as? [Dictionary<String, AnyObject>])!{
            let name = place["name"] as! String
            let description = place["description"] as! String
            let long = place["long"] as! Double
            let lat = place["lat"] as! Double
            placesDict.append(["name": name, "description": description, "long": long, "lat": lat])
        }
    }
      
    func saveFavorites(name place: String) {
        favoritesList.append(place)
        favoritesDefaults.setValue(favoritesList, forKey: "FavoritePlaces")
    }
  
    func deleteFavorite(name place: String) {
        for (index, location) in favoritesList.enumerated(){
            if location == place {
                favoritesList.remove(at: index)
                break;
            }
        }
        favoritesDefaults.setValue(favoritesList, forKey: "FavoritePlaces")
    }
  
    func listFavorites() -> [String] {
        return favoritesList
    }
    
    func isFavorites(name: String) -> Bool{
        for location in favoritesList {
            if location == name {
                return true
            }
        }
        return false
    }
    
    func getLocation(name: String) -> Dictionary<String,Double> {
        var result = ["long": 360.0, "lat": 360.0]
        for place in placesDict{
            print((place["name"] as! String), name)
            if (place["name"] as! String) == name {
                result["long"] = (place["long"] as! Double)
                result["lat"] = (place["lat"] as! Double)
            }
        }
        return result
    }
}
