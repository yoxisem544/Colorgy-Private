//
//  ColorgyNavigationController.swift
//  ColorgyCourse
//
//  Created by David on 2015/5/4.
//  Copyright (c) 2015年 David. All rights reserved.
//

import UIKit

class ColorgyNavigationController: UINavigationController {

    var colorgyDarkGray: UIColor = UIColor(red: 74/255.0, green: 74/255.0, blue: 74/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.barTintColor = self.colorgyDarkGray
        self.navigationBar.tintColor = UIColor.whiteColor()
    }
}
