//
//  GoogleVisionResult.swift
//  WhatsThat
//
//  Created by Yuan Cheng on 2017/11/19.
//  Copyright © 2017年 Yuan Cheng. All rights reserved.
//

import Foundation


struct GoogleVisionResult: Decodable {
    let mid : String
    let description : String
    let score : Double
    
    enum CodingKeys: String, CodingKey {
        case mid
        case description
        case score
    }
    
}


// Struct for google vision response
// Structs below were generated using http://danieltmbr.github.io/JsonCodeGenerator/
struct Root: Codable {
    
    let responses: [Responses]
    
}

struct Responses: Codable {
    
    let labelAnnotations: [LabelAnnotations]
    
}

struct LabelAnnotations: Codable {
    
    let mid: String
    let description: String
    let score: Double
    
}
