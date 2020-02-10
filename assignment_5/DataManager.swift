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
    var placesDict: NSArray?
    var favoritesList: [String] = Array()
  
    //This prevents others from using the default '()' initializer
    fileprivate init() {
        loadAnnotationFromPlist()
    }
    
    // Your code (these are just example functions, implement what you need)
  
    func loadAnnotationFromPlist() {
        let dictionary = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Data", ofType: "plist")!);
        self.placesDict = dictionary?["places"] as? NSArray
    }
  
    func saveFavorites(name place: String) {
        favoritesList.append(place)
        listFavorites()
    }
  
    func deleteFavorite(name place: String) {
        for (index, name) in favoritesList.enumerated(){
            if name == place {
                favoritesList.remove(at: index)
                break;
            }
        }
        listFavorites()
    }
  
    func listFavorites() {
        print(favoritesList)
    }
    
    func isFavorites(name: String) -> Bool{
        for place in self.favoritesList {
            if place == name {
                return true
            }
        }
        return false
    }
}
