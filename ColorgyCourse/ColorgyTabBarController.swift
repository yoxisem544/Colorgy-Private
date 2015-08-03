//
//  ColorgyTabBarController.swift
//  ColorgyCourse
//
//  Created by David on 2015/7/19.
//  Copyright (c) 2015年 David. All rights reserved.
//

import UIKit

class ColorgyTabBarController: UITabBarController {

    var colorgyOrange: UIColor = UIColor(red: 246/255.0, green: 150/255.0, blue: 114/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        UITabBar.appearance().tintColor = self.colorgyOrange
        self.tabBar.tintColor = self.colorgyOrange
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
