//
//  ColorgyClassmatePersonalPageViewController.swift
//  ColorgyCourse
//
//  Created by David on 2015/7/24.
//  Copyright (c) 2015年 David. All rights reserved.
//

import UIKit

class ColorgyClassmatePersonalPageViewController: UIViewController {
    
    //spinner
    var spinner: UIImageView!
    
    // size
    var profileHeaderViewHeight: CGFloat = 190
    
    // views
    var classmateContentScrollView: UIScrollView!
    var profileHeaderView: UIView!
    var userCoverPhotoImageView: UIImageView!
    var userAvatarImageView: UIImageView!
    var userNameLabel: UILabel!
    var userSchoolLabel: UILabel!
    var userCourses: [UIView]!
    var courseData: [[String]]!
    
    // MARK: - timetableview
    var colorgyTimeTableView: UIView!
    
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
    
    // MARK: - color declaration
    // color region
    var colorgyOrange: UIColor = UIColor(red: 246/255.0, green: 150/255.0, blue: 114/255.0, alpha: 1)
    var colorgyDarkGray: UIColor = UIColor(red: 74/255.0, green: 74/255.0, blue: 74/255.0, alpha: 1)
    var timetableWhite: UIColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    var timetableBackgroundColor: UIColor = UIColor(red: 239/255.0, green: 238/255.0, blue: 238/255.0, alpha: 1)
    var colorgyBackgroundColor: UIColor = UIColor(red: 239/255.0, green: 238/255.0, blue: 238/255.0, alpha: 1)
    var timetableLineColor: UIColor = UIColor(red: 216/255.0, green: 216/255.0, blue: 216/255.0, alpha: 1)
    
    // MARK: - get data from segue
    var classmateId: Int!
    
    func setupClassmateId(id: Int) {
        
        self.classmateId = id
    }
    
    // MARK: - push segue
    var pushCourseCode: String!
    
    // preload data
    func preloadData() {
        
        // timetable require
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
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        println(self.classmateId)
        self.view.backgroundColor = self.timetableBackgroundColor
        // add spinner
        self.setupSpinner()
        self.spinner.center = self.view.center
        self.view.addSubview(self.spinner)
        self.animateSpinner()
        
        
        
        // set back button to no string
        var backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton
        
        // never adjust this for me.....fuck
        // this is very important line!
        self.automaticallyAdjustsScrollViewInsets = true
        
        self.preloadData()
        
        // generate timetable scrollview
        self.colorgyTimeTableView?.removeFromSuperview()
        self.colorgyTimeTableView = self.ColorgyTimeTableView()
        // header
        self.profileHeaderView = self.DetailHeaderView()!
        
        // move to header's bottom
        self.colorgyTimeTableView.frame.origin.y = self.profileHeaderView.frame.height + 26
        println(self.colorgyTimeTableView.frame.origin.y)
        
        self.classmateContentScrollView = UIScrollView(frame: self.view.frame)
        self.classmateContentScrollView.contentInset.top = 64
        self.classmateContentScrollView.contentInset.bottom = 49
        self.classmateContentScrollView.contentSize = CGSizeMake(self.view.frame.width, self.profileHeaderView.frame.height + 26 + self.colorgyTimeTableView.frame.height)
        
        self.classmateContentScrollView.addSubview(self.profileHeaderView)
        self.classmateContentScrollView.addSubview(self.colorgyTimeTableView)
        
        self.view.addSubview(self.classmateContentScrollView)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        dispatch_async(dispatch_get_main_queue()) {
            var userImage = self.getUserAvatarWithUserId("\(self.classmateId)")
            if userImage.avatar != nil {
                self.userAvatarImageView.image = userImage.avatar
            }
            if userImage.coverPhoto != nil {
                self.userCoverPhotoImageView.image = userImage.coverPhoto
            }
            
            var transition = CATransition()
            transition.duration = 0.4
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionFade
            self.userAvatarImageView.layer.addAnimation(transition, forKey: nil)
            self.userNameLabel.layer.addAnimation(transition, forKey: nil)
            
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            var name = self.getUserNameWithUserId("\(self.classmateId)")
            if name != nil {
                self.userNameLabel.text = name!
            }
            var transition = CATransition()
            transition.duration = 0.4
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionFade
            self.userNameLabel.layer.addAnimation(transition, forKey: nil)
        }
        
        self.getUserCourseDataWithUserId("\(self.classmateId)")
        
        self.stopAnimatingAndRemoveSpinner()
    }
    
    // MARK: - timetable grid view and content view
    func ColorgyTimeTableView() -> UIView {
        
        // set its bounds
        var height = self.colorgyTimeTableCell.height * 15 + self.timetableSpacing * 2 + self.headerHeight
        var view = UIView(frame: CGRectMake(0, 0, self.screenWidth, height))
        // background color of timetable
        view.backgroundColor = self.timetableBackgroundColor
        
        // add grid view
        view.addSubview(self.ColorgyTimeTableColumnView())
        view.addSubview(self.ColorgyTimeTableRowSessionView("morning"))
        view.addSubview(self.ColorgyTimeTableRowSessionView("afternoon"))
        view.addSubview(self.ColorgyTimeTableRowSessionView("night"))
        view.addSubview(self.ColorgyTimeTableColumnSeperatorLine(view))
        
        return view as UIView
    }
    
    func ColorgyTimeTableColumnSeperatorLine(view: UIView) -> UIView {
        
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
    
    // MARK: - header view
    func DetailHeaderView() -> UIView? {
        
        var detailHeaderView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.profileHeaderViewHeight))
        detailHeaderView.backgroundColor = UIColor.grayColor()
        detailHeaderView.layer.cornerRadius = 5
        // grow back the radius
        detailHeaderView.frame.size.height += detailHeaderView.layer.cornerRadius
        self.userCoverPhotoImageView = detailHeaderView
        self.userCoverPhotoImageView.layer.masksToBounds = true
        self.userCoverPhotoImageView.contentMode = UIViewContentMode.ScaleAspectFill
        
        // dim view on cover
        var dim = UIView(frame: self.userCoverPhotoImageView.frame)
        dim.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        self.userCoverPhotoImageView.addSubview(dim)
        
//        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark)) as UIVisualEffectView
//        visualEffectView.frame = self.userCoverPhotoImageView.bounds
//        self.userCoverPhotoImageView.addSubview(visualEffectView)
        
        var leftSpacing: CGFloat = 29
        // user contents
        // avatar
        self.userAvatarImageView = UIImageView(frame: CGRectMake(0, 0, 85, 85))
        self.userAvatarImageView.layer.borderColor = UIColor.whiteColor().CGColor
        self.userAvatarImageView.layer.borderWidth = 5
        self.userAvatarImageView.layer.cornerRadius = self.userAvatarImageView.frame.width / 2
        self.userAvatarImageView.layer.masksToBounds = true
        
        // name label
        var nameFontSize: CGFloat = 19
        self.userNameLabel = UILabel(frame: CGRectMake(0, 0, self.view.frame.width - self.userAvatarImageView.frame.width - leftSpacing, nameFontSize))
        self.userNameLabel.font = UIFont(name: "STHeitiTC-Medium", size: nameFontSize)
        self.userNameLabel.textColor = UIColor.whiteColor()
        
        // school label
        var schoolFontSize: CGFloat = 11
        self.userSchoolLabel = UILabel(frame: CGRectMake(0, 0, self.view.frame.width - self.userAvatarImageView.frame.width - leftSpacing, schoolFontSize))
        self.userSchoolLabel.font = UIFont(name: "STHeitiTC-Medium", size: schoolFontSize)
        self.userSchoolLabel.textColor = UIColor.whiteColor()
        
        // position name, shcool, avatar
        self.userAvatarImageView.frame.origin.x = leftSpacing
        self.userAvatarImageView.frame.origin.y = self.profileHeaderViewHeight - leftSpacing - self.userAvatarImageView.frame.height
        // name to avatar's right
        self.userNameLabel.center.y = self.userAvatarImageView.center.y
        var labelAvatarSpacing: CGFloat = 13
        self.userNameLabel.frame.origin.x = self.userAvatarImageView.frame.width + leftSpacing + labelAvatarSpacing
        // school to name's top
        self.userSchoolLabel.center = self.userNameLabel.center
        var topSpacing: CGFloat = 6
        self.userSchoolLabel.center.y -= (self.userSchoolLabel.frame.height + self.userNameLabel.frame.height) / 2 + topSpacing
        
        // add views
        detailHeaderView.addSubview(self.userAvatarImageView)
        detailHeaderView.addSubview(self.userNameLabel)
        detailHeaderView.addSubview(self.userSchoolLabel)
        
        var headerMask = UIView(frame: detailHeaderView.frame)
        headerMask.frame.size.height -= detailHeaderView.layer.cornerRadius
        //        headerMask.frame.origin.y = (detailHeaderView.layer.cornerRadius)
        //        headerMask.backgroundColor = UIColor.blueColor()
        headerMask.addSubview(detailHeaderView)
        detailHeaderView.frame.origin.y -= detailHeaderView.layer.cornerRadius
        headerMask.layer.masksToBounds = true
        
        return headerMask
        //        return detailHeaderView
    }
    
    //MARK: - spinner
    func setupSpinner() {
        
        self.spinner = UIImageView(image: UIImage(named: "spinner"))
    }
    
    func animateSpinner() {
        
        var rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = 2 * M_PI
        rotationAnimation.duration = 3
        rotationAnimation.cumulative = true
        rotationAnimation.repeatCount = 200
        
        self.spinner.layer.addAnimation(rotationAnimation, forKey: "rotationAnimation")
    }
    
    func stopAnimatingAndRemoveSpinner() {
        
        self.spinner.layer.removeAllAnimations()
        self.spinner.removeFromSuperview()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - add course cell region
    func courseCellMake(courseName: String, location: String, day: Int, session: Int) -> UIView? {
        
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
    
    func refreshTimeTable() {
        
        println("refredshing😡 \(self.userCourses.count)")
        if self.userCourses != nil {
            for cell in self.userCourses! {
                println(self.colorgyTimeTableView)
                cell.backgroundColor = UIColor.brownColor()
                self.colorgyTimeTableView.addSubview(cell)
                
                // ges
                let tap = UITapGestureRecognizer()
                tap.numberOfTouchesRequired = 1
                tap.addTarget(self, action: "tapOnCourseCellView:")
                cell.addGestureRecognizer(tap)
                
                // animation
                cell.alpha = 0
                UIView.animateWithDuration(0.4, animations: {
                    cell.alpha = 1
                })
            }
        }
    }
    
    func tapOnCourseCellView(gesture: UITapGestureRecognizer) {
        println("tapppp")
        println(gesture.view?.frame)
        let position = self.getCoursePositionOnTimetable(gesture.view?.center)

        println(gesture.view?.subviews[0])
        if let label = gesture.view?.subviews[0] as? UILabel {
            let code = self.getCourseCodeWithCourseName(label.text!)
            println(code)
            if code != nil {
                self.pushCourseCode = code!
                self.performSegueWithIdentifier("classmateToCourseDetail", sender: self)
            }
        }
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
    
    func getCourseCodeWithCourseName(name: String) -> String? {
        
        for array in self.courseData {
            let nn = array[0]
            if nn == name {
                // match!
                return array[1]
            }
        }
        
        return nil
    }
        
//        return nil

    // MARK: - server
    func getUserCourseDataWithUserId(userId: String) {
        
        let ud = NSUserDefaults.standardUserDefaults()
        let afManager = AFHTTPSessionManager(baseURL: NSURL(string: "https://colorgy.io/oauth/token"))
        // get user name and  school
        let access_token = ud.objectForKey("ColorgyAccessToken") as! String
        
        var url = "https://colorgy.io:443/api/v1/user_courses.json?filter%5Buser_id%5D=" + userId + "&&&&&&&&&&access_token=" + access_token
        println(url)
       
        
        afManager.GET(url, parameters: nil, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) in
            
            // unpack response object using JSON
            let json = JSON(responseObject)
            println("😆")
            
            //init courses container
            self.userCourses = [UIView]()
            self.courseData = [[String]]()
            
            for (key: String, value: JSON) in json {
                println(key)
                println(value)
                let code = value["course_code"].string
                let json = self.getCourseInfoWithCourseCode(code!)
                if json != nil {
                    let name = json!["name"].string!
                    // save course code for further usage
                    self.courseData.append([name, json!["code"].string!])
                    // need handle course
                    if let day_1 = json!["day_1"].int {
                        if let period_1 = json!["period_1"].int {
                            if let location_1 = json!["location_1"].string {
                                if let cell = self.courseCellMake(name, location: location_1, day: day_1, session: period_1) {
                                    self.userCourses.append(cell)
                                }
                            }
                        }
                    }
                    if let day_2 = json!["day_2"].int {
                        if let period_2 = json!["period_2"].int {
                            if let location_2 = json!["location_2"].string {
                                if let cell = self.courseCellMake(name, location: location_2, day: day_2, session: period_2) {
                                    self.userCourses.append(cell)
                                }
                            }
                        }
                    }
                    if let day_3 = json!["day_3"].int {
                        if let period_3 = json!["period_3"].int {
                            if let location_3 = json!["location_3"].string {
                                if let cell = self.courseCellMake(name, location: location_3, day: day_3, session: period_3) {
                                    self.userCourses.append(cell)
                                }
                            }
                        }
                    }
                    if let day_4 = json!["day_4"].int {
                        if let period_4 = json!["period_4"].int {
                            if let location_4 = json!["location_4"].string {
                                if let cell = self.courseCellMake(name, location: location_4, day: day_4, session: period_4) {
                                    self.userCourses.append(cell)
                                }
                            }
                        }
                    }
                    if let day_5 = json!["day_5"].int {
                        if let period_5 = json!["period_5"].int {
                            if let location_5 = json!["location_5"].string {
                                if let cell = self.courseCellMake(name, location: location_5, day: day_5, session: period_5) {
                                    self.userCourses.append(cell)
                                }
                            }
                        }
                    }
                    if let day_6 = json!["day_6"].int {
                        if let period_6 = json!["period_6"].int {
                            if let location_6 = json!["location_6"].string {
                                if let cell = self.courseCellMake(name, location: location_6, day: day_6, session: period_6) {
                                    self.userCourses.append(cell)
                                }
                            }
                        }
                    }
                    if let day_7 = json!["day_7"].int {
                        if let period_7 = json!["period_7"].int {
                            if let location_7 = json!["location_7"].string {
                                if let cell = self.courseCellMake(name, location: location_7, day: day_7, session: period_7) {
                                    self.userCourses.append(cell)
                                }
                            }
                        }
                    }
                    if let day_8 = json!["day_8"].int {
                        if let period_8 = json!["period_8"].int {
                            if let location_8 = json!["location_8"].string {
                                if let cell = self.courseCellMake(name, location: location_8, day: day_8, session: period_8) {
                                    self.userCourses.append(cell)
                                }
                            }
                        }
                    }
                    if let day_9 = json!["day_9"].int {
                        if let period_9 = json!["period_9"].int {
                            if let location_9 = json!["location_9"].string {
                                if let cell = self.courseCellMake(name, location: location_9, day: day_9, session: period_9) {
                                    self.userCourses.append(cell)
                                }
                            }
                        }
                    }

                }
            }
            
            println("😆😆😆😆😆😆😆😆")
            println(self.userCourses)
            // put these onto timetable
            self.refreshTimeTable()
            
            }, failure: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) in
                // TODO: 處理錯誤GET
                println("error \(responseObject)")
        })
    }
    
    func getCourseInfoWithCourseCode(courseCode: String) -> JSON? {
        
        let ud = NSUserDefaults.standardUserDefaults()
        // get user name and  school
        let access_token = ud.objectForKey("ColorgyAccessToken") as! String
        let userSchool = ud.objectForKey("userSchool") as! String
        
        var url = "https://colorgy.io:443/api/v1/" + userSchool.lowercaseString + "/courses/" + courseCode + ".json?access_token=" + access_token
        println(url)
        // first, init a request using url.
        var req = NSURLRequest(URL: NSURL(string: url)!)
        // then you need a response type as follow.
        var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        // get response data back
        var responseData = NSURLConnection.sendSynchronousRequest(req, returningResponse: response, error: nil)
        
        //        println(responseData)
        var err: NSError?
        // need to check if data truly comes back.
        // or json serialization will fail.
        if responseData != nil {
            // FIXME: 強制拆有危險
            var jsonResult: NSDictionary = (NSJSONSerialization.JSONObjectWithData(responseData!, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary)!
            
            // if successfully serialize this data, use JSON to unpack it.
            if let responseObject = responseData {
               let json = JSON(jsonResult)
                return json
            }
            
        }
        
        return nil
    }
    
    func getUserNameWithUserId(userId: String) -> String? {
        
        let ud = NSUserDefaults.standardUserDefaults()
        // get user name and  school
        let afManager = AFHTTPSessionManager(baseURL: NSURL(string: "https://colorgy.io/oauth/token"))
        let access_token = ud.objectForKey("ColorgyAccessToken") as! String
        
        var url = "https://colorgy.io:443/api/v1/users/" + userId + ".json?access_token=" + access_token
        println(url)
        // first, init a request using url.
        var req = NSURLRequest(URL: NSURL(string: url)!)
        // then you need a response type as follow.
        var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        // get response data back
        var responseData = NSURLConnection.sendSynchronousRequest(req, returningResponse: response, error: nil)
        
        //        println(responseData)
        var err: NSError?
        // need to check if data truly comes back.
        // or json serialization will fail.
        if responseData != nil {
            // FIXME: 強制拆有危險
            var jsonResult: NSDictionary = (NSJSONSerialization.JSONObjectWithData(responseData!, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary)!
            
            // if successfully serialize this data, use JSON to unpack it.
            if let responseObject = responseData {
                println("user info")
                println(responseObject)
                let json = JSON(jsonResult)
                
                var name: String?
                if let n = json["name"].string {
                    name = n
                }
                return name
                
            }
        }
        
        return nil
    }
    
    func getUserAvatarWithUserId(userId: String) -> (avatar: UIImage?, coverPhoto: UIImage?) {
        
        // i dont use AFNetworking here.
        // i dont want async here.
        let ud = NSUserDefaults.standardUserDefaults()
        // get user name and  school
        let afManager = AFHTTPSessionManager(baseURL: NSURL(string: "https://colorgy.io/oauth/token"))
        let access_token = ud.objectForKey("ColorgyAccessToken") as! String
        
        var image: UIImage?
        
        var url = "https://colorgy.io:443/api/v1/users/" + userId + ".json?access_token=" + access_token
        println(url)
        // first, init a request using url.
        var req = NSURLRequest(URL: NSURL(string: url)!)
        // then you need a response type as follow.
        var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        // get response data back
        var responseData = NSURLConnection.sendSynchronousRequest(req, returningResponse: response, error: nil)
        
        //        println(responseData)
        var err: NSError?
        // need to check if data truly comes back.
        // or json serialization will fail.
        if responseData != nil {
            // FIXME: 強制拆有危險
            var jsonResult: NSDictionary = (NSJSONSerialization.JSONObjectWithData(responseData!, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary)!
            
            // if successfully serialize this data, use JSON to unpack it.
            if let responseObject = responseData {
                let json = JSON(jsonResult)
                println(json)
                // get out user's avatar and cover photo url.
                let avatarUrl = json["avatar_url"].string
                let coverPhotoUrl = json["cover_photo_url"].string
                var avatarImage: UIImage?
                var coverPhoto: UIImage?
                
                if avatarUrl != nil {
                    if let data = NSData(contentsOfURL: NSURL(string: avatarUrl!)!) {
                        avatarImage = UIImage(data: data)
                    }
                }
                
                if coverPhotoUrl != nil {
                    if let data = NSData(contentsOfURL: NSURL(string: coverPhotoUrl!)!) {
                        coverPhoto = UIImage(data: data)
                    }
                }
                
                return (avatarImage, coverPhoto)
            }
        }
        
        
        return (nil, nil)
    }
    
    // MARK: - puss segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "classmateToCourseDetail" {
            
            var vc = segue.destinationViewController as! ColorgyCourseDetailPageViewController
            vc.pushWithCourseCode(self.pushCourseCode)
            
        }
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
