//
//  FavoritePhotosTableViewController.swift
//  WhatsThat
//
//  Created by Yuan Cheng on 2017/12/9.
//  Copyright © 2017年 Yuan Cheng. All rights reserved.
//

import UIKit


class FavoritePhotosTableViewController: UITableViewController {
    
    var savedFavorites = [SavedFavorites]()

    override func viewDidLoad() {
        super.viewDidLoad()
                
        print("Favorites did load!")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        savedFavorites = PersistanceManager.sharedInstance.fetchPhotoDetailsResult()
                
        print("FavoritePhotosTableViewController will appear!")
    }

    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedFavorites.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoritesCell", for: indexPath) as! FavoritesTableViewCell

        // Configure the cell...
        let savedFavorite = savedFavorites[indexPath.row]
        
        cell.savedResultImageView.image = savedFavorite.image
        cell.savedResultNameLabel.text = savedFavorite.name.capitalized
        
        return cell
    }
    
    // Customize the cell height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 70.0
    }
    
    
    // Direct user to PhotoDetailsVC showing details of the chosen savedFavorites
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showPhotoDetailsFromFavorites", sender: savedFavorites[indexPath.row].name)
    }
 

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhotoDetailsFromFavorites" {
            let destinationViewController = segue.destination as? PhotoDetailsViewController
            
            // Pass the savedFavorites name to PhotoDetailsVC (to display on top)
            destinationViewController?.chosenVisionResult = sender as! String
        }
    }
    
    // Delete function for the chosen favorite
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            savedFavorites.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // Actually delete this SavedFavorites in Userdefaults
            PersistanceManager.sharedInstance.deleteSavedFavorites(index: indexPath.row)
        }
    }
}
