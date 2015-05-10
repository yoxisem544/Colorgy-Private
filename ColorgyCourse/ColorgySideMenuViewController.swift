//
//  ColorgySideMenuViewController.swift
//  
//
//  Created by David on 2015/5/5.
//
//

import UIKit

class ColorgySideMenuViewController: UIViewController {
    
    var colorgyDarkGray: UIColor = UIColor(red: 59/255.0, green: 58/255.0, blue: 59/255.0, alpha: 1)
    var colorgyDimOrange: UIColor = UIColor(red: 228/255.0, green: 133/255.0, blue: 111/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        println("load")
        
        
    }

    @IBAction func yy(sender: AnyObject) {
        performSegueWithIdentifier("fff", sender: self)
    }

    @IBAction func hi(sender: AnyObject) {
        performSegueWithIdentifier("p", sender: self)
    }
    @IBAction func ss(sender: AnyObject) {
        performSegueWithIdentifier("s", sender: self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logout(sender: AnyObject) {
        var ud = NSUserDefaults.standardUserDefaults()
        ud.setObject(nil, forKey: "isLogin")
        FBSession.activeSession().closeAndClearTokenInformation()
        ud.synchronize()
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
