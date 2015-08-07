//
//  ColorgyUserPriofileViewController.swift
//  ColorgyCourse
//
//  Created by David on 2015/8/6.
//  Copyright (c) 2015年 David. All rights reserved.
//

import UIKit
import CoreData

class ColorgyUserPriofileViewController: UIViewController {
    
    var userProfilePhotoImageView: UIImageView!
    var userNameLabel: UILabel!
    
    var timetableBackgroundColor: UIColor = UIColor(red: 239/255.0, green: 238/255.0, blue: 238/255.0, alpha: 1)
    var colorgyDimOrange: UIColor = UIColor(red: 228/255.0, green: 133/255.0, blue: 111/255.0, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // style of nav bar
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationItem.title = "個人頁面"

        // Do any additional setup after loading the view.
        self.userProfilePhotoImageView = self.userProfilePhotoImageViewMake()
        self.userNameLabel = self.userNameLabelMake()
        self.view.addSubview(self.userProfilePhotoImageView)
        self.view.addSubview(self.userNameLabel)
        self.view.addSubview(self.logoutButtonMake())
        self.view.backgroundColor = self.timetableBackgroundColor
    }
    
    func userNameLabelMake() -> UILabel {
        
        var name = UILabel(frame: CGRectMake(0, 0, self.view.frame.width, 23))
        name.textAlignment = NSTextAlignment.Center
        name.textColor = UIColor.blackColor()
        name.font = UIFont(name: "STHeitiTC-Medium", size: 23)
        
        var ud = NSUserDefaults.standardUserDefaults()
        name.text = ud.objectForKey("userName") as? String
        
        name.center.x = self.view.center.x
        name.frame.origin.y = self.userProfilePhotoImageView.frame.origin.y + self.userProfilePhotoImageView.frame.height + 30
        
        return name
    }
    
    func userProfilePhotoImageViewMake() -> UIImageView {
        
        var imageView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width * 0.4, self.view.frame.width * 0.4))
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.frame.width / 2
        var ud = NSUserDefaults.standardUserDefaults()
        var profilePhoto = UIImage(data: ud.objectForKey("bigFBProfilePhoto") as! NSData)
        imageView.image = profilePhoto!
        
        imageView.layer.borderColor = UIColor.whiteColor().CGColor
        imageView.layer.borderWidth = 5
        
        imageView.center.x = self.view.center.x
        imageView.frame.origin.y = 64 + self.view.frame.height * 0.1
        
        return imageView
    }
    
    func logoutButtonMake() -> UIButton {
        
//        var deleteImage = UIImageView(image: UIImage(named: "deleteCourse"))
//        var deleteButton = UIButton(frame: deleteImage.frame)
//        deleteButton.setImage(deleteImage.image, forState: UIControlState.Normal)
//        dimBackground.addSubview(deleteButton)
        
        var logoutButton = UIButton(frame: CGRectMake(0, 100, 32*2, 32))
        logoutButton.layer.cornerRadius = 5
        logoutButton.layer.borderWidth = 1
        logoutButton.layer.borderColor = UIColor.redColor().CGColor
        logoutButton.backgroundColor = UIColor.redColor()
        
        logoutButton.addTarget(self, action: "logout", forControlEvents: UIControlEvents.TouchUpInside)
        
        var title = UILabel(frame: CGRectMake(0, 0, logoutButton.bounds.width, logoutButton.bounds.height))
        logoutButton.addSubview(title)
        title.text = "登出"
        title.textColor = UIColor.whiteColor()
        title.textAlignment = NSTextAlignment.Center
        title.font = UIFont(name: "STHeitiTC-Medium", size: 23)
        title.center.y = logoutButton.bounds.size.height / 2
        
        logoutButton.center.x = self.view.center.x
        logoutButton.frame.origin.y = self.view.frame.height * 0.8
        
        return logoutButton
    }
    
    func logout() {
        var alert = UIAlertController(title: "登出", message: "確定登出嗎？\n登出之後所有資料將會被移除！", preferredStyle: UIAlertControllerStyle.Alert)
        var ok = UIAlertAction(title: "登出", style: UIAlertActionStyle.Default, handler: {(alert:UIAlertAction!) -> Void in
            
            var ud = NSUserDefaults.standardUserDefaults()
            ud.setObject(nil, forKey: "isLogin")
            ud.setObject(nil, forKey: "loginTpye")
            ud.setObject(nil, forKey: "smallFBProfilePhoto")
            ud.setObject(nil, forKey: "bigFBProfilePhoto")
            ud.setObject(nil, forKey: "ColorgyAccessToken")
            ud.setObject(nil, forKey: "ColorgyCreatedTime")
            ud.setObject(nil, forKey: "ColorgyExpireTime")
            ud.setObject(nil, forKey: "ColorgyRefreshToken")
            ud.setObject(nil, forKey: "ColorgyTokenType")
            ud.setObject(nil, forKey: "courseDataFromServer")
            ud.setObject(nil, forKey: "userName")
            ud.setObject(nil, forKey: "userSchool")
            ud.setObject(nil, forKey: "hasLoginOnce")
            ud.setObject(nil, forKey: "userSelectedSchool")
            //
            ud.setObject(nil, forKey: "isGuideShown")
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
    
    // MARK: - Animation
    func logoutAnimation() {
        var view = UIView(frame: CGRectMake(0, 0, 500, 500))
        view.layer.cornerRadius = 250
        view.backgroundColor = self.colorgyDimOrange
        view.transform = CGAffineTransformMakeScale(0, 0)
        
        // position of view
        var x = self.tabBarController?.view.center.x
        view.center.x = x!
        view.center.y = self.view.center.y
        
        // apply this to view, will be animated later.
        self.tabBarController?.view.addSubview(view)
        
        UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            view.transform = CGAffineTransformMakeScale(10, 10)
            }, completion: nil)
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
