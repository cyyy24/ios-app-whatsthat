//
//  PhotoIdentificationViewController.swift
//  WhatsThat
//
//  Created by Yuan Cheng on 2017/11/26.
//  Copyright © 2017年 Yuan Cheng. All rights reserved.
//

import UIKit
import MBProgressHUD

class PhotoIdentificationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var imageToDisplay: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var chosenImage: UIImage!
    var googleVisionResults = [GoogleVisionResult]()
    let googleVisionAPIManager = GoogleVisionAPIManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageToDisplay.image = chosenImage
        
        // Designate self as the receiver of the createRequest callbacks
        googleVisionAPIManager.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getImageResult()
    }
    
    func getImageResult() {
        MBProgressHUD.showAdded(to: self.view, animated: true)

        let binaryImageData = googleVisionAPIManager.base64EncodeImage(chosenImage) //encode image for request
        googleVisionAPIManager.createRequest(with: binaryImageData)
    }
    
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return googleVisionResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "googleVisionResultCell", for: indexPath)
        
        // Configure the cell...
        let googleVisionResult = googleVisionResults[indexPath.row]
        cell.textLabel?.text = googleVisionResult.description.capitalized
        cell.detailTextLabel?.text = "\(Int(round(googleVisionResult.score * 100)))% match"
        cell.detailTextLabel?.textColor = .gray
        
        return cell
    }
    
    // Once the user click one of the cell...
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "photoDetailsSegue", sender: googleVisionResults[indexPath.row].description)
    }
    
    
    // Get ready for the PhotoDetails VC and pass the chosen result
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoDetailsSegue" {
            let destinationViewController = segue.destination as? PhotoDetailsViewController
            
            // Pass the chosen vision result to PhotoDetailsVC (to display on top)
            destinationViewController?.chosenVisionResult = sender as! String
            
            // Pass the image to the next screen
            destinationViewController?.imageToSave = chosenImage
        }
    }
}
// -------------------------------------------- OUTSIDE OF THIS CLASS -----------------------------------------------

// Adhere to the GoogleVisionDelegate protocol
extension PhotoIdentificationViewController: GoogleVisionDelegate {
    func visionResultFound(googleVisionResults: [GoogleVisionResult]) {
        self.googleVisionResults = googleVisionResults
        
        // Update tableview data on the main (UI) thread
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            self.tableView.reloadData()
        }
    }
    
    
    func visionResultNotFound(reason: GoogleVisionAPIManager.FailureReason) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)

            let alertController = UIAlertController(title: "Problem fetching google vision result", message: reason.rawValue, preferredStyle: .alert)
            
            switch reason {
            case .networkRequestFailed:
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: { (action) in
                    // What happens when user hits Retry button
                    self.getImageResult()
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
