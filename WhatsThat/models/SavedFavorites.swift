//
//  SavedFavorites.swift
//  WhatsThat
//
//  Created by Yuan Cheng on 2017/12/10.
//  Copyright © 2017年 Yuan Cheng. All rights reserved.
//

import Foundation

// This class is used for storing the result shown in PhotoDetailsVC. It stores the name that displayed there and
// the corresponding image into this model object.
class SavedFavorites: NSObject {
    let name: String
    let image: UIImage
    
    let nameKey = "name"
    let imageKey = "image"
    
    
    init(name: String, image: UIImage) {
        self.name = name
        self.image = image
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: nameKey) as! String
        image = aDecoder.decodeObject(forKey: imageKey) as! UIImage
    }
}

extension SavedFavorites: NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: nameKey)
        aCoder.encode(image, forKey: imageKey)
    }
}
