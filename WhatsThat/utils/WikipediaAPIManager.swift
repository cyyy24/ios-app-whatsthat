//
//  WikipediaAPIManager.swift
//  WhatsThat
//
//  Created by Yuan Cheng on 2017/11/19.
//  Copyright © 2017年 Yuan Cheng. All rights reserved.
//

import Foundation

// Protocol communicates with View Controllers.
protocol WikiDelegate {
    func wikiResultFound(wikipediaResult: WikipediaResult)
    func wikiResultNotFound(reason: WikipediaAPIManager.FailureReason)
}

/*
 * This class is responsible for creating & sending request to Wikipedia API and handling the response, and
 * converting the response JSON object to model object: "WikipediaResult.swift".
 */
class WikipediaAPIManager {
    
    var delegate: WikiDelegate?
    
    enum FailureReason: String {
        case networkRequestFailed = "Your wiki request failed, please try again."
        case noData = "No wiki result data received"
        case badJSONResponse = "Bad wiki JSON response"
    }
    
    // Display this in case the extract is empty.
    enum WikiExtractStatus: String {
        case extractIsEmpty = "No description for this specific word. Please check Wikipedia's redirected page"
    }
    
    
    // This function sends a GET request to Wikipedia API and parse & convert JSON response into model object.
    func fetchWikiResult(inputVisionResult: String) {
        
        var urlComponents = URLComponents(string: "https://en.wikipedia.org/w/api.php")!
        
        urlComponents.queryItems = [
            URLQueryItem(name: "action", value: "query"),
            URLQueryItem(name: "titles", value: inputVisionResult),
            URLQueryItem(name: "prop", value: "extracts"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "exintro", value: "true"),
            URLQueryItem(name: "explaintext", value: "true"),
            URLQueryItem(name: "indexpageids", value: "true")
        ]
        
        let url = urlComponents.url!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Check for valid response with 200 (success)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                self.delegate?.wikiResultNotFound(reason: .networkRequestFailed)

                return
            }

            guard let data = data, let wikiJsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] ?? [String:Any]() else {
                self.delegate?.wikiResultNotFound(reason: .noData)

                return
            }
            
            
            // ------ BELOW ARE JSON RESPONSE PARSING ------
            
            // Get query JSON object & pageids.
            guard let queryJsonObject = wikiJsonObject["query"] as? [String:Any], let pageidsArray = queryJsonObject["pageids"] as? [String]  else {
                self.delegate?.wikiResultNotFound(reason: .badJSONResponse)
                print(FailureReason.badJSONResponse.rawValue)

                return
            }
            
            // Get pages JSON object & pages JSON object with pageids.
            guard let pagesJsonObject = queryJsonObject["pages"] as? [String:Any], let pageidJsonObject = pagesJsonObject[pageidsArray[0]] as? [String:Any] else {
                self.delegate?.wikiResultNotFound(reason: .badJSONResponse)
                print(FailureReason.badJSONResponse.rawValue)

                return
            }
            
            // Get the extract in pageidJsonObject.
            guard let extractString = pageidJsonObject["extract"] as? String else {
                self.delegate?.wikiResultNotFound(reason: .badJSONResponse)
                print(FailureReason.badJSONResponse.rawValue)
                
                return
            }

            
            // --- BELOW ARE PROCESS OF PUTTING THE PARSING RESULT INTO OUR MODEL OBJ (WikipediaResult) ---
            
            var extract = extractString
            let pageId = pageidsArray[0]
            
            // If there is no wiki description for the chosen google vision result
            if extract.isEmpty {
                extract = WikiExtractStatus.extractIsEmpty.rawValue
            }
            
            let wikipediaResult = WikipediaResult(pageId: pageId, extract: extract)
            
            self.delegate?.wikiResultFound(wikipediaResult: wikipediaResult)
        }
        
        task.resume()
    }
    
}
// -------------------------------------------- OUTSIDE OF THIS CLASS -----------------------------------------------
