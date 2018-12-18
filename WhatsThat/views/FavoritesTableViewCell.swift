//
//  FavoritesTableViewCell.swift
//  WhatsThat
//
//  Created by Yuan Cheng on 2017/12/10.
//  Copyright © 2017年 Yuan Cheng. All rights reserved.
//

import UIKit

class FavoritesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var savedResultImageView: UIImageView!
    @IBOutlet weak var savedResultNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
