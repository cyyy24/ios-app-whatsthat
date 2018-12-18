//
//  PersistanceManager.swift
//  WhatsThat
//
//  Created by Yuan Cheng on 2017/11/19.
//  Copyright © 2017年 Yuan Cheng. All rights reserved.
//

import Foundation


// This class is used for storing user saved favorites.
class PersistanceManager {
    static let sharedInstance = PersistanceManager()
    
    let favoritesKey = "favorites"
    
    func savePhotoDetailsResult(_ savedFavorite: SavedFavorites) {
        let userDefaults = UserDefaults.standard
        
        var savedFavorites = fetchPhotoDetailsResult()
        savedFavorites.append(savedFavorite)
        
        let data = NSKeyedArchiver.archivedData(withRootObject: savedFavorites)
        
        userDefaults.set(data, forKey: favoritesKey)
    }
    
    func fetchPhotoDetailsResult() -> [SavedFavorites] {
        let userDefaults = UserDefaults.standard
        
        let data = userDefaults.object(forKey: favoritesKey) as? Data
        
        if let data = data {
            // Data is not nil, so use it
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? [SavedFavorites] ?? [SavedFavorites]()
        } else {
            // Data is nil
            return [SavedFavorites]()
        }
    }
    
    func deleteSavedFavorites(index: Int?) {
        var savedFavorites = fetchPhotoDetailsResult()
        
        if index != nil {
            savedFavorites.remove(at: index!)
            // Save the updated SavedFavorites object back
            let data = NSKeyedArchiver.archivedData(withRootObject: savedFavorites)
            UserDefaults.standard.set(data, forKey: favoritesKey)
        } else {
            return
        }
    }
}
// -------------------------------------------- OUTSIDE OF THIS CLASS -----------------------------------------------
