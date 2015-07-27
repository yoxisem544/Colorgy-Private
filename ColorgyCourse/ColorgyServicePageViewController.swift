//
//  ColorgyServicePageViewController.swift
//  ColorgyCourse
//
//  Created by David on 2015/7/27.
//  Copyright (c) 2015年 David. All rights reserved.
//

import UIKit

class ColorgyServicePageViewController: UIViewController {

    var webview: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.webview = UIWebView(frame: CGRectMake(0, 64, self.view.frame.width, self.view.frame.height - 49))
        self.view.addSubview(self.webview)

        self.webview.backgroundColor = UIColor.clearColor()
        self.webview.opaque = false
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
