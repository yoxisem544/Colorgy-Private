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
    
    // MARK: - color declaration
    // color region
    var colorgyOrange: UIColor = UIColor(red: 246/255.0, green: 150/255.0, blue: 114/255.0, alpha: 1)
    var colorgyDarkGray: UIColor = UIColor(red: 74/255.0, green: 74/255.0, blue: 74/255.0, alpha: 1)
    var timetableWhite: UIColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
    
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
            }, failure: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) in
                println("error!!!")
                var res = task.response as! NSHTTPURLResponse
                
                println(res.statusCode)
            })
    }
    
    // MARK: - view
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
        
        self.colorgyTimeTableView = self.ColorgyTimeTableView()
        self.view.addSubview(self.colorgyTimeTableView)
        
        // style of nav bar
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationItem.title = "課表"
        
        println("=====================")
        self.detectIfClassHasConflicts()
        println("testREFRESH!")
//        self.refreshAccessToken()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - handle conflict courses
    func detectIfClassHasConflicts() {
        
        if self.coursesOnTimetable.count == 0 {
            println("count is 0, no conflicts.")
        } else {
            self.getConflictTimetable()
            self.animateConflictCourses()
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
            let position = self.getCoursePositionOnTimetable(course.center)!
            conflictTimetable[position.day - 1][position.session - 1].addObject(course)
        }
        
        self.conflictCourses = conflictTimetable
    }
    
    func getCoursePositionOnTimetable(point: CGPoint?) -> (day: Int, session: Int)? {
        
        if point != nil {
            var day = Int((point!.x - self.timetableSpacing - self.sideBarWidth - self.colorgyTimeTableCell.width / 2) / self.colorgyTimeTableCell.width) + 1
            var session = Int((point!.y - self.timetableSpacing - self.headerHeight - self.colorgyTimeTableCell.width / 2) / self.colorgyTimeTableCell.height) + 1
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
                                }, completion: nil)
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
        view.backgroundColor = self.colorgyDarkGray
        
        // set timetable scrollview's content size
        // width matches device width
        // height is headerBarHeight and coursescount height and some spacing
        view.contentSize = CGSizeMake(self.screenWidth, self.headerHeight + self.colorgyTimeTableCell.height * CGFloat(self.courseCount) + CGFloat(2) * self.timetableSpacing)
        
        // add grid view
        view.addSubview(self.ColorgyTimeTableColumnView())
        view.addSubview(self.ColorgyTimeTableRowSessionView("morning"))
        view.addSubview(self.ColorgyTimeTableRowSessionView("afternoon"))
        view.addSubview(self.ColorgyTimeTableRowSessionView("night"))
        
        // add course here
//        view.addSubview(self.CourseViewAtDay(1, session: "A"))
//        view.addSubview(self.CourseViewAtDay(2, session: "2"))
        
        // update timetableview
        // this will return array of uiviews
        // before track courses position, init courseOnTimetable first
        self.coursesOnTimetable = NSMutableArray()
        // prepare gesture
        if let views = self.updateTimetableCourse() {
            for v in views {
                let tap = UITapGestureRecognizer()
                tap.numberOfTouchesRequired = 1
                tap.addTarget(self, action: "tapOnCourseCellView:")
                v.addGestureRecognizer(tap)
                view.addSubview(v)
                coursesOnTimetable.addObject(v)
            }
        }
        
        
        return view as UIScrollView
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
        var title = "好"
        if courses.count > 1 {
            title = "幹選那麼多是要死喔？"
        }
        for course in courses {
            let c = course as! UIView
            println(c.subviews)
            for subview in c.subviews {
                if subview.isKindOfClass(UILabel) {
                    let label = subview as! UILabel
                    message += "課程名稱：" + label.text! + "\n"
                }
            }
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "好", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func ColorgyTimeTableColumnView() -> UIView {
        // this view is vertical view
        // this is days from mon to fri
        var view = UIView(frame: CGRectMake(self.timetableSpacing + self.sideBarWidth, 0.0 + self.timetableSpacing, self.colorgyTimeTableCell.width * 5, self.headerHeight + self.colorgyTimeTableCell.height * CGFloat(self.courseCount)))
        println(view.frame)
        println(self.colorgyTimeTableCell.height)
        view.backgroundColor = self.timetableWhite
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.whiteColor().CGColor
        view.layer.cornerRadius = 10
        
        // vertical line in this view, to seperate days
        for day in 1...4 {
            var line = UIView(frame: CGRectMake(0, 0, 1, self.headerHeight + self.colorgyTimeTableCell.height * CGFloat(self.courseCount)))
            line.backgroundColor = UIColor.whiteColor()
            
            line.center.x = self.colorgyTimeTableCell.width * CGFloat(day)
            
            view.addSubview(line)
        }
        
        // add day label
        for day in 1...5 {
            var label = UILabel(frame: CGRectMake(0, 0, self.headerWidth, self.headerHeight))
            label.textAlignment = NSTextAlignment.Center
            label.center.y = self.headerHeight / 2
            label.textColor = UIColor.whiteColor()
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
        view.layer.borderColor = UIColor.whiteColor().CGColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 6
        
        // add lines to it
        for i in 1...Int(courses - 1) {
            var line = UIView(frame: CGRectMake(0, 0, self.sideBarWidth + self.colorgyTimeTableCell.width * CGFloat(5), 1))
            line.backgroundColor = UIColor.whiteColor()
            
            line.center.y = self.colorgyTimeTableCell.height * CGFloat(i)
            view.addSubview(line)
        }
        
        switch time {
            case "morning":
                for i in 1...Int(courses) {
                    var label = UILabel(frame: CGRectMake(0, 0, self.sideBarWidth, self.sideBarWidth))
                    label.text = "\(i-1)"
                    label.center.y = self.colorgyTimeTableCell.height * CGFloat(i) - self.colorgyTimeTableCell.height / 2
                    // problem here!!!!
                    label.center.x = self.sideBarWidth / 2
                    label.textColor = UIColor.whiteColor()
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
                    label.textColor = UIColor.whiteColor()
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
                    label.textColor = UIColor.whiteColor()
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
        var label = UILabel(frame: CGRectMake(0, 0, self.colorgyTimeTableCell.width - 1, self.colorgyTimeTableCell.height - 1))
        
        view.layer.cornerRadius = 5
        
        label.text = courseName + "\n" + location
        label.font = UIFont(name: "Heiti TC", size: 13)
        label.textAlignment = NSTextAlignment.Center
        label.numberOfLines = 2
        label.textColor = UIColor.whiteColor()
        
        view.addSubview(label)
        
        var x = self.timetableSpacing + self.sideBarWidth - self.colorgyTimeTableCell.width / 2 + CGFloat(day) * self.colorgyTimeTableCell.width
        var y = self.timetableSpacing + self.headerHeight - self.colorgyTimeTableCell.width / 2 + CGFloat(session) * self.colorgyTimeTableCell.width
        
        view.center = CGPointMake(x, y)
        
        
        if day < 6 {
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
