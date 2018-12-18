//
//  WikipediaResult.swift
//  WhatsThat
//
//  Created by Yuan Cheng on 2017/11/19.
//  Copyright © 2017年 Yuan Cheng. All rights reserved.
//

import Foundation

struct WikipediaResult: Decodable{
    
    let pageId: String
    let extract: String
   
    enum CodingKeys: String, CodingKey {
        case pageId //this matches above
        case extract //this matches above
    }
}
