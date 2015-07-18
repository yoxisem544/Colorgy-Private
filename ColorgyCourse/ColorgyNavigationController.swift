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
    var colorgyLightOrange = UIColor(red: 248/255.0, green: 150/255.0, blue: 128/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.barTintColor = self.colorgyLightOrange
        self.navigationBar.tintColor = UIColor.whiteColor()
        
        self.navigationBar.layer.shadowColor = UIColor.blackColor().CGColor
        self.navigationBar.layer.shadowOpacity = 0.5
        self.navigationBar.layer.shadowPath = UIBezierPath(rect: self.navigationBar.bounds).CGPath
        self.navigationBar.layer.shadowOffset = CGSizeMake(0, 2)
    }
}
