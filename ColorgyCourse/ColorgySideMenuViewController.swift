//
//  ColorgySideMenuViewController.swift
//  
//
//  Created by David on 2015/5/5.
//
//

import UIKit
import CoreData

class ColorgySideMenuViewController: UIViewController {
    
    var colorgyDarkGray: UIColor = UIColor(red: 59/255.0, green: 58/255.0, blue: 59/255.0, alpha: 1)
    var colorgyDimOrange: UIColor = UIColor(red: 228/255.0, green: 133/255.0, blue: 111/255.0, alpha: 1)
    
    var scrollview: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        println("load")
        
        // wrap in scroll view
        self.scrollview = UIScrollView(frame: self.view.frame)
        self.scrollview.contentSize = CGSizeMake(self.view.frame.width, self.view.frame.height*2)
        self.scrollview.backgroundColor = self.colorgyDarkGray
        
        self.setupProfilePhoto()
        self.setupWave()
        
        self.setupButtonWith("選課", action: "pushSegueToselectCourse:", order: 1)
        self.setupButtonWith("課表", action: "pushSegueToTimetable:", order: 2)
        self.setupButtonWith("關於我們", action: "pushSegueToProfile:", order: 3)
        
        // setup logout btn
        self.setupLogoutButton()
        
        self.view.addSubview(self.scrollview)
    }
    
    func setupLogoutButton() {
        
        var logoutImg = UIImage(named: "fb_logout")
        var logout = UIButton(frame: CGRectMake(30, 500, 50, 50))
        
        logout.setImage(logoutImg, forState: UIControlState.Normal)
        logout.addTarget(self, action: "logout", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.scrollview.addSubview(logout)
    }
    
    func logout() {

        var alert = UIAlertController(title: "登出", message: "確定登出嗎？\n登出之後所有資料將會被移除！", preferredStyle: UIAlertControllerStyle.Alert)
        var ok = UIAlertAction(title: "登出", style: UIAlertActionStyle.Default, handler: {(alert:UIAlertAction!) -> Void in
            
                var ud = NSUserDefaults.standardUserDefaults()
                ud.setObject(nil, forKey: "isLogin")
                ud.setObject(nil, forKey: "courseFromServer")
                ud.synchronize()
            
                self.deleteDataFromDatabase()
            
                FBSession.activeSession().closeAndClearTokenInformation()
            
                self.logoutAnimation()
            
                var delay = dispatch_time(DISPATCH_TIME_NOW, Int64( 1 * Double(NSEC_PER_SEC)))
                dispatch_after(delay, dispatch_get_main_queue()) {
                    var storyboard = UIStoryboard(name: "Main", bundle: nil)
                    var vc = storyboard.instantiateViewControllerWithIdentifier("colorgyFBLoginView") as! ColorgyFBLoginViewController
                    self.presentViewController(vc, animated: true, completion: nil)
                }
            })
        var cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    // MARK: - db operation
    func deleteDataFromDatabase() {
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext {
            let fetchRequest = NSFetchRequest(entityName: "Course")
            var e: NSError?
            var course: [Course] = managedObjectContext.executeFetchRequest(fetchRequest, error: &e) as! [Course]
            if e != nil {
                println("something error")
            } else {
                println("ok count: \(course.count)")
            }
            for c in course {
                managedObjectContext.deleteObject(c)
            }
            
            managedObjectContext.save(&e)
            if e != nil {
                println("error \(e)")
            }
        }
    }
    
    // MARK: - setup
    
    func setupProfilePhoto() {
        
        var profile = UIImageView(frame: CGRectMake(39, 60, 62, 62))
        profile.backgroundColor = UIColor.grayColor()
        profile.layer.cornerRadius = 31
        profile.layer.borderWidth = 3
        profile.layer.borderColor = UIColor.whiteColor().CGColor
        
        var ud = NSUserDefaults.standardUserDefaults()
        var data = ud.objectForKey("smallFBProfilePhoto") as! NSData
        profile.image = UIImage(data: data)
        profile.layer.masksToBounds = true
        
        self.scrollview.addSubview(profile)
    }
    
    func setupWave() {
        
        var waveImg = UIImage(named: "wave")
        var w = waveImg?.size.width
        var h = waveImg?.size.height
        println(h)
        
        var wave = UIImageView(frame: CGRectMake(0, 150, w!, h!))
        wave.image = waveImg
        
        self.scrollview.addSubview(wave)
    }
    
    func setupButtonWith(title: String, action: String, order: Int) {
        
        var offset = CGFloat(150 + 43) + CGFloat(order - 1) * 75 + 0.5 * CGFloat(order)
        
        var button = UIButton(frame: CGRectMake(0, offset, 140, 75))
        var titleLabel = UILabel(frame: CGRectMake(0, 33, 140, 30))
        
        titleLabel.text = title
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.textColor = UIColor.whiteColor()
        
        var pinImg = UIImage(named: "Pin")
        var w = pinImg?.size.width
        var h = pinImg?.size.height
        var pin = UIImageView(frame: CGRectMake(0, 18, w!, h!))
        pin.center.x = button.center.x
        pin.image = pinImg
        
        button.backgroundColor = self.colorgyDimOrange
        button.addSubview(titleLabel)
        button.addSubview(pin)
        
        // hook push segue
        button.addTarget(self, action: NSSelectorFromString(action), forControlEvents: UIControlEvents.TouchUpInside)
        button.addTarget(self, action: "buttonTouchDragEnter:", forControlEvents: UIControlEvents.TouchDragEnter)
        button.addTarget(self, action: "buttonTouchDragExit:", forControlEvents: UIControlEvents.TouchDragExit)
        button.addTarget(self, action: "buttonTouchDown:", forControlEvents: UIControlEvents.TouchDown)
        
        // extend view
        var extendView = UIView(frame: CGRectMake(140, offset, 140, 75))
        extendView.backgroundColor = self.colorgyDimOrange
        
        
        self.scrollview.addSubview(extendView)
        self.scrollview.addSubview(button)
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
    
    
    // MARK: - button behavior
    func buttonTouchDown(sender: UIButton) {
        sender.alpha = 0.77
    }
    
    func buttonTouchDragEnter(sender: UIButton) {
        sender.alpha = 0.77
    }
    
    func buttonTouchDragExit(sender: UIButton) {
        sender.alpha = 1.0
    }
    
    // MARK: - push segue region
    func pushSegueToTimetable(sender: UIButton) {
        sender.alpha = 1.0
        performSegueWithIdentifier("timetable", sender: self)
    }
    
    func pushSegueToselectCourse(sender: UIButton) {
        sender.alpha = 1.0
        performSegueWithIdentifier("selectCourse", sender: self)
    }
    
    func pushSegueToProfile(sender: UIButton) {
        sender.alpha = 1.0
        performSegueWithIdentifier("profile", sender: self)
    }
    
    // MARK: - Animation
    func logoutAnimation() {
        var view = UIView(frame: CGRectMake(0, 0, 500, 500))
        view.layer.cornerRadius = 250
        view.backgroundColor = self.colorgyDimOrange
        view.transform = CGAffineTransformMakeScale(0, 0)
        
        // position of view
        view.center.x = self.revealViewController().view.center.x
        view.center.y = self.view.center.y
        
//        self.view.addSubview(view)
        self.revealViewController().view.addSubview(view)
        
        UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                view.transform = CGAffineTransformMakeScale(10, 10)
            }, completion: nil)
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