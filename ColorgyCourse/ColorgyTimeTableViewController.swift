//
//  ColorgyTimeTableViewController.swift
//  ColorgyTimeTable
//
//  Created by David on 2015/4/27.
//  Copyright (c) 2015年 David. All rights reserved.
//

import UIKit
import CoreData

class ColorgyTimeTableViewController: UIViewController {
    
    // MARK: - reveal menu
    @IBOutlet weak var revealMenuButton: UIBarButtonItem!
    
    // MARK: - declaration
    // screen h & w
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    // time table cell h & w
    var colorgyTimeTableCell: CGSize!
    
    // spacing of timetable and background view
    var timetableSpacing: CGFloat = 14
    
    // side bar h & w
    var sideBarWidth: CGFloat = 37
    // maybe we dont need height....
    var sideBarHeight: CGFloat!
    
    // header bar h & w
    // header bar height is fixed not sure if this is good
    var headerHeight: CGFloat = 42
    var headerWidth: CGFloat!
    
    // var course count
    // for 0 to 10 and A to D
    // we got 11 + 4 = 15 courses
    var courseCount: Int = 15
    
    // MARK: - course cell array
    // use to track if user has conflict with their course
    var coursesOnTimetable: NSMutableArray!
    var conflictCourses: [[NSMutableArray]]!
    
    // MARK: - timetableview
    var colorgyTimeTableView: UIScrollView!
    var isAnimating: Bool!
    
    // MARK: - color declaration
    // color region
    var colorgyOrange: UIColor = UIColor(red: 246/255.0, green: 150/255.0, blue: 114/255.0, alpha: 1)
    var colorgyDarkGray: UIColor = UIColor(red: 74/255.0, green: 74/255.0, blue: 74/255.0, alpha: 1)
    var timetableWhite: UIColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    var timetableBackgroundColor: UIColor = UIColor(red: 239/255.0, green: 238/255.0, blue: 238/255.0, alpha: 1)
    var colorgyBackgroundColor: UIColor = UIColor(red: 239/255.0, green: 238/255.0, blue: 238/255.0, alpha: 1)
    var timetableLineColor: UIColor = UIColor(red: 216/255.0, green: 216/255.0, blue: 216/255.0, alpha: 1)
    
    // MARK: - push segue
    var pushSegueCode: String!
    
    // upadting alert view
    var updatingAlert: UIAlertController!
    
    //MARK:- test refresh
    func refreshAccessToken() {
        
        let afManager = AFHTTPSessionManager(baseURL: NSURL(string: "https://colorgy.io/oauth/token"))
        
        afManager.requestSerializer = AFJSONRequestSerializer()
        afManager.responseSerializer = AFJSONResponseSerializer()
        
        var ud = NSUserDefaults.standardUserDefaults()
        let refresh_token = ud.objectForKey("ColorgyRefreshToken") as! String
        println(refresh_token)
        
        let params = [
            "grant_type": "refresh_token",
            // 應用程式ID application id, in colorgy server
            "client_id": "ad2d3492de7f83f0708b5b1db0ac7041f9179f78a168171013a4458959085ba4",
            "client_secret": "d9de77450d6365ca8bd6717bbf8502dfb4a088e50962258d5d94e7f7211596a3",
            "refresh_token": refresh_token
        ]
        
        afManager.POST("https://colorgy.io/oauth/token?", parameters: params, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) in
                println("ok! refresh!")
                println(responseObject)
                let token = responseObject["access_token"] as! String
                let created_at = String(stringInterpolationSegment: responseObject["created_at"])
                let expires_in = String(stringInterpolationSegment: responseObject["expires_in"])
                let refresh_token = responseObject["refresh_token"] as! String
                let token_type = responseObject["token_type"] as! String
                
                
                ud.setObject(token, forKey: "ColorgyAccessToken")
                ud.setObject(created_at, forKey: "ColorgyCreatedTime")
                ud.setObject(expires_in, forKey: "ColorgyExpireTime")
                ud.setObject(refresh_token, forKey: "ColorgyRefreshToken")
                ud.setObject(token_type, forKey: "ColorgyTokenType")
                ud.synchronize()
            
                if self.updatingAlert != nil {
                    self.updatingAlert.message = "\n正在下載新的課程資料...\n\n\n"
                }
            }, failure: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) in
                println("error refreshing token, authrication fail!!!")
                self.updatingAlert.dismissViewControllerAnimated(false, completion: nil)
                var delay = dispatch_time(DISPATCH_TIME_NOW, Int64( 1 * Double(NSEC_PER_SEC)))
                dispatch_after(delay, dispatch_get_main_queue()) {
                    let alert = UIAlertController(title: "錯誤", message: "與伺服器驗證過期，請重新登入！", preferredStyle: UIAlertControllerStyle.Alert)
                    let ok = UIAlertAction(title: "好", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
                        
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
    //                    ud.setObject(nil, forKey: "courseDataFromServer")
                        ud.setObject(nil, forKey: "userName")
                        ud.setObject(nil, forKey: "userSchool")
                        ud.synchronize()
                        
                        FBSession.activeSession().closeAndClearTokenInformation()
                        
                        self.logoutAnimation()

                        var delay = dispatch_time(DISPATCH_TIME_NOW, Int64( 1 * Double(NSEC_PER_SEC)))
                        dispatch_after(delay, dispatch_get_main_queue()) {
                            var storyboard = UIStoryboard(name: "Main", bundle: nil)
                            var vc = storyboard.instantiateViewControllerWithIdentifier("colorgyFBLoginView") as! ColorgyFBLoginViewController
                            self.presentViewController(vc, animated: true, completion: nil)
                        }
                    })
                    
                    alert.addAction(ok)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
    }
    
    func logoutAnimation() {
        
        var view = UIView(frame: CGRectMake(0, 0, 500, 500))
        view.layer.cornerRadius = 250
        view.backgroundColor = self.colorgyOrange
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
    
    // MARK: - view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        println("colorgy timetable view did load!")
        // get screen h & w
        self.screenHeight = self.view.frame.height
        self.screenWidth = self.view.frame.width
        
        // setup time table cell h & w
        // size of cell can be defined after known screen width, spacing, and side bar width
        var cellWidth = (self.screenWidth - 2 * self.timetableSpacing - self.sideBarWidth) / 5
        // cause cell is a square so width is equal to height
        var cellHeight = cellWidth
        self.colorgyTimeTableCell = CGSizeMake(cellWidth, cellHeight)
        // also header bar width is equal to cell width
        self.headerWidth = cellWidth
        
        // style of nav bar
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationItem.title = "課表"
        // never adjust this for me.....fuck
        // this is very important line!
        self.automaticallyAdjustsScrollViewInsets = false
        
        // generate timetable scrollview
        self.colorgyTimeTableView?.removeFromSuperview()
        self.colorgyTimeTableView = self.ColorgyTimeTableView()
        self.view.addSubview(self.colorgyTimeTableView)
        
        println("=====================")
        self.detectIfClassHasConflicts()
        
        
        self.animateConflictCourses()
        
        self.setupCourseNotification()
        
        println("im back!")
        
        println(self.getDataFromDatabase())
        // generate timetable scrollview
        
        // status bar frame change notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "barChange", name: UIApplicationDidChangeStatusBarFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "youRBack", name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "youGo", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        // notify
//        self.setupNotification()

        // animate conflict courses
        self.isAnimating = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.refreshTimetableCourseCells()
        
        self.detectIfClassHasConflicts()
        
        
        self.animateConflictCourses()
        
        self.setupCourseNotification()
        
        // test tabbar push hide
        // when you push to another view, you need to set back hide to true.
        // Or bottom bar will disappear when you push to another view
//        self.hidesBottomBarWhenPushed = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // when you push to another view, you need to set back hide to false.
        // Or bottom bar will not appear again
//        self.hidesBottomBarWhenPushed = false
    }
    
    //MARK:- notification
    func setupCourseNotification() {
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        if self.conflictCourses != nil {
        for (index, everyDaySessions) in enumerate(self.conflictCourses) {
            for (i, session) in enumerate(everyDaySessions) {
                if i == 0 {
                    println("head of session")
                    if session.count > 0 {
                        println("head of session")
                        var thisOneLocation = (session[0] as! UIView).subviews[1] as! UILabel
                        var thisOne = (session[0] as! UIView).subviews[0] as! UILabel
                        self.setNotificationWithMessage("等一下在" + thisOneLocation.text! + " 上 " + thisOne.text!, day: index + 1, session: i)
                    }
                } else {
                    println("\(index), \(i)")
                    if session.count > 0 {
                        var thisOne = (session[0] as! UIView).subviews[0] as! UILabel
                        var thisOneLocation = (session[0] as! UIView).subviews[1] as! UILabel
                        println("\(index), \(i) : \(thisOne.text)")
                        if everyDaySessions[i - 1].count > 0 {
                            var previousOne = (everyDaySessions[i - 1][0] as! UIView).subviews[0] as! UILabel
                            if thisOne.text == previousOne.text {
                                println("match!")
                            } else {
                                println("nop")
                            }
                        } else {
                            println("no course infront of ....")
                            self.setNotificationWithMessage("等一下在" + thisOneLocation.text! + " 上 " + thisOne.text!, day: index + 1, session: i)
                        }
                    }
                }
            }
        }
        } else {
            println("self.conflictCourses is nil fuck it")
        }
        println(UIApplication.sharedApplication().scheduledLocalNotifications)
        
    }
    
    func setNotificationWithMessage(message: String, day: Int, session: Int) {
        
        var cal = NSCalendar.currentCalendar()
        var com = NSDateComponents()
        com.year = 2014
        com.month = 12
        com.day = day
        com.hour = session + 7
        com.minute = 0
        com.second = 0
        
        cal.timeZone = NSTimeZone.defaultTimeZone()
        var dateToFire = cal.dateFromComponents(com)
        
        var localnoti = UILocalNotification()
        localnoti.timeZone = NSTimeZone.defaultTimeZone()
        localnoti.fireDate = dateToFire
        localnoti.repeatInterval = NSCalendarUnit.WeekCalendarUnit
        localnoti.alertBody = message
        
        UIApplication.sharedApplication().scheduleLocalNotification(localnoti)
        println("好的，設定完成")
        println(UIApplication.sharedApplication().scheduledLocalNotifications)
    }
    
    func youRBack() {
        // every time user come back to app, start animating.
        // cause this is always the very first scene, so just animate views here.
        // but if this view is not your first view, always animate once in viewdidload.
        println("大師兄你回來惹QAQQQQQQ")
        if !self.isAnimating {
            self.animateConflictCourses()
            self.isAnimating = true
        }
    }
    
    func youGo() {
        self.isAnimating = false
    }
    
    func barChange() {
        viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - add course button action
    
    @IBAction func pushToAddCourseView(sender: AnyObject) {
        println("push to add course view")
    }
    
    
    // MARK:- update data
    
    // this part is where you can get new data from server
    @IBAction func updateFromCloud(sender: AnyObject) {
        println("from cloud!!")
        var reachability = Reachability.reachabilityForInternetConnection()
        var networkStatus = reachability.currentReachabilityStatus().value
        if networkStatus == NotReachable.value {
            println("沒有往往")
            self.alertUserWIthError("你現在沒有網路耶....")
        } else {
            println("有往往")
            self.updateCourseFromServer()
        }
        
    }
    
    func alertUserWIthError(error: String) {
        let alert = UIAlertController(title: "錯誤", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "好", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func updateCourseFromServer() {
        
        let afManager = AFHTTPSessionManager(baseURL: NSURL(string: ""))
        
        var ud = NSUserDefaults.standardUserDefaults()
        var front_url = "https://colorgy.io:443/api/"
        var middle_url = "/courses.json?per_page=5000&&&&&access_token="
        let school = ud.objectForKey("userSchool") as! String
//        let school = ud.objectForKey("userSelectedSchool") as! String
        var token = ud.objectForKey("ColorgyAccessToken") as! String
        let url = front_url + school.lowercaseString + middle_url + token
        println("安安\n")
        println(url)
        

        afManager.requestSerializer = AFJSONRequestSerializer()
        afManager.responseSerializer = AFJSONResponseSerializer()
        
        // block whole view when updating...
        self.updatingAlert = UIAlertController(title: "更新中", message: "課程資料更新中，\n過程中請不要離開程式！\n\n", preferredStyle: UIAlertControllerStyle.Alert)
        let indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150))
        self.updatingAlert.view.addSubview(indicator)
        indicator.center = CGPointMake(134, 100)
        indicator.color = self.colorgyOrange
        indicator.startAnimating()
        self.presentViewController(self.updatingAlert, animated: true, completion: nil)
        
        // every time connecting to server, check token first
        self.updatingAlert.message = "\n正在更新驗證...\n\n\n"
        self.refreshAccessToken()
        
        
        var delay = dispatch_time(DISPATCH_TIME_NOW, Int64( 2 * Double(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue()) {
            afManager.GET(url, parameters: nil, success: { (task:NSURLSessionDataTask!, responseObject: AnyObject!) in
                println(responseObject.count)
                // check db and new course data, update old db data
                var vc = ColorgyViewAndAddCourseTableViewController()
                var coursesInDB = vc.getDataFromDatabase()
                // if get update course, archive it and replace it.
                let archiveData = vc.archive(responseObject)
                ud.setObject(archiveData, forKey: "courseDataFromServer")
                ud.synchronize()
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
                                let name = newCourse["name"] as? String
                                let lecturer = newCourse["lecturer"] as? String
                                var credits = Int32()
                                if let c = newCourse["credits"] as? Int {
                                    credits = Int32(c)
                                }
                                let uuid = newCourse["code"] as? String
                                // year, term, id, type
                                var year = Int32(newCourse["year"] as! Int)
                                if let y = newCourse["year"] as? Int {
                                    year = Int32(y)
                                }
                                var term = Int32()
                                if let t = newCourse["year"] as? Int {
                                    term = Int32(t)
                                }
                                var id = Int32()
                                if let i = newCourse["id"] as? Int {
                                    id = Int32(i)
                                }
                                let type = newCourse["_type"] as? String
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
                println("update success")
                self.updatingAlert.dismissViewControllerAnimated(false, completion: nil)
                self.viewDidLoad()
                var delay = dispatch_time(DISPATCH_TIME_NOW, Int64( 0.3 * Double(NSEC_PER_SEC)))
                dispatch_after(delay, dispatch_get_main_queue()) {
                    // after update, load view again
                    let success = UIAlertController(title: "更新成功", message: "✅ yeah!", preferredStyle: UIAlertControllerStyle.Alert)
                    self.presentViewController(success, animated: true, completion: nil)
                    delay = dispatch_time(DISPATCH_TIME_NOW, Int64( 1.5 * Double(NSEC_PER_SEC)))
                    dispatch_after(delay, dispatch_get_main_queue()) {
                        success.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
                }, failure: { (task: NSURLSessionDataTask!, error: NSError!) in
                    println("error post")
                    self.updatingAlert.dismissViewControllerAnimated(false, completion: nil)
                    if ud.objectForKey("courseDataFromServer") != nil {
                        println("✅ 使用者已經下載資料，無須在下載一次")
                        var delay = dispatch_time(DISPATCH_TIME_NOW, Int64( 1 * Double(NSEC_PER_SEC)))
                        dispatch_after(delay, dispatch_get_main_queue()) {
                            let err = UIAlertController(title: "錯誤", message: "更新失敗，你的網路可能有問題唷！", preferredStyle: UIAlertControllerStyle.Alert)
                            let ok = UIAlertAction(title: "好", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
                                self.viewDidLoad()
                            })
                            err.addAction(ok)
                            self.presentViewController(err, animated: true, completion: nil)
                        }
                    } else {
                        var delay = dispatch_time(DISPATCH_TIME_NOW, Int64( 1 * Double(NSEC_PER_SEC)))
                        dispatch_after(delay, dispatch_get_main_queue()) {
                            self.refreshAccessToken()
                            let err = UIAlertController(title: "錯誤", message: "更新失敗，" + school + "可能尚未開通使用！", preferredStyle: UIAlertControllerStyle.Alert)
                            let ok = UIAlertAction(title: "好", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
                                ud.setObject(nil, forKey: "userSelectedSchool")
                                ud.synchronize()
                                self.viewDidLoad()
                            })
                            err.addAction(ok)
                            self.presentViewController(err, animated: true, completion: nil)
                        }
                    }
                })
            }
    }
    // MARK:- register local notification
    func setupNotification() {
        println("setting notify")
        for i in 1...10 {
            println("setting \(i)")
            var noti = UILocalNotification()
            var hi = NSTimeInterval(i + 5)
            noti.fireDate = NSDate().dateByAddingTimeInterval(hi)
            noti.alertBody = "testing!!"
            UIApplication.sharedApplication().scheduleLocalNotification(noti)
        }
    }
    
    
    //MARK: - handle conflict courses
    func detectIfClassHasConflicts() {
        
        if self.coursesOnTimetable.count == 0 {
            println("count is 0, no conflicts.")
        } else {
            self.getConflictTimetable()
        }
        
    }
    
    func getConflictTimetable() {
        
        var conflictTimetable: [[NSMutableArray]] = [
                                                        [[], [], [], [], [], [], [], [], [], [], [], [], [], [], []],
                                                        [[], [], [], [], [], [], [], [], [], [], [], [], [], [], []],
                                                        [[], [], [], [], [], [], [], [], [], [], [], [], [], [], []],
                                                        [[], [], [], [], [], [], [], [], [], [], [], [], [], [], []],
                                                        [[], [], [], [], [], [], [], [], [], [], [], [], [], [], []]
                                                    ]
        
        for course in self.coursesOnTimetable {
            println(course.center)
            println(course.subviews)
            let position = self.getCoursePositionOnTimetable(course.center)!
            if position.day > 0 && position.session > 0 {
                // some session or day are smaller then 1
                println("conflict: \(position)")
                conflictTimetable[position.day - 1][position.session - 1].addObject(course)
            }
        }
        
        self.conflictCourses = conflictTimetable
    }
    
    func getCoursePositionOnTimetable(point: CGPoint?) -> (day: Int, session: Int)? {
        
        if point != nil {
            var day = Int((point!.x - self.timetableSpacing - self.sideBarWidth - self.colorgyTimeTableCell.width / 2) / self.colorgyTimeTableCell.width + 0.1) + 1
            // add 0.1 to prevent 1.99999 -> 1.0000
            var session = Int(((point!.y - self.timetableSpacing - self.headerHeight - self.colorgyTimeTableCell.width / 2) / self.colorgyTimeTableCell.height + 0.1) + 1)
            return (day, session)
        } else {
            return nil
        }
    }
    
    // handle conflict course animation
    func animateConflictCourses() {
        if self.conflictCourses != nil {
            for day in self.conflictCourses {
                for session in day {
                    if session.count > 1 {
                        // conflict courses, need animation to alert user.
                        for course in session {
                            let view = course as! UIView
                            view.backgroundColor = UIColor.redColor()
                            self.colorgyTimeTableView.bringSubviewToFront(view)
                            UIView.animateWithDuration(0.7, delay: 0, options: UIViewAnimationOptions.Repeat | UIViewAnimationOptions.Autoreverse | UIViewAnimationOptions.AllowUserInteraction, animations: {
                                    view.transform = CGAffineTransformMakeScale(1.1, 1.1)
                                }, completion: { (isFinished: Bool) in
                                    println("animation fiifsh")
                                    view.transform = CGAffineTransformMakeScale(1, 1)
                                })
                        }
                    }
                }
            }
        }
    }
    
    
    // MARK: - timetable grid view and content view
    func ColorgyTimeTableView() -> UIScrollView {
        
        // set its bounds
        var view = UIScrollView(frame: CGRectMake(0, 0, self.screenWidth, self.screenHeight))
        // background color of timetable
        view.backgroundColor = self.timetableBackgroundColor
        
        // set timetable scrollview's content size
        // width matches device width
        // height is headerBarHeight and coursescount height and some spacing
        view.contentSize = CGSizeMake(self.screenWidth, self.headerHeight + self.colorgyTimeTableCell.height * CGFloat(self.courseCount) + CGFloat(2) * self.timetableSpacing)
        // this is nav bar height -> 64
        view.contentInset.top = 64
        // this is tab bar height -> 49
        view.contentInset.bottom = 49
        view.contentOffset.y = -64
        
        // add grid view
        view.addSubview(self.ColorgyTimeTableColumnView())
        view.addSubview(self.ColorgyTimeTableRowSessionView("morning"))
        view.addSubview(self.ColorgyTimeTableRowSessionView("afternoon"))
        view.addSubview(self.ColorgyTimeTableRowSessionView("night"))
        view.addSubview(self.ColorgyTimeTableColumnSeperatorLine(view))
        
        // add course here
//        view.addSubview(self.CourseViewAtDay(1, session: "A"))
//        view.addSubview(self.CourseViewAtDay(2, session: "2"))
        
        // update timetableview
        // this will return array of uiviews
        // before track courses position, init courseOnTimetable first
        self.coursesOnTimetable = NSMutableArray()
        // prepare gesture
        // updateTimetableCourse will return views....
        if let views = self.updateTimetableCourse() {
            // this part will add gesture to views.
            for v in views {
                let tap = UITapGestureRecognizer()
                tap.numberOfTouchesRequired = 1
                tap.addTarget(self, action: "tapOnCourseCellView:")
                v.addGestureRecognizer(tap)
                view.addSubview(v)
                self.coursesOnTimetable.addObject(v)
            }
        }
        
        
        return view as UIScrollView
    }
    
    func refreshTimetableCourseCells() {
        
        if self.coursesOnTimetable != nil {
            for cell in self.coursesOnTimetable {
                if let viewcell = cell as? UIView {
                    // remove views
                    viewcell.removeFromSuperview()
                }
            }
        }
        
        // update timetableview
        // this will return array of uiviews
        // before track courses position, init courseOnTimetable first
        self.coursesOnTimetable = NSMutableArray()
        // prepare gesture
        // updateTimetableCourse will return views....
        if let views = self.updateTimetableCourse() {
            // this part will add gesture to views.
            for v in views {
                let tap = UITapGestureRecognizer()
                tap.numberOfTouchesRequired = 1
                tap.addTarget(self, action: "tapOnCourseCellView:")
                v.addGestureRecognizer(tap)
                self.colorgyTimeTableView.addSubview(v)
                self.coursesOnTimetable.addObject(v)
            }
        }
    }
    
    func tapOnCourseCellView(gesture: UITapGestureRecognizer) {
        println("tapppp")
        println(gesture.view?.frame)
        let position = self.getCoursePositionOnTimetable(gesture.view?.center)
        if position != nil {
            self.showCourseOnDay(position!.day, session: position!.session)
        }
    }
    
    func showCourseOnDay(day: Int, session: Int) {
        let courses = self.conflictCourses[day - 1][session - 1]
        println(courses.count)
        var message = ""
        var courseName = ""
        var title = "課程資訊"
        if courses.count > 1 {
            title = "衝堂囉！"
        }
        for course in courses {
            let c = course as! UIView
            println(c.subviews)
            for subview in c.subviews {
                if subview.isKindOfClass(UILabel) && subview.tag == 1 {
                    let label = subview as! UILabel
                    message += "課程名稱：" + label.text! + "\n"
                    courseName = label.text!
                } else if subview.isKindOfClass(UILabel) && subview.tag == 2 {
                    let label = subview as! UILabel
                    message += "教室位置：" + label.text! + "\n"
                }
            }
            println("以上課程衝堂！")
        }
        if courses.count > 1 {
            message += "以上課程衝堂！"
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "好", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(ok)
        // show alert!
//        self.presentViewController(alert, animated: true, completion: nil)
        if let code = self.getCourseCodeWithCourseName(courseName) {
            println(code)
            self.pushSegueCode = code
            // push segue
            performSegueWithIdentifier("getCourseDetail", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "getCourseDetail" {
            if self.pushSegueCode != nil {
                var vc = segue.destinationViewController as! ColorgyCourseDetailPageViewController
                
                vc.pushWithCourseCode(self.pushSegueCode)
            }
        }
    }
    
    func getCourseCodeWithCourseName(name: String?) -> String? {
        
        let courses = self.getDataFromDatabase()
        
        if courses != nil {
            for course in courses! {
                // check if name match
                if course.name == name {
                    return course.uuid
                }
            }
        } else {
            // no data in db, so return nil
            return nil
        }
        
        // if no course match, return nil
        return nil
    }
    
    func ColorgyTimeTableColumnSeperatorLine(view: UIScrollView) -> UIView {
        
        var lineContainer = UIView(frame: view.frame)
        
        var offset = CGSizeMake(self.timetableSpacing + self.sideBarWidth, self.timetableSpacing + self.headerHeight)
        
        // draw lines
        for i in 1...5 {
            var moveALittleBit = -CGFloat(0.125 * Double(i - 1))
            if i == 2 {
                moveALittleBit -= 0.2
            }
            var line = UIView(frame: CGRectMake(moveALittleBit + offset.width + CGFloat(i - 1) * self.colorgyTimeTableCell.width, offset.height, 1, self.colorgyTimeTableCell.height * CGFloat(self.courseCount)))
            line.backgroundColor = self.timetableLineColor
            
            lineContainer.addSubview(line)
        }
        
        
        return lineContainer
    }
    
    func ColorgyTimeTableColumnView() -> UIView {
        // this view is vertical view
        // this is days from mon to fri
        var view = UIView(frame: CGRectMake(self.timetableSpacing + self.sideBarWidth, 0.0 + self.timetableSpacing, self.colorgyTimeTableCell.width * 5, self.headerHeight + self.colorgyTimeTableCell.height * CGFloat(self.courseCount)))
        println(view.frame)
        println(self.colorgyTimeTableCell.height)
        view.backgroundColor = self.timetableWhite
        view.layer.borderWidth = 1
        // outer line of timetable
        view.layer.borderColor = self.timetableLineColor.CGColor
        view.layer.cornerRadius = 10
        
        // vertical line in this view, to seperate days
        for day in 1...4 {
            var line = UIView(frame: CGRectMake(0, 0, 1, self.headerHeight + self.colorgyTimeTableCell.height * CGFloat(self.courseCount)))
            line.backgroundColor = self.timetableLineColor
            
            line.center.x = self.colorgyTimeTableCell.width * CGFloat(day)
            
            view.addSubview(line)
        }
        
        // add day label
        for day in 1...5 {
            var label = UILabel(frame: CGRectMake(0, 0, self.headerWidth, self.headerHeight))
            label.textAlignment = NSTextAlignment.Center
            label.center.y = self.headerHeight / 2
            label.textColor = self.timetableLineColor
            label.center.x = CGFloat(day) * self.colorgyTimeTableCell.width - self.colorgyTimeTableCell.width / 2
            
            label.text = "\(day)"
            
            view.addSubview(label)
        }
        
        return view as UIView
    }
    
    func ColorgyTimeTableRowSessionView(time: NSString) -> UIView {
        
        var courses: CGFloat!
        var timeOffset: CGFloat!
        switch time {
            case "morning":
                courses = 5
                timeOffset = 0
            case "afternoon":
                courses = 5
                timeOffset = self.colorgyTimeTableCell.height * CGFloat(6)
            case "night":
                courses = 4
                timeOffset = self.colorgyTimeTableCell.height * CGFloat(11)
            default:
                break
        }
        
        var view = UIView(frame: CGRectMake(self.timetableSpacing, self.timetableSpacing + self.headerHeight + timeOffset, self.sideBarWidth + self.colorgyTimeTableCell.width * CGFloat(5), self.colorgyTimeTableCell.height * courses))
        view.backgroundColor = self.timetableWhite
        // outer line of timetable
        view.layer.borderColor = self.timetableLineColor.CGColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 6
        
        // add lines to it
        for i in 1...Int(courses - 1) {
            var line = UIView(frame: CGRectMake(0, 0, self.sideBarWidth + self.colorgyTimeTableCell.width * CGFloat(5), 1))
            line.backgroundColor = self.timetableLineColor
            
            line.center.y = self.colorgyTimeTableCell.height * CGFloat(i)
            view.addSubview(line)
        }
        
        // adding side period from 0~10 a~d
        switch time {
            case "morning":
                for i in 1...Int(courses) {
                    var label = UILabel(frame: CGRectMake(0, 0, self.sideBarWidth, self.sideBarWidth))
                    label.text = "\(i-1)"
                    label.center.y = self.colorgyTimeTableCell.height * CGFloat(i) - self.colorgyTimeTableCell.height / 2
                    // problem here!!!!
                    label.center.x = self.sideBarWidth / 2
                    label.textColor = self.timetableLineColor
                    label.textAlignment = NSTextAlignment.Center
                    view.addSubview(label)
                }
            case "afternoon":
                for i in 1...Int(courses) {
                    var label = UILabel(frame: CGRectMake(0, 0, self.sideBarWidth, self.sideBarWidth))
                    label.text = "\(i+5)"
                    label.center.y = self.colorgyTimeTableCell.height * CGFloat(i) - self.colorgyTimeTableCell.height / 2
                    // problem here!!!!
                    label.center.x = self.sideBarWidth / 2
                    label.textColor = self.timetableLineColor
                    label.textAlignment = NSTextAlignment.Center
                    view.addSubview(label)
                }
            case "night":
                var nightCourse = ["A", "B", "C", "D"]
                for i in 1...Int(courses) {
                    var label = UILabel(frame: CGRectMake(0, 0, self.sideBarWidth, self.sideBarWidth))
                    label.text = "\(nightCourse[i-1])"
                    label.center.y = self.colorgyTimeTableCell.height * CGFloat(i) - self.colorgyTimeTableCell.height / 2
                    // problem here!!!!
                    label.center.x = self.sideBarWidth / 2
                    label.textColor = self.timetableLineColor
                    label.textAlignment = NSTextAlignment.Center
                    view.addSubview(label)
                }
            default:
                break
        }

        // add session to it
        return view as UIView
    }
    

    func CourseViewAtDay(day: Int, session: String) -> UIView {
        
        // srink cell by 1, 1 make it fit to the bound of time table
        var CellSrinkSize = CGSizeMake(1, 1)
        var view = UIView(frame: CGRectMake(0, 0, self.colorgyTimeTableCell.width - CellSrinkSize.width, self.colorgyTimeTableCell.height - CellSrinkSize.height))
        var offset = CGPointMake(self.timetableSpacing + self.sideBarWidth - self.colorgyTimeTableCell.width / 2, self.timetableSpacing + self.headerHeight - self.colorgyTimeTableCell.width / 2)
        
        // course cell style
        view.backgroundColor = UIColor.grayColor()
        view.layer.cornerRadius = 5
        
        // postion of course
        view.center.x = offset.x + CGFloat(day) * self.colorgyTimeTableCell.width
        if let morningClass = session.toInt() {
            // course in morning
            view.center.y = offset.y + CGFloat(morningClass) * self.colorgyTimeTableCell.height
        } else {
            // course at night
            if session == "A" {
                view.center.y = offset.y + CGFloat(12) * self.colorgyTimeTableCell.height
            } else if session == "B" {
                view.center.y = offset.y + CGFloat(13) * self.colorgyTimeTableCell.height
            } else if session == "C" {
                view.center.y = offset.y + CGFloat(14) * self.colorgyTimeTableCell.height
            } else if session == "D" {
                view.center.y = offset.y + CGFloat(15) * self.colorgyTimeTableCell.height
            }
        }
        
        return view as UIView
    }
    
    
    // MARK: - add course cell region
    func addCourseWith(courseName: String, location: String, day: Int, session: Int) -> UIView? {
        
        var view = UIView(frame: CGRectMake(0, 0, self.colorgyTimeTableCell.width - 1, self.colorgyTimeTableCell.height - 1))
        var label = UILabel(frame: CGRectMake(0, 3, self.colorgyTimeTableCell.width - 1, (self.colorgyTimeTableCell.height - 1) * 0.6))
        
        view.layer.cornerRadius = 5
        
        // name label
        label.text = courseName
        label.font = UIFont(name: "STHeitiTC-Medium", size: 13)
        label.textAlignment = NSTextAlignment.Center
        label.numberOfLines = 4
        label.textColor = UIColor.whiteColor()
        label.tag = 1
        
        view.addSubview(label)
        
        // location label
        var titlelabel = UILabel(frame: CGRectMake(0, label.bounds.size.height, self.colorgyTimeTableCell.width - 1, (self.colorgyTimeTableCell.height - 1) * 0.4))
        titlelabel.text = location
        titlelabel.font = UIFont(name: "STHeitiTC-Medium", size: 11)
        titlelabel.textAlignment = NSTextAlignment.Center
        titlelabel.numberOfLines = 1
        titlelabel.textColor = UIColor.whiteColor()
        titlelabel.tag = 2
        
        view.addSubview(titlelabel)
        
        var x = self.timetableSpacing + self.sideBarWidth - self.colorgyTimeTableCell.width / 2 + CGFloat(day) * self.colorgyTimeTableCell.width
        var y = self.timetableSpacing + self.headerHeight - self.colorgyTimeTableCell.width / 2 + CGFloat(session) * self.colorgyTimeTableCell.width
        
        view.center = CGPointMake(x, y)
        
        
        if day < 6 && day > 0 && session > 0 {
            // some day and session are smaller then 0
            return view
        } else {
            return nil
        }
    }

    // update timetable
    func updateTimetableCourse() -> [UIView]? {
        
        var timetableViews = [UIView]()
        var courses = self.getDataFromDatabase()
        if courses == nil {
            return nil
        }
        
        for course in courses! {
            if course.day_1 != "<null>" {
                var v = self.addCourseWith(course.name, location: course.location_1, day: course.day_1.toInt()!, session: course.period_1.toInt()!)
                if v != nil {
                    v!.backgroundColor = UIColor(red: 248/255.0, green: 150/255.0, blue: 128/255.0, alpha: 1)
                    timetableViews.append(v!)
                }
            }
            if course.day_2 != "<null>" {
                var v = self.addCourseWith(course.name, location: course.location_2, day: course.day_2.toInt()!, session: course.period_2.toInt()!)
                if v != nil {
                    v!.backgroundColor = UIColor(red: 248/255.0, green: 150/255.0, blue: 128/255.0, alpha: 1)
                    timetableViews.append(v!)
                }
            }
            if course.day_3 != "<null>" {
                var v = self.addCourseWith(course.name, location: course.location_3, day: course.day_3.toInt()!, session: course.period_3.toInt()!)
                if v != nil {
                    v!.backgroundColor = UIColor(red: 248/255.0, green: 150/255.0, blue: 128/255.0, alpha: 1)
                    timetableViews.append(v!)
                }
            }
            if course.day_4 != "<null>" {
                var v = self.addCourseWith(course.name, location: course.location_4, day: course.day_4.toInt()!, session: course.period_4.toInt()!)
                if v != nil {
                    v!.backgroundColor = UIColor(red: 248/255.0, green: 150/255.0, blue: 128/255.0, alpha: 1)
                    timetableViews.append(v!)
                }
            }
            if course.day_5 != "<null>" {
                var v = self.addCourseWith(course.name, location: course.location_5, day: course.day_5.toInt()!, session: course.period_5.toInt()!)
                if v != nil {
                    v!.backgroundColor = UIColor(red: 248/255.0, green: 150/255.0, blue: 128/255.0, alpha: 1)
                    timetableViews.append(v!)
                }
            }
            if course.day_6 != "<null>" {
                var v = self.addCourseWith(course.name, location: course.location_6, day: course.day_6.toInt()!, session: course.period_6.toInt()!)
                if v != nil {
                    v!.backgroundColor = UIColor(red: 248/255.0, green: 150/255.0, blue: 128/255.0, alpha: 1)
                    timetableViews.append(v!)
                }
            }
            if course.day_7 != "<null>" {
                var v = self.addCourseWith(course.name, location: course.location_7, day: course.day_7.toInt()!, session: course.period_7.toInt()!)
                if v != nil {
                    v!.backgroundColor = UIColor(red: 248/255.0, green: 150/255.0, blue: 128/255.0, alpha: 1)
                    timetableViews.append(v!)
                }
            }
            if course.day_8 != "<null>" {
                var v = self.addCourseWith(course.name, location: course.location_8, day: course.day_8.toInt()!, session: course.period_8.toInt()!)
                if v != nil {
                    v!.backgroundColor = UIColor(red: 248/255.0, green: 150/255.0, blue: 128/255.0, alpha: 1)
                    timetableViews.append(v!)
                }
            }
            if course.day_9 != "<null>" {
                var v = self.addCourseWith(course.name, location: course.location_9, day: course.day_9.toInt()!, session: course.period_9.toInt()!)
                if v != nil {
                    v!.backgroundColor = UIColor(red: 248/255.0, green: 150/255.0, blue: 128/255.0, alpha: 1)
                    timetableViews.append(v!)
                }
            }
        }
        
        return timetableViews
    }
    
    //MARK:- db operation
    func getDataFromDatabase() -> [Course]? {
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext {
            let fetchRequest = NSFetchRequest(entityName: "Course")
            var e: NSError?
            var course: [Course] = managedObjectContext.executeFetchRequest(fetchRequest, error: &e) as! [Course]
            if e != nil {
                println("something error")
            } else {
                println("ok count: \(course.count)")
            }
            
            // if sucessfullly get the selected coruse data
            // return it, as [Course] type
            return course
        }
        
        // if something wrong, return nil.
        return nil
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
