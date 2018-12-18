//
//  SearchTimelineViewController.swift
//  WhatsThat
//
//  Created by Yuan Cheng on 2017/12/9.
//  Copyright © 2017年 Yuan Cheng. All rights reserved.
//

import UIKit
import TwitterKit

class SearchTimelineViewController: TWTRTimelineViewController {
    
    var keyWord = "twitter" // Will change once the chosen vision result is passed here
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let twitterClient = TWTRAPIClient()
        self.dataSource = TWTRSearchTimelineDataSource(searchQuery: keyWord, apiClient: twitterClient)
    }
}
