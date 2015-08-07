//
//  ColorgyServicePageViewController.swift
//  ColorgyCourse
//
//  Created by David on 2015/7/27.
//  Copyright (c) 2015年 David. All rights reserved.
//

import UIKit

class ColorgyServicePageViewController: UIViewController, UIWebViewDelegate {

    var webview: UIWebView!
    var accessToken: String!
    
    var loginUrl: NSURL!
    
    var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // style of nav bar
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationItem.title = "活動牆"

        // Do any additional setup after loading the view.
        
        self.webview = UIWebView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
        self.view.addSubview(self.webview)

        self.webview.backgroundColor = UIColor.clearColor()
        self.webview.opaque = false
        
        self.webview.delegate = self
        
        // login session
        var ud = NSUserDefaults.standardUserDefaults()
        self.accessToken = ud.objectForKey("ColorgyAccessToken") as! String
        self.loginUrl = NSURL(string: "https://colorgy.io/sso_new_session?access_token=" + self.accessToken)
        var reqObj = NSURLRequest(URL: self.loginUrl!)
        println(reqObj.URL)
        self.webview.loadRequest(reqObj)
        
        //// add bar items
        var nextPage = UIBarButtonItem(image: UIImage(named: "forward"), style: UIBarButtonItemStyle.Done, target: self, action: "goForward")
        var previousPage = UIBarButtonItem(image: UIImage(named: "backward"), style: UIBarButtonItemStyle.Done, target: self, action: "goBack")
        self.navigationItem.setLeftBarButtonItems([previousPage, nextPage], animated: false)
        
        var reload = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "reloadPage")
        self.loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        var spinner = UIBarButtonItem(customView: self.loadingIndicator)
        
        self.navigationItem.setRightBarButtonItems([reload, spinner], animated: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if Release().mode {
            // Flurry
            Flurry.logEvent("User Viewing Service Page", timed: true)        // "User Using Time Table"
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if Release().mode {
            // Flurry
            Flurry.endTimedEvent("User Viewing Service Page", withParameters: nil)
        }
    }
    
    func reloadPage() {
        
        // login again
        var ud = NSUserDefaults.standardUserDefaults()
        self.accessToken = ud.objectForKey("ColorgyAccessToken") as! String
        self.loginUrl = NSURL(string: "https://colorgy.io/sso_new_session?access_token=" + self.accessToken)
        var reqObj = NSURLRequest(URL: self.loginUrl!)
        println(reqObj.URL)
        self.webview.loadRequest(reqObj)
        
        self.webview.reload()
    }
    
    func goForward() {
        if self.webview.canGoForward {
            self.webview.goForward()
        }
    }
    
    func goBack() {
        if self.webview.canGoBack {
            self.webview.goBack()
        }
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
    
    func webViewDidFinishLoad(webView: UIWebView) {
        println("web did finish load")
        println(webview.request?.URL)
        println("webview url \(webview.request?.URL)")
        println("self login url \(self.loginUrl!)")
        if webview.request?.URL! == NSURL(string: "https://colorgy.io/sso_new_session") {
            println("😇")
            var colorgy = NSURL(string: "https://colorgy.io/mobile-index")
            var req = NSURLRequest(URL: colorgy!)
            println(colorgy)
            self.webview.loadRequest(req)
        } else if webview.request?.URL! == NSURL(string: "https://colorgy.io")! {
            println("after!")
        }
        self.loadingIndicator.stopAnimating()
        self.loadingIndicator.hidden = true
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        println("web start load")
        self.loadingIndicator.startAnimating()
        self.loadingIndicator.hidden = false
    }

}