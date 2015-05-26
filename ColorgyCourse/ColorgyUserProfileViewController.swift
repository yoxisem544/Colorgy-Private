//
//  ColorgyUserProfileViewController.swift
//  ColorgyCourse
//
//  Created by David on 2015/5/10.
//  Copyright (c) 2015年 David. All rights reserved.
//

import UIKit
import CoreData

class ColorgyUserProfileViewController: UIViewController {
    
    var colorgyLightOrange: UIColor = UIColor(red: 228/255.0, green: 133/255.0, blue: 111/255.0, alpha: 1)
    var colorgyDarkGray: UIColor = UIColor(red: 59/255.0, green: 58/255.0, blue: 59/255.0, alpha: 1)
    var colorgyDimYellow: UIColor = UIColor(red: 245/255.0, green: 166/255.0, blue: 35/255.0, alpha: 1)
    var colorgyLightYellow: UIColor = UIColor(red: 244/255.0, green: 188/255.0, blue: 94/255.0, alpha: 1)
    
    var backgroundImage: UIImageView!
    var profilePhotoImageView: UIImageView!
    var userInformationCard: UIView!
    var outerFrame: UIView!
    
    @IBOutlet weak var revealMenuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //reveal region
        if self.revealViewController() != nil {
            revealMenuButton.target = self.revealViewController()
            revealMenuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        self.revealViewController().rearViewRevealWidth = 140
        //
        
        // style of nav bar
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationItem.title = "個人資料"
        
        // setup background
        self.setupBackgorund()
        
        // Do any additional setup after loading the view.
        var ud = NSUserDefaults.standardUserDefaults()
        if ud.objectForKey("loginType")! as! String == "fb" {
            var data = ud.objectForKey("bigFBProfilePhoto") as! NSData
            var name = ud.objectForKey("userName") as! String
            var school = ud.objectForKey("userSchool") as! String
            self.setupUserInformationWithName(name, school: school)
            self.setupUserPorfilePhotoWithImage(UIImage(data: data)!)
            
        } else if ud.objectForKey("loginType")! as! String == "account" {
            var name = ud.objectForKey("userName") as! String
            var school = ud.objectForKey("userSchool") as! String
            self.setupUserInformationWithName(name, school: school)
            self.setupUserPorfilePhotoWithImage(UIImage(named: "cordova_big.png")!)
        }
        self.setupProfilePhotoOuterFrame()
//        self.fetchCourseDataFromServer()
        
        // bar frame change nitification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "barChange", name: UIApplicationDidChangeStatusBarFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "youRBack", name: UIApplicationDidBecomeActiveNotification, object: nil)
        //testing
//        self.updateCourseFromServer()
    }
    
    func barChange() {
        viewDidLoad()
    }
    
    func youRBack() {
        // every time user come back to app, start animating.
        // cause this is always the very first scene, so just animate views here.
        // but if this view is not your first view, always animate once in viewdidload.
        println("user p 回來")
        self.animateOuterFrame()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.animateBackground()
    }
    
    // MARK: - fetch data from server
    func fetchCourseDataFromServer() {
        
        var ud = NSUserDefaults.standardUserDefaults()
        var front_url = "https://colorgy.io:443/api/"
        var middle_url = "/courses.json?per_page=5000&&&&&access_token="
        let school = ud.objectForKey("userSchool") as! String
        var token = ud.objectForKey("ColorgyAccessToken") as! String
        let url = front_url + school.lowercaseString + middle_url + token
        
        println(url)
        
        let afManager = AFHTTPSessionManager(baseURL: NSURL(string: url))
        
        afManager.requestSerializer = AFJSONRequestSerializer()
        afManager.responseSerializer = AFJSONResponseSerializer()
        
        afManager.GET(url, parameters: nil, success: { (task:NSURLSessionDataTask!, responseObject: AnyObject!) in
            var resArr = responseObject as! NSArray
            var parsedResData = NSMutableArray()
            
            var arcData = self.archive(resArr)
            
            var ud = NSUserDefaults.standardUserDefaults()
            ud.setObject(arcData, forKey: "courseDataFromServer")
            ud.synchronize()
            println("get course from server")
            }, failure: { (task: NSURLSessionDataTask!, error: NSError!) in
                println("error post")
        })
    }
    
    func updateCourseFromServer() {
        
        let afManager = AFHTTPSessionManager(baseURL: NSURL(string: ""))
        
        var ud = NSUserDefaults.standardUserDefaults()
        var front_url = "https://colorgy.io:443/api/"
        var middle_url = "/courses.json?per_page=5000&&&&&access_token="
        let school = ud.objectForKey("userSchool") as! String
        var token = ud.objectForKey("ColorgyAccessToken") as! String
        let url = front_url + school.lowercaseString + middle_url + token
        
        afManager.requestSerializer = AFJSONRequestSerializer()
        afManager.responseSerializer = AFJSONResponseSerializer()
        
        afManager.GET(url, parameters: nil, success: { (task:NSURLSessionDataTask!, responseObject: AnyObject!) in
            println(responseObject.count)
            // if get update course, archive it and replace it.
            let archiveData = self.archive(responseObject)
            ud.setObject(archiveData, forKey: "courseDataFromServer")
            ud.synchronize()
            // check db and new course data, update old db data
            var vc = ColorgyViewAndAddCourseTableViewController()
            var coursesInDB = vc.getDataFromDatabase()
            // update only if there is data in db.
            var userCourses = NSMutableArray()
            // collect user course uuid
            if coursesInDB != nil {
                for course: Course in coursesInDB! {
                    userCourses.addObject(course.uuid)
                }
            }
            // clear db
            var sidevc = ColorgySideMenuViewController()
            sidevc.deleteDataFromDatabase()
            // get courses back using new data.
            if userCourses.count != 0 {
                // this vc help us to store data to db
                let vc = ColorgyViewAndAddCourseTableViewController()
                // loop through new course data
                for newCourse in responseObject as! NSArray {
                    // check if any course match.
                    for uc in userCourses {
                        if newCourse["code"] as! String == uc as! String {
                            println("有！ \(uc)")
                            // get out all the data, easy to use.
                            let name = newCourse["name"] as! String
                            let lecturer = newCourse["lecturer"] as! String
                            let credits = Int32(newCourse["credits"] as! Int)
                            let uuid = newCourse["code"] as! String
                            // year, term, id, type
                            let year = Int32(newCourse["year"] as! Int)
                            let term = Int32(newCourse["term"] as! Int)
                            let id = Int32(newCourse["id"] as! Int)
                            let type = newCourse["_type"] as! String
                            // sessions.
                            var sessions = NSMutableArray()
                            for i in 1...9 {
                                let day = newCourse["day_" + "\(i)"]
                                let session = newCourse["period_" + "\(i)"]
                                let location = newCourse["location_" + "\(i)"]
                                
                                sessions.addObject(["\(day!!)", "\(session!!)", "\(location!!)"])
                            }
                            // store it
                            vc.storeDataToDatabase(name, lecturer: lecturer, credits: credits, uuid: uuid, sessions: sessions, year: year, term: term, id: id, type: type)
                            // if match, remove from lists and break.
                            userCourses.removeObject(uc)
                            break
                        }
                    }
                }
            }
            println(userCourses)
            }, failure: { (task: NSURLSessionDataTask!, error: NSError!) in
                println("error post")
            })
    }
    
    // MARK: - compress data
    
    func archive(array: AnyObject) -> NSData {
        let a = array as! NSArray
        return NSKeyedArchiver.archivedDataWithRootObject(array)
    }
    
    func unarchive(data: NSData) -> NSArray {
        return NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSArray
    }
    
    //MARK: - setup
    func setupProfilePhotoOuterFrame() {
        var view = UIImageView(image: UIImage(named: "profileOuterFrame"))
        self.outerFrame = view
        view.center = CGPointMake(self.profilePhotoImageView.center.x + 33/2, self.profilePhotoImageView.center.y - 57/2)
        
        self.view.addSubview(view)
        self.view.sendSubviewToBack(view)
        self.view.sendSubviewToBack(self.backgroundImage)
        
        self.animateOuterFrame()
    }
    
    func animateOuterFrame() {
        
        UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.Autoreverse | UIViewAnimationOptions.Repeat, animations: {
                self.outerFrame.transform = CGAffineTransformMakeScale(0.95, 0.95)
            }, completion: { (isFinished: Bool) in
                self.outerFrame.transform = CGAffineTransformMakeScale(1, 1)
            })
    }
    
    func setupUserPorfilePhotoWithImage(image: UIImage) {
        // photo
        self.profilePhotoImageView = UIImageView(frame: CGRectMake(0, 0, 150, 150))
        self.profilePhotoImageView.layer.cornerRadius = self.profilePhotoImageView.frame.width / 2
        self.profilePhotoImageView.layer.borderColor = UIColor.whiteColor().CGColor
        self.profilePhotoImageView.layer.borderWidth = 9
        self.profilePhotoImageView.image = image
        self.profilePhotoImageView.center = self.userInformationCard.center
        self.profilePhotoImageView.center.y = self.userInformationCard.frame.origin.y - 5
        self.profilePhotoImageView.layer.masksToBounds = true
        self.view.addSubview(self.profilePhotoImageView)
    }
    
    func setupUserInformationWithName(name: String, school: String) {
        
        var view = UIView(frame: CGRectMake(0, 0, 287, 222))
        var shadowView = UIView(frame: CGRectMake(0, 0, 287, 222))
        self.userInformationCard = shadowView
        view.backgroundColor = UIColor.whiteColor()
        view.layer.cornerRadius = 3
        view.layer.masksToBounds = true
        
        // user name text
        var nameLabel = UILabel(frame: CGRectMake(0, 0, 287, 30))
        nameLabel.textAlignment = NSTextAlignment.Center
        nameLabel.textColor = self.colorgyLightOrange
        nameLabel.center = view.center
        nameLabel.text = name
        nameLabel.font = UIFont(name: "STHeitiTC-Medium", size: 30)
        view.addSubview(nameLabel)
        println(view.subviews)
        
        // school text.....
        var schoolTitleView = UIView(frame: CGRectMake(0, 0, 98, 64))
        var schoolTitleLable = UILabel(frame: CGRectMake(0, 0, schoolTitleView.frame.width, 14))
        schoolTitleLable.center = schoolTitleView.center
        schoolTitleView.addSubview(schoolTitleLable)
        schoolTitleView.backgroundColor = self.colorgyDimYellow
        schoolTitleView.frame.origin.y = view.frame.height - schoolTitleView.frame.height
        schoolTitleLable.text = "學校"
        schoolTitleLable.textAlignment = NSTextAlignment.Center
        schoolTitleLable.textColor = UIColor.whiteColor()
        schoolTitleLable.font = UIFont(name: "STHeitiTC-Medium", size: 14)
        view.addSubview(schoolTitleView)
        
        var schoolNameView = UIView(frame: CGRectMake(0, 0, view.frame.width - schoolTitleView.frame.width, 64))
        var schoolNameLable = UILabel(frame: CGRectMake(0, 0, schoolNameView.frame.width, 14))
        schoolNameLable.center = schoolNameView.center
        schoolNameView.addSubview(schoolNameLable)
        schoolNameView.backgroundColor = self.colorgyLightYellow
        schoolNameView.frame.origin.y = view.frame.height - schoolNameView.frame.height
        schoolNameView.frame.origin.x = schoolTitleView.frame.width
        schoolNameLable.text = school
        schoolNameLable.textAlignment = NSTextAlignment.Center
        schoolNameLable.textColor = UIColor.whiteColor()
        schoolNameLable.font = UIFont(name: "STHeitiTC-Medium", size: 14)
        view.addSubview(schoolNameView)

        // shadow
        shadowView.layer.shadowPath = UIBezierPath(rect: CGRectMake(view.bounds.origin.x, view.bounds.origin.y, view.bounds.width + 2, view.bounds.height + 2)).CGPath
        shadowView.layer.shadowColor = UIColor.blackColor().CGColor
        shadowView.layer.shadowOpacity = 0.5
        shadowView.layer.shadowRadius = 3
        shadowView.layer.shadowOffset = CGSizeMake(-1, 1)
        
        shadowView.center = self.view.center
        shadowView.addSubview(view)

        if self.view.frame.height <= 480 {
            // iphone 4s
            shadowView.frame.origin.y += 90
        } else if self.view.frame.height <= 568 {
            // for 5 and 5s
            shadowView.frame.origin.y += 70
        } else if self.view.frame.height <= 667 {
            // iphone 6
            shadowView.frame.origin.y += 40
        } else {
            // for 6+
            shadowView.frame.origin.y += 20
        }
        
        self.view.addSubview(shadowView)
    }
    
    func setupBackgorund() {
        // setup backgorund
        var image = UIImage(named: "LoginBackground")
        var w = image?.size.width
        var h = image?.size.height
        self.backgroundImage = UIImageView(frame: CGRectMake(0, 0, w!, h!))
        self.backgroundImage.center.x = self.view.center.x
        self.backgroundImage.image = image
        
        self.view.addSubview(self.backgroundImage)
    }
    
    func animateBackground() {
        // when user enter this view, logo and background image need to animate from top to bottom.
        // initial state
        self.backgroundImage.transform = CGAffineTransformMakeTranslation(0, -850)
        
        var transDown: CGAffineTransform!
        
        if self.view.frame.height <= 480 {
            // iphone 4s
            transDown = CGAffineTransformMakeTranslation(0, -518)
        } else if self.view.frame.height <= 568 {
            // for 5 and 5s
            transDown = CGAffineTransformMakeTranslation(0, -430)
        } else if self.view.frame.height <= 667 {
            // iphone 6
            transDown = CGAffineTransformMakeTranslation(0, -330)
        } else {
            // for 6+
            transDown = CGAffineTransformMakeTranslation(0, -261)
        }
        
        UIView.animateWithDuration(1.0, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: nil, animations: {
            // first drop down background image.
            self.backgroundImage.transform = transDown
            }, completion: nil)
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
