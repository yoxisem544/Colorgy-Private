//
//  ColorgyViewAndAddCourseTableViewController.swift
//  ColorgyCourse
//
//  Created by David on 2015/5/4.
//  Copyright (c) 2015年 David. All rights reserved.
//

import UIKit
import CoreData

class ColorgyViewAndAddCourseTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {

    // MARK: - reveal menu
    @IBOutlet weak var revealMenuButon: UIBarButtonItem!
    
    // MARK: - declaration
    // course data parsed from json file, save it as a array
    var parsedCourseData: NSArray!
    // parse parsedCourseData in to courseData, for easier usage
    var courseData: NSMutableArray! = NSMutableArray()
    // search controller, let this view able to search.
    var searchCourse = UISearchController()
    
    // filteredcoures is courses that filtered by search text
    var filteredCourse: NSMutableArray! = NSMutableArray()
    
    // courses user added to their timetable
    var coursesAddedToTimetable: NSMutableArray!
    
    // background dimmer view
    var dimmer: UIView!
    
    // reloader
    var reloader: NSTimer!
    
    // indicaotr
    var indicator: UIActivityIndicatorView!
    
    // MARK: - color
    var colorgyDimOrange: UIColor = UIColor(red: 226/255.0, green: 109/255.0, blue: 90/255.0, alpha: 1)
    var colorgyLightOrange: UIColor = UIColor(red: 248/255.0, green: 150/255.0, blue: 128/255.0, alpha: 1)
    var colorgyDimYellow: UIColor = UIColor(red: 245/255.0, green: 166/255.0, blue: 35/255.0, alpha: 1)
    var colorgyLightYellow: UIColor = UIColor(red: 244/255.0, green: 188/255.0, blue: 94/255.0, alpha: 1)
    var colorgyDarkGray = UIColor(red: 74/255.0, green: 74/255.0, blue: 74/255.0, alpha: 1)
//    var colorgyGreen: UIColor = UIColor(red: 42/255.0, green: 171/255.0, blue: 147/255.0, alpha: 1)
    var colorgyBackgroundColor: UIColor = UIColor(red: 250/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1)
    
    // updating
    var updatingAlert: UIAlertController!
    
    // MARK: - view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // test tabbar push hide
        println("😀 \(self.hidesBottomBarWhenPushed)")
        self.hidesBottomBarWhenPushed = false
        
        // tableview delegate and datasource
        self.tableView.delegate = self
        self.tableView.dataSource = self

        // tableview style
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.backgroundColor = self.colorgyBackgroundColor
        // navi style
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationItem.title = "已選課程"
        
        // get json file
//        let path = NSBundle.mainBundle().pathForResource("CCU_courses", ofType: "json")
        var e: NSError?
//        var courseData = NSData(contentsOfFile: path!)
        
        // fetch data
        var ud = NSUserDefaults.standardUserDefaults()
        // first init self.parsedCourseData
        self.parsedCourseData = []
        dispatch_async(dispatch_get_main_queue()) {
            if ud.objectForKey("courseDataFromServer") != nil {
                var courseData = NSData(data: ud.objectForKey("courseDataFromServer") as! NSData)
                
                self.parsedCourseData = self.unarchive(courseData)
                println("length is \(self.parsedCourseData.count)")
                if e != nil {
                    println(e)
                }
            } else {
                
            }
        }
        
        var reachability = Reachability.reachabilityForInternetConnection()
        var networkStatus = reachability.currentReachabilityStatus().value
        if networkStatus == NotReachable.value {
            println("沒有往往")
        } else {
            println("有往往")
        }
        
        // setup search controller and its style
        self.searchCourse = UISearchController(searchResultsController: nil)
        self.searchCourse.searchResultsUpdater = self
        self.searchCourse.searchBar.sizeToFit()
        self.searchCourse.searchBar.placeholder = "搜尋並加入課程"
        // i want to select tableview while searching
        self.searchCourse.dimsBackgroundDuringPresentation = false
        // change search abr color
        // tintColor is right button's color
        self.searchCourse.searchBar.tintColor = UIColor.whiteColor()
        // barTintColor is color of surrounding.
        self.searchCourse.searchBar.barTintColor = self.colorgyLightOrange
//        self.searchCourse.searchBar.searchBarStyle = UISearchBarStyle.Minimal
        self.tableView.bounces = false
        // search cancel button -> done button
        self.searchCourse.searchBar.setValue("選好了！", forKey: "_cancelButtonText")
        
//        self.searchCourse.dimsBackgroundDuringPresentation = true

        // add search bar to top of tableview
        self.tableView.tableHeaderView = self.searchCourse.searchBar
        // search keyboard dismissmode
        self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        // register a keyboard hide notificaiton
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHide", name: UIKeyboardDidHideNotification, object: nil)
        
        //style fo search bar
        //if you dont add this, status bar will be ruin by the search
        self.definesPresentationContext = true
        
//        self.getDataFromDatabase()
//        self.storeDataToDatabase()
//        self.isCourseAlreadyAddedToSelectedCourse()
        
        // fetch data at the very begining
        self.fetchDataAndUpdateSelectedCourses()
        
        // dimmer test region
        self.dimmer = UIView(frame: CGRectMake(0, 44, self.view.frame.width, self.view.frame.height))
        self.dimmer.backgroundColor = UIColor.blackColor()
        self.dimmer.alpha = 0.5
        self.tableView.addSubview(self.dimmer)
        self.dimmer.hidden = true
        
        // indicator
        self.indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
        self.indicator.center = CGPointMake(self.view.center.x, 128)
        self.view.addSubview(self.indicator)
    }
    
    // MARK: - keyboard handle
    func keyboardDidHide() {
        if self.searchCourse.active && (self.searchCourse.searchBar.text == "") {
            self.searchCourse.active = false
        }
    }
    
    // MARK: view disappear
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        println("消司")
    }
    
    //MARK:- update from cloud
    @IBAction func updateFromCloud(sender: AnyObject) {
        println("from cloud!!")
        var reachability = Reachability.reachabilityForInternetConnection()
        var networkStatus = reachability.currentReachabilityStatus().value
        if networkStatus == NotReachable.value {
            println("沒有往往")
            self.alertUserWIthError("你現在沒有網路唷～～～～～")
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
    
    // MARK: - Fetch data from server
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
        
        // block when updating...
        self.updatingAlert = UIAlertController(title: "更新中", message: "課程資料更新中，\n過程中請不要離開程式！\n\n", preferredStyle: UIAlertControllerStyle.Alert)
        let indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150))
        self.updatingAlert.view.addSubview(indicator)
        indicator.center = CGPointMake(134, 100)
        indicator.color = self.colorgyLightOrange
        indicator.startAnimating()
        self.presentViewController(self.updatingAlert, animated: true, completion: nil)
        
        // refresh every time
        self.refreshAccessToken()
        
        //fire after 2 second, wait for refresh
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
                    let success = UIAlertController(title: "更新成功", message: "✅yeah!", preferredStyle: UIAlertControllerStyle.Alert)
                    self.presentViewController(success, animated: true, completion: nil)
                    delay = dispatch_time(DISPATCH_TIME_NOW, Int64( 1.5 * Double(NSEC_PER_SEC)))
                    dispatch_after(delay, dispatch_get_main_queue()) {
                        success.dismissViewControllerAnimated(true, completion: nil)
                        self.tableView.reloadData()
                    }
                }
                }, failure: { (task: NSURLSessionDataTask!, error: NSError!) in
                    println("error post")
                    // dismiss loading view
                    self.updatingAlert.dismissViewControllerAnimated(false, completion: nil)
                    var delay = dispatch_time(DISPATCH_TIME_NOW, Int64( 1 * Double(NSEC_PER_SEC)))
                    dispatch_after(delay, dispatch_get_main_queue()) {
                        self.refreshAccessToken()
                        let err = UIAlertController(title: "錯誤", message: "更新失敗，可能是網路不穩定造成的！再重新試試看吧！", preferredStyle: UIAlertControllerStyle.Alert)
                        let ok = UIAlertAction(title: "好", style: UIAlertActionStyle.Default, handler: nil)
                        err.addAction(ok)
                        self.presentViewController(err, animated: true, completion: nil)
                    }
            })
        }
    }
    
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
            }, failure: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) in
                println("error!!!")
                self.updatingAlert.dismissViewControllerAnimated(false, completion: nil)
                var delay = dispatch_time(DISPATCH_TIME_NOW, Int64( 0.5 * Double(NSEC_PER_SEC)))
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
        view.backgroundColor = self.colorgyLightOrange
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
    
    // MARK: - compare data
    
    // check if course is already added to selected course
    func isCourseAlreadyAddedToSelectedCourse(code: String) -> Bool{
        
        var courses = self.getDataFromDatabase()
        if courses != nil {
            // get data!
            var isRepeated: Bool = false
            for cc in courses! {
                let c = cc as Course
                if c.uuid == code {
                    isRepeated = true
                }
            }
            
            // judge if is already repeated 
            if isRepeated {
                println("yes repeat")
            } else {
                println("no repeat")
            }
            
            return isRepeated
        }
        
        // empty course
        return false
    }
    
    func alertUserCourseIsEmpty() {
        let alert = UIAlertController(title: "哦！出錯了！", message: "你的課程資料是空的！", preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "好", style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction!) -> Void in
            println("好！")
            alert.dismissViewControllerAnimated(true, completion: nil)
        })
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: {
            self.searchCourse.active = false
        })
    }
    
    // MARK: - operating database
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
    
    
    // this function help you to store data into db
    func storeDataToDatabase(name: String?, lecturer: String?, credits: Int32?, uuid: String?, sessions: AnyObject, year: Int32?, term: Int32?, id: Int32?, type: String?) {
        
        println("store")
        // get out managedObjectContext
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext {
            
            // insert a new course, but not yet saved.
            var course = NSEntityDescription.insertNewObjectForEntityForName("Course", inManagedObjectContext: managedObjectContext) as! Course
            // assign its value to it's key
            course.name = name
            course.lecturer = lecturer
            course.credits = credits!
            course.uuid = uuid
            
            course.id = id!
            course.type = type!
            course.year = year!
            course.term = term!
            
            course.day_1 = sessions[0][0] as! String
            course.day_2 = sessions[1][0] as! String
            course.day_3 = sessions[2][0] as! String
            course.day_4 = sessions[3][0] as! String
            course.day_5 = sessions[4][0] as! String
            course.day_6 = sessions[5][0] as! String
            course.day_7 = sessions[6][0] as! String
            course.day_8 = sessions[7][0] as! String
            course.day_9 = sessions[8][0] as! String
            
            course.period_1 = sessions[0][1] as! String
            course.period_2 = sessions[1][1] as! String
            course.period_3 = sessions[2][1] as! String
            course.period_4 = sessions[3][1] as! String
            course.period_5 = sessions[4][1] as! String
            course.period_6 = sessions[5][1] as! String
            course.period_7 = sessions[6][1] as! String
            course.period_8 = sessions[7][1] as! String
            course.period_9 = sessions[8][1] as! String
            
            course.location_1 = sessions[0][2] as! String
            course.location_2 = sessions[1][2] as! String
            course.location_3 = sessions[2][2] as! String
            course.location_4 = sessions[3][2] as! String
            course.location_5 = sessions[4][2] as! String
            course.location_6 = sessions[5][2] as! String
            course.location_7 = sessions[6][2] as! String
            course.location_8 = sessions[7][2] as! String
            course.location_9 = sessions[8][2] as! String
     
            var e: NSError?
            // to see if successfully store to db
            if managedObjectContext.save(&e) != true {
                // if i got a error
                println("error \(e)")
            } else {
                // if success
                println("store OK!")
            }
        }
    }

    
    // fetch data and update view, this function will update selected course.
    // these data are from db
    func fetchDataAndUpdateSelectedCourses() {
        // first get out the data from db
        if self.coursesAddedToTimetable == nil {
            // this if again is to prevent duplicate tableview data....
            if let coursesFromDB = self.getDataFromDatabase() {
                // if successfully get course data, parse it.

                // if courseaddedtotimetable is nil, alloc it.
                // or if there are some data in it re alloc it to make it a clean table.
                // then get data from db again
                self.coursesAddedToTimetable = NSMutableArray()
                
                if !self.coursesAddedToTimetable.isEqual(nil) {
                    dispatch_async(dispatch_get_main_queue()) {
                        for c in coursesFromDB {
                            let weekdays = ["Mon", "Tue", "wed", "Thu", "Fri", "Sat", "Sun"]
                            var location = ""
                            var period = ""
                            
                            if c.day_1 != "<null>" {
                                period += weekdays[c.day_1.toInt()! - 1] + "\(c.period_1.toInt()!-1)" + " "
                                location += c.location_1 + " "
                            }
                            if c.day_2 != "<null>" {
                                period += weekdays[c.day_2.toInt()! - 1] + "\(c.period_2.toInt()!-1)" + " "
                                location += c.location_2 + " "
                            }
                            if c.day_3 != "<null>" {
                                period += weekdays[c.day_3.toInt()! - 1] + "\(c.period_3.toInt()!-1)" + " "
                                location += c.location_3 + " "
                            }
                            if c.day_4 != "<null>" {
                                period += weekdays[c.day_4.toInt()! - 1] + "\(c.period_4.toInt()!-1)" + " "
                                location += c.location_4 + " "
                            }
                            if c.day_5 != "<null>" {
                                period += weekdays[c.day_5.toInt()! - 1] + "\(c.period_5.toInt()!-1)" + " "
                                location += c.location_5 + " "
                            }
                            if c.day_6 != "<null>" {
                                period += weekdays[c.day_6.toInt()! - 1] + "\(c.period_6.toInt()!-1)" + " "
                                location += c.location_6 + " "
                            }
                            if c.day_7 != "<null>" {
                                period += weekdays[c.day_7.toInt()! - 1] + "\(c.period_7.toInt()!-1)" + " "
                                location += c.location_7 + " "
                            }
                            if c.day_8 != "<null>" {
                                period += weekdays[c.day_8.toInt()! - 1] + "\(c.period_8.toInt()!-1)" + " "
                                location += c.location_8 + " "
                            }
                            if c.day_9 != "<null>" {
                                period += weekdays[c.day_9.toInt()! - 1] + "\(c.period_9.toInt()!-1)" + " "
                                location += c.location_9 + " "
                            }
                            
                            var lecturer = ""
                            if c.lecturer == nil {
                                lecturer = "老師"
                            }
                            lecturer = (c.lecturer != nil) ? c.lecturer : "老師"
                            var object = [c.name, lecturer, String(Int(c.credits)), c.uuid, period, location]
                            self.coursesAddedToTimetable.addObject(object)
                        }
                        self.tableView.reloadData()
                    }
                }
            }
        }
        // after getting data from db
        // reload tableview
//        self.tableView.reloadData()
    }
    
    // MARK: - compress data
    
    func archive(array: AnyObject) -> NSData {
        let a = array as! NSArray
        return NSKeyedArchiver.archivedDataWithRootObject(array)
    }
    
    func unarchive(data: NSData) -> NSArray {
        return NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSArray
    }

    
    // MARK: - Search bar update and filter
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        println("update!")
        dispatch_async(dispatch_get_main_queue()) {
            self.filterContentForSearchText(self.searchCourse.searchBar.text)
        }
        self.tableView.reloadData()
        
        if self.searchCourse.active && self.searchCourse.searchBar.text != "" {
            // user is searching course
            // do something if user is using search bar
            // light up backgoround view if user is searching
            self.dimmerViewisOn(false)
        } else {
            // user is viewing selected courses
            // display it to user
            self.fetchDataAndUpdateSelectedCourses()
            // dim backgoround view if user is not searching
            if self.searchCourse.active {
                // if user is searching but not entering anything, dim the view
                self.dimmerViewisOn(true)
                if self.parsedCourseData == [] {
                    self.alertUserCourseIsEmpty()
                }
            } else {
                // if user leave search, light up view
                self.dimmerViewisOn(false)
            }
        }
    }
    
    func dimmerViewisOn(isOn: Bool) {

        if isOn {
            self.dimmer.hidden = false
        } else {
            self.dimmer.hidden = true
        }
        
    }
    
    func filterContentForSearchText(searchText: String) {
        
        // this function will filter data and display to user
        // first clear filtered course
        self.filteredCourse = []
        
        
        
        // loop through all course data
        if searchText != "" {
            // start searching...
            self.indicator.startAnimating()
            
            for data in self.parsedCourseData {
//                    let c = data["credits"]
//                    var credits = "\(c)"
//                    var uuid = data["code"] as! String
                
                var match: Bool! = false
                
                if let name = data["name"] as? String {
                    if name.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil {
                        match = true
                    }
                }
                if let lecturer = data["lecturer"] as? String {
                    if lecturer.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil {
                        match = true
                    }
                }
//                    if credits.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil {
//                        match = true
//                    }
                if let code = data["code"] as? String {
                    if code.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil {
                        match = true
                    }
                }
                
                // if match search text, add to filter course, ready to display to user
                if match! {
                    self.filteredCourse.addObject(data)
                }
            }
            self.indicator.stopAnimating()
            self.tableView.reloadData()
            println(self.filteredCourse.count)
        }
    }
    
    // MARK: - Table view region
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchCourse.active && self.searchCourse.searchBar.text != "" {
            // dim view alittle if user is not yet entering any keywords.
                return self.filteredCourse.count
            
        } else {
            if self.coursesAddedToTimetable == nil {
                // if there is nothing in it, fetch data from db
                println("fetching data...")
                self.fetchDataAndUpdateSelectedCourses()
            }
            println("count of add : " + "\(self.coursesAddedToTimetable.count)")
            return self.coursesAddedToTimetable.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if searchCourse.active && searchCourse.searchBar.text != "" {
            var cell = tableView.dequeueReusableCellWithIdentifier("ColorgyCourseCardCell", forIndexPath: indexPath) as! ColorgyCourseCardCell

//            cell.name.text = self.filteredCourse[indexPath.row]["name"] as! String
//            cell.teacher.text = self.filteredCourse[indexPath.row]["lecturer"] as! String
//            cell.time.text = self.filteredCourse[indexPath.row]["code"] as! String
//            let s = self.filteredCourse[indexPath.row]["credits"]
//            cell.location.text = "\(s)"
            
            if let name = self.filteredCourse[indexPath.row]["name"] as? String {
                cell.name.text = name
            }
            if let lecturer = self.filteredCourse[indexPath.row]["lecturer"] as? String {
                cell.lecturer.text = lecturer
            }
            if let code = self.filteredCourse[indexPath.row]["code"] as? String {
                cell.code.text = code
            }
            if let credits = self.filteredCourse[indexPath.row]["credits"] as? Int {
                var c = credits
//                cell.credits.text = "\(c)"
            } else {
//                cell.credits.text = "-"
            }
            var text = ""
            for i in 1...9 {
                if let location = self.filteredCourse[indexPath.row]["location_\(i)"] as? String {
                    println("近來惹")
                    if location != "" {
                        text += location + " "
                    }
                }
//                cell.location.text = text
            }
            text = ""
            for i in 1...9 {

                if let period = self.filteredCourse[indexPath.row]["period_\(i)"] as? Int {
//                    text += period + " "
                    if let day = self.filteredCourse[indexPath.row]["day_\(i)"] as? Int {
                        text += self.getPeriodWithDay(day, session: period) + " "
                    }
                }

                cell.period.text = text
            }
            println("早安：\(text)")
            
            if indexPath.row % 2 == 1 {
                cell.lecturerBackgorundView.backgroundColor = self.colorgyDimYellow
                cell.cardBackgroundView.backgroundColor = self.colorgyLightYellow
            } else {
                cell.lecturerBackgorundView.backgroundColor = self.colorgyDimOrange
                cell.cardBackgroundView.backgroundColor = self.colorgyLightOrange
            }
            
            // add tag to button, makes me eaiser to handle button position.
            cell.addButton.tag = indexPath.row
            cell.addButton.addTarget(self, action: "userTapAddCourseButton:", forControlEvents: UIControlEvents.TouchUpInside)
            
            // rotate button here.....
            if !self.isCourseAlreadyAddedToSelectedCourse(cell.code.text!) {
                cell.addButton.transform = CGAffineTransformMakeRotation(0)
            } else {
                let halfQuarter = CGFloat((M_PI * 45.0) / 180.0)
                cell.addButton.transform = CGAffineTransformMakeRotation(halfQuarter)
            }
            
            return cell
        } else {
            // user not searching course
            var cell = tableView.dequeueReusableCellWithIdentifier("ColorgyCourseCardCell", forIndexPath: indexPath) as! ColorgyCourseCardCell
            println("now on \(indexPath.row)")
            if let name = self.coursesAddedToTimetable[indexPath.row][0] as? String {
                cell.name.text = name
            }
            if let code = self.coursesAddedToTimetable[indexPath.row][3] as? String {
                cell.code.text = code
            }
            if let credits = self.coursesAddedToTimetable[indexPath.row][2] as? String {
//                cell.credits.text = credits
            } else {
                cell.credits.text = "-"
            }
            if let lecturer = self.coursesAddedToTimetable[indexPath.row][1] as? String {
                cell.lecturer.text = lecturer
            }
            if let period = self.coursesAddedToTimetable[indexPath.row][4] as? String {
                cell.period.text = period
            }
            if let location = self.coursesAddedToTimetable[indexPath.row][5] as? String {
//                cell.location.text = location
            }
            
            if indexPath.row % 2 == 1 {
                cell.lecturerBackgorundView.backgroundColor = self.colorgyDimYellow
                cell.cardBackgroundView.backgroundColor = self.colorgyLightYellow
            } else {
                cell.lecturerBackgorundView.backgroundColor = self.colorgyDimOrange
                cell.cardBackgroundView.backgroundColor = self.colorgyLightOrange
            }
            
            // add tag to button, makes me eaiser to handle button position.
            cell.addButton.tag = indexPath.row
            cell.addButton.addTarget(self, action: "userTapAddCourseButton:", forControlEvents: UIControlEvents.TouchUpInside)
            
            // rotate button here.....
            if !self.isCourseAlreadyAddedToSelectedCourse(cell.code.text!) {
                cell.addButton.transform = CGAffineTransformMakeRotation(0)
            } else {
                let halfQuarter = CGFloat((M_PI * 45.0) / 180.0)
                cell.addButton.transform = CGAffineTransformMakeRotation(halfQuarter)
            }
            
            return cell
        }
    }
    
    func userTapAddCourseButton(sender: UIButton) {
        
        println("an!")
        println(sender.tag)
        let index = sender.tag
        
        if !self.searchCourse.active {
            // user not searching course.
            println("user not searching")
            println(self.coursesAddedToTimetable[index])
            // user is deleting course
            self.userAttempToDeleteCourseAtIndex(index, warning: false)
        } else {
            println("inside search box")
            println(self.filteredCourse[index])
            // user is searching course
            
            if self.getAddButtonState(sender) == "add" {
                // if user want to add course
                // user searching and attemp to add course
                self.userAttempToAddCourseAtIndex(index, warning: false)
            } else if self.getAddButtonState(sender) == "remove" {
                // if user want to delete course
                self.userAttempToDeleteCourseWhileSearchingAtIndex(index, warning: false)
            }
            
            
        }
        
        // change button state.
        if self.getAddButtonState(sender) == "add" {
            self.animateAddButton(sender, state: "remove")
        } else {
            self.animateAddButton(sender, state: "add")
        }
    }
    
    func getAddButtonState(button: UIButton) -> String? {
        
        if button.transform.a == 1 {
            return "add"
        } else {
            return "remove"
        }
    }
    
    func animateAddButton(button: UIButton, state: String) {
        
        if state == "add" {
            // roll back!
            let halfQuarter = CGFloat((M_PI * 45.0) / 180.0)
            UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.3, options: nil, animations: {
                // make spin and scale first.
                var spin = CGAffineTransformMakeRotation(0)
                var scale = CGAffineTransformMakeScale(1.3, 1.3)
                var trans = CGAffineTransformConcat(scale, spin)
                button.transform = trans
                }, completion: { (isFinished: Bool) -> Void in
                    UIView.animateWithDuration(0.1, animations: {
                        // then make it shrink and stay rotated.
                        var spin = CGAffineTransformMakeRotation(0)
                        var scale = CGAffineTransformMakeScale(1, 1)
                        var trans = CGAffineTransformConcat(scale, spin)
                        button.transform = trans
                        }
                    )
                }
            )
        } else if state == "remove" {
            // 45 degree
            let halfQuarter = CGFloat((M_PI * 45.0) / 180.0)
            UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.3, options: nil, animations: {
                    // make spin and scale first.
                    var spin = CGAffineTransformMakeRotation(halfQuarter)
                    var scale = CGAffineTransformMakeScale(1.3, 1.3)
                    var trans = CGAffineTransformConcat(scale, spin)
                    button.transform = trans
                }, completion: { (isFinished: Bool) -> Void in
                    UIView.animateWithDuration(0.1, animations: {
                            // then make it shrink and stay rotated.
                            var spin = CGAffineTransformMakeRotation(halfQuarter)
                            var scale = CGAffineTransformMakeScale(1, 1)
                            var trans = CGAffineTransformConcat(scale, spin)
                            button.transform = trans
                        }
                    )
                }
            )
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 110
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if self.searchCourse.active {
            println("searching, you tapped \(self.filteredCourse[indexPath.row])")
//            self.userAttempToAddCourseAtIndex(indexPath.row, warning: false)
            
        } else if !self.searchCourse.active {
            println("outside searching, you tapped \(self.coursesAddedToTimetable[indexPath.row])")
//            self.userAttempToDeleteCourseAtIndex(indexPath.row, warning: false)
        }
    }
    
    func userAttempToDeleteCourseAtIndex(index: Int, warning: Bool) {
        
        println("you tap \(index)")
        let name = self.coursesAddedToTimetable[index][0] as! String
        if warning {
            // with warning
            var alert = UIAlertController(title: "刪除課程", message: "確定刪除：" + name + "\n這堂課嗎？", preferredStyle: UIAlertControllerStyle.Alert)
            var ok = UIAlertAction(title: "刪除", style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction!) in
                let uuid = self.coursesAddedToTimetable[index][3] as! String
                self.deleteCourseWithUUID(uuid, reload: true)
            })
            var cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.Default, handler: nil)
            alert.addAction(ok)
            alert.addAction(cancel)
            dispatch_async(dispatch_get_main_queue()) {
                self.presentViewController(alert, animated: true, completion: nil)
            }
        } else {
            // delete without warning
            let uuid = self.coursesAddedToTimetable[index][3] as! String
            self.deleteCourseWithUUID(uuid, reload: true)
        }
        
    }
    
    func userAttempToDeleteCourseWhileSearchingAtIndex(index: Int, warning: Bool) {
        
        println("you tap \(index)")
        if warning {
            // with warning
            let name = self.filteredCourse[index]["name"] as! String
            var alert = UIAlertController(title: "刪除課程", message: "確定刪除：" + name + "\n這堂課嗎？", preferredStyle: UIAlertControllerStyle.Alert)
            var ok = UIAlertAction(title: "刪除", style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction!) in
                let uuid = self.filteredCourse[index]["code"] as! String
                self.deleteCourseWithUUID(uuid, reload: false)
            })
            var cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.Default, handler: nil)
            alert.addAction(ok)
            alert.addAction(cancel)
            dispatch_async(dispatch_get_main_queue()) {
                self.presentViewController(alert, animated: true, completion: nil)
            }
        } else {
            // without warning
            let uuid = self.filteredCourse[index]["code"] as! String
            self.deleteCourseWithUUID(uuid, reload: false)
        }
    }
    
    func userAttempToAddCourseAtIndex(index: Int, warning: Bool) {
        
        // get out all the data, easy to read.
        let name = self.filteredCourse[index]["name"] as? String
        let lecturer = self.filteredCourse[index]["lecturer"] as? String
        var credits = Int32()
        if let c = self.filteredCourse[index]["credits"] as? Int {
            credits = Int32(c)
        } else {
            credits = 0
        }
        let uuid = self.filteredCourse[index]["code"] as? String
        // year, term, id, type
        var year = Int32()
        if let y = self.filteredCourse[index]["year"] as? Int {
            year = Int32(y)
        }
        var term = Int32()
        if let t = self.filteredCourse[index]["term"] as? Int {
            term = Int32(t)
        }
        var id = Int32()
        if let i = self.filteredCourse[index]["id"] as? Int {
            id = Int32(i)
        }
        let type = self.filteredCourse[index]["_type"] as? String
        
        let courseName = (name != nil) ? name! : "未知課程"
        let courseLecturer = (lecturer != nil) ? lecturer! : "-"
        
        
        if warning {
            // with warning
            let optionMenu = UIAlertController(title: "\(courseName)", message: "老師：\(courseLecturer)\n學分：\(credits)", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "加入課程", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction!) -> Void in
                if !self.isCourseAlreadyAddedToSelectedCourse(self.filteredCourse[index]["code"] as! String) {
                    // if this course is not selected...... add it
                    var sessions = NSMutableArray()
                    for i in 1...9 {
                        let day = self.filteredCourse[index]["day_" + "\(i)"]
                        let session = self.filteredCourse[index]["period_" + "\(i)"]
                        let location = self.filteredCourse[index]["location_" + "\(i)"]
                        
                        sessions.addObject(["\(day!!)", "\(session!!)", "\(location!!)"])
                    }
                    println(sessions)
                    self.storeDataToDatabase(name, lecturer: lecturer, credits: credits, uuid: uuid, sessions: sessions, year: year, term: term, id: id, type: type)
                    // user add their course, set coursesAddedToTimetable to nil
                    self.coursesAddedToTimetable = nil
                }
            })
            let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction!) -> Void in
                optionMenu.dismissViewControllerAnimated(true, completion: nil)
            })
            
            optionMenu.addAction(ok)
            optionMenu.addAction(cancel)
            dispatch_async(dispatch_get_main_queue()) {
                self.presentViewController(optionMenu, animated: true, completion: nil)
            }
        } else {
            // no warning
            if !self.isCourseAlreadyAddedToSelectedCourse(self.filteredCourse[index]["code"] as! String) {
                // if this course is not selected...... add it
                var sessions = NSMutableArray()
                for i in 1...9 {
                    let day = self.filteredCourse[index]["day_" + "\(i)"]
                    let session = self.filteredCourse[index]["period_" + "\(i)"]
                    let location = self.filteredCourse[index]["location_" + "\(i)"]
                    
                    sessions.addObject(["\(day!!)", "\(session!!)", "\(location!!)"])
                }
                println(sessions)
                self.storeDataToDatabase(name, lecturer: lecturer, credits: credits, uuid: uuid, sessions: sessions, year: year, term: term, id: id, type: type)
                // user add their course, set coursesAddedToTimetable to nil
                self.coursesAddedToTimetable = nil
            }
        }
    }
    
    //MARK:- get period
    func getPeriodWithDay(day: Int, session: Int) -> String {
        let weekdays = ["Mon", "Tue", "wed", "Thu", "Fri", "Sat", "Sun"]
        var period = ""
        
        // day is from 1~7, need to -1
        // session also
        if day > 0 && day <= 7 && session >= 0 && session <= 15 {
            period = weekdays[day - 1] + String(session - 1)
        }
        
        return period
    }
    // MARK:- test
    func testTOAddAllcourse() {
        for course in self.filteredCourse {
            // get out all the data, easy to read.
            let name = course["name"] as? String
            let lecturer = course["lecturer"] as? String
            var credits = Int32()
            if let c = course["credits"] as? Int {
                credits = Int32(c)
            } else {
                credits = 0
            }
            let uuid = course["code"] as? String
            // year, term, id, type
            var year = Int32()
            if let y = course["year"] as? Int {
                year = Int32(y)
            }
            var term = Int32()
            if let t = course["term"] as? Int {
                term = Int32(t)
            }
            var id = Int32()
            if let i = course["id"] as? Int {
                id = Int32(i)
            }
            let type = course["_type"] as? String
            
            let courseName = (name != nil) ? name! : "未知課程"
            let courseLecturer = (lecturer != nil) ? lecturer! : "-"
            
            if !self.isCourseAlreadyAddedToSelectedCourse(course["code"] as! String) {
                // if this course is not selected...... add it
                var sessions = NSMutableArray()
                for i in 1...9 {
                    let day = course["day_" + "\(i)"]
                    let session = course["period_" + "\(i)"]
                    let location = course["location_" + "\(i)"]
                    
                    sessions.addObject(["\(day!!)", "\(session!!)", "\(location!!)"])
                }
                println(sessions)
                self.storeDataToDatabase(name, lecturer: lecturer, credits: credits, uuid: uuid, sessions: sessions, year: year, term: term, id: id, type: type)
                // user add their course, set coursesAddedToTimetable to nil
                self.coursesAddedToTimetable = nil
            }
        }
        self.tableView.reloadData()
    }
    
    func deleteCourseWithUUID(uuid: String, reload: Bool) {
        var courses = self.getDataFromDatabase()
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext {
            for course in courses! {
                if course.uuid == uuid {
                    managedObjectContext.deleteObject(course)
                    var e: NSError?
                    managedObjectContext.save(&e)
                    if e != nil {
                        println("something wrong while deleting course")
                    }
                    break
                }
            }
        }
        self.coursesAddedToTimetable = nil
        if reload {
            self.tableView.reloadData()
        }
    }
}
