//
//  PhotoDetailsViewController.swift
//  WhatsThat
//
//  Created by Yuan Cheng on 2017/12/7.
//  Copyright © 2017年 Yuan Cheng. All rights reserved.
//

import UIKit
import MBProgressHUD
import SafariServices

class PhotoDetailsViewController: UIViewController, SFSafariViewControllerDelegate {
    
    @IBOutlet weak var nameToDisplay: UILabel!
    @IBOutlet weak var descriptionDetail: UITextView!
    var chosenVisionResult: String!
    var imageToSave: UIImage!
    let wikipediaAPIManager = WikipediaAPIManager()
    
    // Will let it point to WikipediaResults model obj once wikiResultFound
    var wikipediaResult = WikipediaResult(pageId: "", extract: "")
    
    var wikiUrl: String = "http://en.wikipedia.org/?curid=" // Need to append pageId after "="

    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionDetail.isEditable = false
        
        nameToDisplay.text = chosenVisionResult.capitalized
        
        wikipediaAPIManager.delegate = self // Designate self as the receiver of the fetchWikiResult callbacks
        
        getWikipediaDescription()
    }
    
    
    func getWikipediaDescription() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        wikipediaAPIManager.fetchWikiResult(inputVisionResult: chosenVisionResult)
    }

    
    // When Wikipedia button is pressed, show wiki page in safari view...
    @IBAction func wikipediaButtonPressed(_ sender: Any) {
        let wikiWebUrl = URL(string: wikiUrl)
        let safariVC = SFSafariViewController(url: wikiWebUrl!)
        
        present(safariVC, animated: true, completion: nil)
    }
    
    
    
    // If Tweets button is pressed, pass the chosen vision result to SearchTimelineVC for tweets search...
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTimelineSegue" {
            let destinationViewController = segue.destination as? SearchTimelineViewController
            
            // Pass the chosen vision result to keyWord variable in SearchTimelineVC
            destinationViewController?.keyWord = chosenVisionResult
        }
    }
    
    
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        // Unwrap chosenVisionResult to get rid of the "optional" in the sharing text
        if let unwrappedChosenVisionResult = chosenVisionResult {
            let textToShare = "\(unwrappedChosenVisionResult.capitalized): \(wikipediaResult.extract)"
            let activityVC = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
            present(activityVC, animated: true, completion: nil)
            
            print(textToShare)
            
        } else {
            print("Error in PhotoDetails VC! chosenVisionResult happens to be nil")
        }
    }
    
    
    // Save the nameToDisplay along with the image to Favorites
    @IBAction func saveButtonPressed(_ sender: Any) {
        // Check if this result has been saved already
        let existingFavorites = PersistanceManager.sharedInstance.fetchPhotoDetailsResult()
        for existFav in existingFavorites {
            if existFav.name == chosenVisionResult {
                
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Oops!", message: "You've already saved this", preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                return
            }
        }
        
        let resultToSave = SavedFavorites(name: chosenVisionResult, image: imageToSave)
        PersistanceManager.sharedInstance.savePhotoDetailsResult(resultToSave)
        
        // Let user to know when save is done
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Done!", message: "Saved as favorites", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alertController.addAction(okayAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    
    
}
// -------------------------------------------- OUTSIDE OF THIS CLASS -----------------------------------------------

// Adhere to the WikiDelegate protocol
extension PhotoDetailsViewController: WikiDelegate {
    func wikiResultFound(wikipediaResult: WikipediaResult) {
        
        // Let global var wikipediaResult we defined point to the model obj that received Wikipedia result
        self.wikipediaResult = wikipediaResult
        
        // Get the wiki url ready for showing wiki page in safari view
        let pageId = wikipediaResult.pageId
        wikiUrl = wikiUrl + pageId
        
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            self.descriptionDetail.text = wikipediaResult.extract
        }
    }
    
    
    func wikiResultNotFound(reason: WikipediaAPIManager.FailureReason) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)

            let alertController = UIAlertController(title: "Problem Getting Info from Wikipedia", message: reason.rawValue, preferredStyle: .alert)
            
            switch reason {
            case .networkRequestFailed:
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: { (action) in
                    // What happens when user hit try button
                    self.getWikipediaDescription()
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                
                alertController.addAction(retryAction)
                alertController.addAction(cancelAction)
                
            case .badJSONResponse, .noData:
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alertController.addAction(okayAction)
            }
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
