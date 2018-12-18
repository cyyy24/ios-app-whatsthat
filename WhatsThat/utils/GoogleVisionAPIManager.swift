//
//  GoogleVisionAPIManager.swift
//  WhatsThat
//
//  Created by Yuan Cheng on 2017/11/19.
//  Copyright © 2017年 Yuan Cheng. All rights reserved.
//

import Foundation
import UIKit

// Protocol communicates with View Controllers.
protocol GoogleVisionDelegate {
    func visionResultFound(googleVisionResults: [GoogleVisionResult])
    func visionResultNotFound(reason: GoogleVisionAPIManager.FailureReason)
}

// This Class is responsible for creating & sending request to GoogleVision API and handling the response, and converting the response JSON object to model object: "GoogleVisionResult.swift".
class GoogleVisionAPIManager {

    var delegate: GoogleVisionDelegate?
    
    enum FailureReason: String {
        case networkRequestFailed = "Your Google Vision request failed, please try again."
        case noData = "No Google Vision result data received"
        case badJSONResponse = "Bad Google Vision JSON response"
    }
    
    // This function makes call to the Google Vision API and handles the response.
    func createRequest(with imageBase64: String) {
        
        var googleAPIKey = "AIzaSyC_2xIpk_PZCLEMdmo7zpOx2HFHHLEafVU"
        var googleURL: URL {
            return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)")!
        }
        
        // Create our request URL
        var request = URLRequest(url: googleURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") // Let API know we are sending JSON
        
        // Build POST request body
        let jsonRequest = [
            "requests": [
                "image": [
                    "content": imageBase64
                ],
                "features": [
                    [
                        "type": "LABEL_DETECTION",
                        "maxResults": 20
                    ]
                ]
            ]
        ]
        
        // Convert request body to JSON
        guard let requestBody = try? JSONSerialization.data(withJSONObject: jsonRequest, options: []) else { return }
        
        request.httpBody = requestBody
        
        // Creat a URLSession
        let session = URLSession.shared
        
        session.dataTask(with: request) { (data, response, error) in
            
            // Check for valid response with 200 (success)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                self.delegate?.visionResultNotFound(reason: .networkRequestFailed)
                return
            }

            // Ensure data is non-nil
            guard let data = data else {
                self.delegate?.visionResultNotFound(reason: .noData)
                return
            }


            let decoder = JSONDecoder()
            let decodedRoot = try? decoder.decode(Root.self, from: data)

            // Ensure JSON structure matches our expectations and contains the result array
            guard let root = decodedRoot else {
                self.delegate?.visionResultNotFound(reason: .badJSONResponse)
                return
            }

            
            // Convert JSON response into our model object

            let labelAnnotations = root.responses[0].labelAnnotations

            var googleVisionResults = [GoogleVisionResult]()
            
            for labelAnnotation in labelAnnotations {
                let googleVisionResult = GoogleVisionResult(mid: labelAnnotation.mid, description: labelAnnotation.description, score: labelAnnotation.score)
                googleVisionResults.append(googleVisionResult)
            }

            self.delegate?.visionResultFound(googleVisionResults: googleVisionResults)
            
        }.resume()
        
    }
    
    
    // ------ BELOW ARE IMAGE PROCESSING ------
    
    func base64EncodeImage(_ image: UIImage) -> String {
        var imageData = UIImagePNGRepresentation(image)
        
        // Resize the image if it exceeds the 2MB API limit
        if (imageData?.count > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imageData = resizeImage(newSize, image: image)
        }
        
        return imageData!.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        return resizedImage!
    }
}
// -------------------------------------------- OUTSIDE OF THIS CLASS -----------------------------------------------

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}
