//
//  FBTestViewController.swift
//  ColorgyCourse
//
//  Created by David on 2015/5/9.
//  Copyright (c) 2015年 David. All rights reserved.
//

import UIKit

class FBTestViewController: UIViewController {

    var lgview = FBLoginView()
    
    @IBOutlet weak var btn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.lgview.center = self.view.center
        self.view.addSubview(self.lgview)
        
        FBSession.activeSession().closeAndClearTokenInformation()
    }

    @IBAction func pre(sender: AnyObject) {
        if FBSession.activeSession().isOpen {
            println("session open")
            println(FBSession.activeSession().accessTokenData)
        } else {
            println("close")
            // request user email permission...
            FBSession.openActiveSessionWithReadPermissions(["email"], allowLoginUI: true, completionHandler: { (session:FBSession!, state:FBSessionState, error: NSError!) in
                // completion handler.
                if error != nil {
                    println(error)
                }
                println("open session with permisson email!")
                
            } )
                
            
            
        }
    }
    
//    var completehandler: FBSessionStateHandler = {
//        session, status, error in
//        
//        if (error != nil) {
//            nil
//        }
//    }
    @IBOutlet weak var btnpressss: UIButton!
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
