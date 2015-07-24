//
//  ColorgyCourseDetailPageViewController.swift
//  ColorgyCourse
//
//  Created by David on 2015/7/19.
//  Copyright (c) 2015年 David. All rights reserved.
//

import UIKit
//import SwiftyJSON

class ColorgyCourseDetailPageViewController: UIViewController {
    
    let headerViewHeight: CGFloat = 190
    let lowerLeftContentSpacing: CGFloat = 28
    let lecturerNameFontSize: CGFloat = 13
    let courseNameFontSize: CGFloat = 36
    let detailInformationContainerViewSpacing: CGFloat = 15
    let detailInformationContentCellHeight: CGFloat = 41
    let headerAndDetailInformationSpacing: CGFloat = 23
    // this is content card spacing
    let contentSpacing: CGFloat = 13
    
    // MARK: - color
    let colorgyDimOrange: UIColor = UIColor(red: 226/255.0, green: 109/255.0, blue: 90/255.0, alpha: 1)
    let colorgyLightOrange: UIColor = UIColor(red: 248/255.0, green: 150/255.0, blue: 128/255.0, alpha: 1)
    var colorgyDarkGray = UIColor(red: 74/255.0, green: 74/255.0, blue: 74/255.0, alpha: 1)
    var timetableLineColor: UIColor = UIColor(red: 216/255.0, green: 216/255.0, blue: 216/255.0, alpha: 1)
    // detail information 的 內容字的顏色
    var colorgyGray = UIColor(red: 113/255.0, green: 112/255.0, blue: 113/255.0, alpha: 1)
    // background color
    var timetableBackgroundColor: UIColor = UIColor(red: 250/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1)
    
    var colorgyLightYellow: UIColor = UIColor(red: 244/255.0, green: 188/255.0, blue: 94/255.0, alpha: 1)
    
    
    // MARK: - data from push segue
    // get code from root view, display information using this code.
    var courseCode: String!
    
    var indexTappedOnClassmate: Int!
    
    func pushWithCourseCode(code: String) {
        println("course code set!😁")
        self.courseCode = code
    }
    
    // access to every view
    // colorgyDetailContentView --> a scroll view contains all of the contents.
    var colorgyDetailContentView: UIScrollView!
    // detailHeaderView --> a view contains title, lecturer, and credits.
    var detailHeaderView: UIView!
    // detailInformationView --> contains things like location: TR312
    // feed array [title: String, content: String], it will auto generate for you.
    var detailInformationView: UIView!
    // classmatesView --> contains classmates who choose this course
    var classmatesView: UIView!
    
    // view contents
    var classmatesData: NSMutableArray!
    var name: String!
    var lecturer: String!
    var detailContents: NSMutableArray!
    
    //spinner
    var spinner: UIImageView!
    
    // MARK: - view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupSpinner()
        self.spinner.center = self.view.center
        self.view.addSubview(self.spinner)
        self.animateSpinner()

        self.getCourseInformationFromServer()
        
        // never adjust this for me.....fuck
        // this is very important line!
        self.automaticallyAdjustsScrollViewInsets = false
        
//        self.testData()
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
    
    // call this function after you get:
    // self.classmatesData --> you need this to generate classmates view.
    func setupDetailContentViews() {
        
        // set nav title
        self.navigationItem.title = self.name
        
        // Do any additional setup after loading the view.
        println("you are now in detail view")
        
        // init this view --> scrollview
        self.colorgyDetailContentView = self.DetailContentView()
        
        // add detail header card
        self.detailHeaderView = self.DetailHeaderView(self.name, lecturer: self.lecturer)!
        self.colorgyDetailContentView.addSubview(self.detailHeaderView)
        // Inset to top
        self.colorgyDetailContentView.contentInset.top = 64
        self.colorgyDetailContentView.contentOffset.y = -64
//        self.colorgyDetailContentView.contentOffset.y = 64
        
        // content
        var content = NSMutableArray()
        content.addObject(["地點", "San Francisco"])
        content.addObject(["日期", "Oct 10"])
        content.addObject(["代碼", "A1234567890"])

        println(self.courseCode)
        // add detail information
        self.detailInformationView = self.DetailInformationContainerViewWithContent(self.detailContents)
        // move information view to header view's bottom
        // set position
        self.detailInformationView.center.x = self.detailHeaderView.center.x
        self.detailInformationView.frame.origin.y = self.detailHeaderView.frame.height + self.headerAndDetailInformationSpacing
        self.colorgyDetailContentView.addSubview(self.detailInformationView)
        
        // TODO: 用一個view把buttons包起來
        // buttons
        var button = self.pushButtonWithTitle("課程評論", selector: "yo")!
        // set position to header view's bottom
        button.center.x = self.detailHeaderView.center.x
        button.frame.origin.y = self.detailInformationView.frame.origin.y + self.detailInformationView.frame.height + self.contentSpacing
        self.colorgyDetailContentView.addSubview(button)
        
        // classmates, contains classmates' profile photo
        self.classmatesView = self.MyClassmatesViewWithClassmates(self.classmatesData)
        self.classmatesView.center.x = self.detailHeaderView.center.x
        self.classmatesView.frame.origin.y = button.frame.origin.y + button.frame.height + self.contentSpacing
        self.colorgyDetailContentView.addSubview(self.classmatesView)
        
        self.view.addSubview(self.colorgyDetailContentView)
        
        self.view.backgroundColor = self.timetableBackgroundColor
    }
    
    // MARK: - server communication
    // download data from server
    func getCourseInformationFromServer() {
        
        
        let ud = NSUserDefaults.standardUserDefaults()
        // get user name and  school
        let afManager = AFHTTPSessionManager(baseURL: NSURL(string: "https://colorgy.io/oauth/token"))
        let access_token = ud.objectForKey("ColorgyAccessToken") as! String
        let userSchool = ud.objectForKey("userSchool") as! String
        let course = self.courseCode
        
        // get classmate user id, in order to get photo
        // generate array like [id, url, uiimage]
        // but now i only use id....
        
        afManager.GET("https://colorgy.io:443/api/v1/" + userSchool.lowercaseString + "/courses/" + course + ".json?access_token=" + access_token, parameters: nil, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) in
            
            // unpack response object using JSON
            let json = JSON(responseObject)
            // need lecturer and course name, get it out
            let name = json["name"].string
            let lecturer = json["lecturer"].string
            println("n  \(name), l \(lecturer)")
            // TODO: 增加詳細資料陣列
            self.name = (name != nil) ? name : ""
            self.lecturer = (lecturer != nil) ? lecturer : ""
            
            // init detailContents
            // FIXME: nil handling....!!1important
            self.detailContents = NSMutableArray()
            let credits = json["credits"].int
            let general_code = json["general_code"].string
            let school = json[""]
            let location = self.getLocationWithCourseJSON(json)
            
            println("😀")
            println()
            
            self.detailContents.addObject(["學分", "\(credits!)"])
            self.detailContents.addObject(["代碼", general_code!])
            self.detailContents.addObject(["上課教室", location])
            self.detailContents.addObject(["時間", ""])


            
            self.getLocationWithCourseJSON(json)
            
            // after getting course information, get classmates
            // never call this before you get lecturer? not sure heehee.
            self.getClassmatesFromServer()
            
            
            }, failure: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) in
                // TODO: 處理錯誤GET
                println("error \(responseObject)")
        })
    }
    
    // MARK: - handle location, period
    func getLocationWithCourseJSON(json: JSON) -> String {
        
        var locations = [String]()
        
        if let location_1 = json["location_1"].string {
            if !self.isLocationRepeatInArray(locations, location: location_1) {
                // not repeated
                locations.append(location_1)
            }
        }
        if let location_2 = json["location_2"].string {
            if !self.isLocationRepeatInArray(locations, location: location_2) {
                // not repeated
                locations.append(location_2)
            }
        }
        if let location_3 = json["location_3"].string {
            if !self.isLocationRepeatInArray(locations, location: location_3) {
                // not repeated
                locations.append(location_3)
            }
        }
        if let location_4 = json["location_4"].string {
            if !self.isLocationRepeatInArray(locations, location: location_4) {
                // not repeated
                locations.append(location_4)
            }
        }
        if let location_5 = json["location_5"].string {
            if !self.isLocationRepeatInArray(locations, location: location_5) {
                // not repeated
                locations.append(location_5)
            }
        }
        if let location_6 = json["location_6"].string {
            if !self.isLocationRepeatInArray(locations, location: location_6) {
                // not repeated
                locations.append(location_6)
            }
        }
        if let location_7 = json["location_7"].string {
            if !self.isLocationRepeatInArray(locations, location: location_7) {
                // not repeated
                locations.append(location_7)
            }
        }
        if let location_8 = json["location_8"].string {
            if !self.isLocationRepeatInArray(locations, location: location_8) {
                // not repeated
                locations.append(location_8)
            }
        }
        if let location_9 = json["location_9"].string {
            if !self.isLocationRepeatInArray(locations, location: location_9) {
                // not repeated
                locations.append(location_9)
            }
        }

        var locationString = ""

        for (index: Int, value: String) in enumerate(locations) {
            locationString += value
            if index != (locations.count - 1) {
                locationString += " "
            }
        }
        
        return locationString
    }
    
    func isLocationRepeatInArray(array: [String], location: String) -> Bool {
        
        if array.count == 0 {
            return false
        } else {
            for loca in array {
                if loca == location {
                    return true
                }
            }
            
            return false
        }
    }
    
    // this function will get called after getting classmates' data
    func getClassmatesFromServer() {
        
        let ud = NSUserDefaults.standardUserDefaults()
        // get user name and  school
        let afManager = AFHTTPSessionManager(baseURL: NSURL(string: "https://colorgy.io/oauth/token"))
        let access_token = ud.objectForKey("ColorgyAccessToken") as! String
        let course = self.courseCode
        afManager.GET("https://colorgy.io:443/api/v1/user_courses.json?filter%5Bcourse_code%5D=" + course + "&access_token=" + access_token, parameters: nil, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) in
            
            // first, init self.classmatesData as NSMutableArray
            self.classmatesData = NSMutableArray()
//            println(responseObject)
            // this response object is a array. 是陣列
            let json = JSON(responseObject)
            println("count of json is \(json.count)")
            // check subscript of JSON, need enumarate.......
            for (key: String, classmate: JSON) in json {
                println(classmate["user_id"])
                let id = classmate["user_id"].double
                var object = NSMutableArray()
                // id must not be nil. If nil, then skip it
                if id != nil {
                    self.classmatesData.addObject(id!)
                }
            }
            
            // after getting classmates, setup views
            // DO NOT CALL THIS along!
            // this function depends on classmatesData. and lecturer, name.
            self.setupDetailContentViews()
            // after setup, stop spinner
            self.stopAnimatingAndRemoveSpinner()
            
            
            }, failure: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) in
                // TODO: 處理錯誤GET
                println("error \(responseObject)")
        })
    }
    
    func getUserAvatarWithUserId(userId: String) -> UIImage? {
        
        // i dont use AFNetworking here.
        // i dont want async here.
        let ud = NSUserDefaults.standardUserDefaults()
        // get user name and  school
        let afManager = AFHTTPSessionManager(baseURL: NSURL(string: "https://colorgy.io/oauth/token"))
        let access_token = ud.objectForKey("ColorgyAccessToken") as! String
        let course = self.courseCode
        
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
            var jsonResult: NSDictionary = (NSJSONSerialization.JSONObjectWithData(responseData!, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary)!
            
            // if successfully serialize this data, use JSON to unpack it.
            if let responseObject = responseData {
                let json = JSON(jsonResult)
                // get out user's avatar url.
                let avatarUrl = json["avatar_url"].string
                if avatarUrl != nil {
                    // check if data is returned.....or, it crash
                    if let data = NSData(contentsOfURL: NSURL(string: avatarUrl!)!) {
                        let avatarImage = UIImage(data: data)
                        return avatarImage
                    }
                } else {
                    return nil
                }
            }
        }

        
        return nil
    }
    
    // MARK: - container --> scrollview
    // container of detail view, scrollview
    func DetailContentView() -> UIScrollView {
        
        var detailContentView = UIScrollView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
        detailContentView.contentSize = CGSizeMake(self.view.frame.width, self.view.frame.height * 2)
        
        return detailContentView
    }
    
    // MARK: - detail header view and its contents.
    // TODO: add name, lecturer to this function
    func DetailHeaderView(name: String, lecturer: String) -> UIView? {
        
        var detailHeaderView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, self.headerViewHeight))
        detailHeaderView.backgroundColor = self.colorgyDimOrange
        detailHeaderView.layer.cornerRadius = 5
        
        // upper right corner view
        var contentView = self.UpperRightCornerContentView()!
        let xOffset: CGFloat = 25
        let yOffset: CGFloat = 32
        let position = CGPointMake(detailHeaderView.frame.width - contentView.frame.width / 2 - xOffset, contentView.frame.height / 2 + yOffset)
        contentView.center = position
        
        // lecturer label
        let offsetHeightToContentView: CGFloat = 22
        let lecturerLabel = self.LowerLeftLecturerNameViewWithName(lecturer)
        lecturerLabel.frame.origin.y = contentView.center.y + contentView.bounds.height / 2 + offsetHeightToContentView
        lecturerLabel.frame.origin.x = self.lowerLeftContentSpacing
        detailHeaderView.addSubview(lecturerLabel)
        
        // course label
        let offsetHeightToLecturerLabel: CGFloat = 13
        let courseLabel = self.LowerLeftTitleViewWithCourseName(name)
        courseLabel.frame.origin.y = lecturerLabel.center.y + lecturerLabel.bounds.height / 2 + offsetHeightToLecturerLabel
        courseLabel.frame.origin.x = self.lowerLeftContentSpacing
        detailHeaderView.addSubview(courseLabel)
        
        detailHeaderView.addSubview(contentView)
        
        println(position)
        
        
        return detailHeaderView
    }
    
    func UpperRightCornerContentView() -> UIView? {
        
        var contentView = UIView(frame: CGRectMake(0, 0, 45, 45))
        contentView.backgroundColor = self.colorgyLightOrange
        contentView.layer.cornerRadius = 8
        
        return contentView
    }
    
    func LowerLeftLecturerNameViewWithName(name: String) -> UILabel {
        
        var lecturerNameLabel = UILabel(frame: CGRectMake(0, 0, self.view.frame.width - 2 * self.lowerLeftContentSpacing, self.lecturerNameFontSize))
        
        lecturerNameLabel.text = name
        lecturerNameLabel.textColor = UIColor.whiteColor()
        lecturerNameLabel.font = UIFont(name: "STHeitiTC-Medium", size: self.lecturerNameFontSize)
        
        return lecturerNameLabel
    }
    
    
    func LowerLeftTitleViewWithCourseName(name: String) -> UILabel {
        
        var courseNameLabel = UILabel(frame: CGRectMake(0, 0, self.view.frame.width - 2 * self.lowerLeftContentSpacing, self.courseNameFontSize))
        
        courseNameLabel.text = name
        courseNameLabel.textColor = UIColor.whiteColor()
        courseNameLabel.font = UIFont(name: "STHeitiTC-Medium", size: self.courseNameFontSize)
        
        courseNameLabel.numberOfLines = 0
        courseNameLabel.lineBreakMode = NSLineBreakMode.ByCharWrapping
        
        return courseNameLabel
        
    }
    
    // MARK: - detail information section
    func DetailInformationContainerViewWithContent(content: NSMutableArray?) -> UIView {
        
        let titleBackgroundViewHeight: CGFloat = 49
        var cellCount = (content != nil) ?  content?.count : 0
        
        let containerHeight: CGFloat = titleBackgroundViewHeight + CGFloat(cellCount!) * self.detailInformationContentCellHeight
        var containerView = UIView(frame: CGRectMake(0, 0, self.view.frame.width - 2 * self.detailInformationContainerViewSpacing, containerHeight))
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        containerView.backgroundColor = UIColor.whiteColor()
        
        // title of "詳細資訊"
        let titleSpacing: CGFloat = 20
        let titleFontSize: CGFloat = 18
        var informationTitle = UILabel(frame: CGRectMake(titleSpacing, 0, containerView.frame.width - titleSpacing, titleFontSize))
        informationTitle.font = UIFont(name: "STHeitiTC-Medium", size: titleFontSize)
        informationTitle.textColor = self.colorgyDarkGray
        informationTitle.text = "詳細資訊"
        
        // background view of title
        var titleBackgroundView = UIView(frame: CGRectMake(0, 0, containerView.frame.width, titleBackgroundViewHeight))
        titleBackgroundView.backgroundColor = self.timetableLineColor
        titleBackgroundView.layer.cornerRadius = 5
        
        // add title to its background
        titleBackgroundView.addSubview(informationTitle)
        informationTitle.center.y = titleBackgroundView.center.y
        
        if content != nil {
            for (index, data) in enumerate(content!) {
                if let contentArray = data as? [String] {
                    // input data
                    println(contentArray)
                    // add content here.
                    let contentTopOffset: CGFloat = titleBackgroundViewHeight + CGFloat(index) * self.detailInformationContentCellHeight
                    var contentCell = UIView(frame: CGRectMake(0, contentTopOffset, containerView.frame.width, self.detailInformationContentCellHeight))
                    // subtitle
                    let subtitleSpacing: CGFloat = 29
                    let subtitleWidth: CGFloat = 124
                    let subtitleFontSize: CGFloat = 11
                    var subtitle = UILabel(frame: CGRectMake(subtitleSpacing, 0, subtitleWidth, subtitleFontSize))
                    subtitle.font = UIFont(name: "STHeitiTC-Medium", size: subtitleFontSize)
                    subtitle.textColor = self.colorgyGray
                    // confusing part, dont center to a view's center
                    subtitle.center.y = contentCell.bounds.height / 2
                    subtitle.text = contentArray[0]
                    // content
                    let offsetToSubtitle: CGFloat = subtitleSpacing + subtitleWidth
                    let contentRightSpacing: CGFloat = 15
                    let contentFontSize: CGFloat = 15
                    var substring = UILabel(frame: CGRectMake(offsetToSubtitle, 0, containerView.frame.width - offsetToSubtitle - contentRightSpacing, contentFontSize))
                    substring.font = UIFont(name: "STHeitiTC-Medium", size: contentFontSize)
                    substring.textColor = self.colorgyGray
                    substring.center.y = contentCell.bounds.height / 2
                    substring.text = contentArray[1]
                    // add subtitle and substring
//                    contentCell.backgroundColor = UIColor.blueColor()
                    contentCell.addSubview(subtitle)
                    contentCell.addSubview(substring)
                    
                    
                    
                    // add to container view
                    containerView.addSubview(contentCell)
                }
            }
        }
        
        // draw seperator line
        if content != nil {
            let count = content?.count
            for index in 1...(count! - 1) {
                let lineThickness: CGFloat = 1
                var line = UIView(frame: CGRectMake(0, 0, containerView.frame.width - 4, lineThickness))
                line.backgroundColor = self.timetableLineColor
                line.center.y = titleBackgroundViewHeight + self.detailInformationContentCellHeight * CGFloat(index)
                line.center.x = containerView.center.x
                
                containerView.addSubview(line)
                
            }
        }
        
        
        
        containerView.addSubview(titleBackgroundView)
        
        return containerView
    }

    // MARK: - buttons
    func pushButtonWithTitle(title: String, selector: String) -> UIView? {
        
        let titleBackgroundViewHeight: CGFloat = 49
        
        let containerHeight: CGFloat = titleBackgroundViewHeight
        var containerView = UIView(frame: CGRectMake(0, 0, self.view.frame.width - 2 * self.detailInformationContainerViewSpacing, containerHeight))
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        containerView.backgroundColor = UIColor.whiteColor()
        
        // title of "詳細資訊"
        let titleSpacing: CGFloat = 20
        let titleFontSize: CGFloat = 18
        var informationTitle = UILabel(frame: CGRectMake(titleSpacing, 0, containerView.frame.width - titleSpacing, titleFontSize))
        informationTitle.font = UIFont(name: "STHeitiTC-Medium", size: titleFontSize)
        informationTitle.textColor = self.colorgyDarkGray
        informationTitle.text = title
        
        // background view of title
        var titleBackgroundView = UIButton(frame: CGRectMake(0, 0, containerView.frame.width, titleBackgroundViewHeight))
        titleBackgroundView.backgroundColor = self.timetableLineColor
        
        // add title to its background
        titleBackgroundView.addSubview(informationTitle)
        informationTitle.center.y = titleBackgroundView.center.y
        
        // disclosure button
        var disclosureView = UIImageView(image: UIImage(named: "disclosure"))
        let spaceToRight: CGFloat = 26
        let xOffset = titleBackgroundView.frame.width - disclosureView.frame.width - spaceToRight
        disclosureView.frame.origin.x = xOffset
        disclosureView.center.y = informationTitle.center.y
        titleBackgroundView.addSubview(disclosureView)
        
        containerView.addSubview(titleBackgroundView)
        
        // touch handle
        titleBackgroundView.addTarget(self, action: "pushButtonTouchDown:", forControlEvents: UIControlEvents.TouchDown)
        titleBackgroundView.addTarget(self, action: "pushButtonTouchDragEnter:", forControlEvents: UIControlEvents.TouchDragEnter)
        titleBackgroundView.addTarget(self, action: "pushButtonTouchDragExit:", forControlEvents: UIControlEvents.TouchDragExit)
        titleBackgroundView.addTarget(self, action: "pushButtonTouchCancel:", forControlEvents: UIControlEvents.TouchCancel)
        titleBackgroundView.addTarget(self, action: "pushButtonTouchDown:", forControlEvents: UIControlEvents.TouchUpInside)
        
        return containerView
    }
    
    func pushButtonTouchDown(button: UIButton) {
        println("pushButtonTouchDown")
        
        UIView.animateWithDuration(0.1, animations: {
            button.backgroundColor = self.colorgyLightYellow
        })
    }
    
    func pushButtonTouchDragEnter(button: UIButton) {
        println("pushButtonTouchDragEnter")
        
        UIView.animateWithDuration(0.1, animations: {
            button.backgroundColor = self.colorgyLightYellow
        })
    }
    
    func pushButtonTouchDragExit(button: UIButton) {
        println("pushButtonTouchDragExit")
        
        UIView.animateWithDuration(0.1, animations: {
            button.backgroundColor = self.timetableLineColor
        })
    }
    
    func pushButtonTouchCancel(button: UIButton) {
        println("pushButtonTouchCancel")
        
        UIView.animateWithDuration(0.1, animations: {
            button.backgroundColor = self.timetableLineColor
        })
    }
    
    // MARK: - my classmates.
    func MyClassmatesViewWithClassmates(classmates: NSMutableArray?) -> UIView {
        
        let titleBackgroundViewHeight: CGFloat = 49
        
        let containerHeight: CGFloat = titleBackgroundViewHeight
        var containerView = UIView(frame: CGRectMake(0, 0, self.view.frame.width - 2 * self.detailInformationContainerViewSpacing, containerHeight))
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        containerView.backgroundColor = UIColor.whiteColor()
        
        // title of "詳細資訊"
        let titleSpacing: CGFloat = 20
        let titleFontSize: CGFloat = 18
        var informationTitle = UILabel(frame: CGRectMake(titleSpacing, 0, containerView.frame.width - titleSpacing, titleFontSize))
        informationTitle.font = UIFont(name: "STHeitiTC-Medium", size: titleFontSize)
        informationTitle.textColor = self.colorgyDarkGray
        informationTitle.text = "我的同學"
        
        // background view of title
        var titleBackgroundView = UIView(frame: CGRectMake(0, 0, containerView.frame.width, titleBackgroundViewHeight))
        titleBackgroundView.backgroundColor = self.timetableLineColor
        
        // add title to its background
        titleBackgroundView.addSubview(informationTitle)
        informationTitle.center.y = titleBackgroundView.center.y
        
        // not nil and not zero 0
        if (classmates != nil) && (classmates?.count != 0) {
            // classmate ball height
            let classmateTopSpacing: CGFloat = 27
            let classmateToLeftSpacing: CGFloat = 26
            let classmateToClassmateSpacing: CGFloat = 18
            // min is 2, you can change row showing count here
            // 10 is max is think....
            let everyRowClassmateCounts: CGFloat = 3
            let classmateWidth: CGFloat = (containerView.frame.width - 2 * classmateToLeftSpacing - (everyRowClassmateCounts - 1) * classmateToClassmateSpacing) / everyRowClassmateCounts
            println(classmateWidth)
            
            // calculate rows
            var rows = (classmates?.count)! / Int(everyRowClassmateCounts)
            if ((classmates?.count)! % Int(everyRowClassmateCounts)) != 0 {
                println("rows is \(rows)")
                rows = rows + 1
                println("rows is \(rows)")
            }
//            let rows = 10
            
            for row in 1...rows {
                // generate classmates!
                // this region will generate outer frame of photo
                // after this, get image.
                let classmatesContainerViewHeight: CGFloat = classmateWidth + classmateToClassmateSpacing
                var classmatesContainerView = UIView(frame: CGRectMake(0, titleBackgroundViewHeight + classmateTopSpacing + CGFloat(row - 1) * classmatesContainerViewHeight, containerView.frame.width, classmatesContainerViewHeight))
                
                // determine row counts.
                var counts = (row == rows) ? (classmates?.count)! % Int(everyRowClassmateCounts) : Int(everyRowClassmateCounts)
                // 如果最後一行，且人數剛好填滿everyRowClassmatesCounts，的exception
                if (row == rows) && ((classmates?.count)! % Int(everyRowClassmateCounts) == 0) {
                    counts = Int(everyRowClassmateCounts)
                }
                
                // loop through
                for i in 1...counts {
                    var classmatePhoto = UIImageView(frame: CGRectMake(classmateToLeftSpacing + CGFloat(i - 1) * (classmateWidth + classmateToClassmateSpacing), 0, classmateWidth, classmateWidth))
                    // default image.
                    classmatePhoto.image = UIImage(named: "1-2.jpg")
                    
                    classmatePhoto.layer.masksToBounds = true
                    classmatePhoto.layer.cornerRadius = classmatePhoto.frame.width / 2
                    classmatesContainerView.addSubview(classmatePhoto)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        let offset = (i - 1) + (row - 1) * Int(everyRowClassmateCounts)
                        let userId: Int = self.classmatesData[offset] as! Int
                        
                        var delay = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(offset) * 0.2 * Double(NSEC_PER_SEC)))
                        dispatch_after(delay, dispatch_get_main_queue()) {
                            var image = self.getUserAvatarWithUserId("\(userId)")
                            // if user's image is broken or nil.
                            // set it back to default.
                            classmatePhoto.image = (image == nil) ? UIImage(named: "1-2.jpg") : image
                            // this is layer transition.
                            var transition = CATransition()
                            transition.duration = 0.4
                            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                            transition.type = kCATransitionFade
                            classmatePhoto.layer.addAnimation(transition, forKey: nil)
//                            UIView.animateWithDuration(0.7, delay: 0, options: UIViewAnimationOptions.Autoreverse, animations: {
//                                    classmatePhoto.transform = CGAffineTransformMakeScale(1.3, 1.3)
//                                }, completion: { (isFinished: Bool) -> Void in
//                                    classmatePhoto.transform = CGAffineTransformMakeScale(1, 1)
//                            })
                            
                            // tap on classmate
                            println("offset \(offset), data \(userId)")
                            // tag user
                            classmatePhoto.tag = userId
                            var tap = UITapGestureRecognizer(target: self, action: "tapOnClassmate:")
                            classmatePhoto.addGestureRecognizer(tap)
                            classmatePhoto.userInteractionEnabled = true
                        }
                    }
                }
                
                containerView.addSubview(classmatesContainerView)
            }
            // adjust height of outer container view.
            // do something
            let classmatesContainerViewHeight: CGFloat = classmateWidth + classmateToClassmateSpacing
            containerView.frame.size.height = containerView.frame.height + classmateTopSpacing + classmatesContainerViewHeight * CGFloat(rows)
        } else {
            // no classmate.......
            // expand a little bit.
            containerView.frame.size.height += 30
        }
     
        containerView.addSubview(titleBackgroundView)
        
        return containerView
    }
    
    func tapOnClassmate(gesture: UITapGestureRecognizer) {
        
        var userId = gesture.view?.tag
        
        self.indexTappedOnClassmate = userId
        self.performSegueWithIdentifier("getClassmatePage", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "getClassmatePage" {
            // set back button to no string
            var backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
            self.navigationItem.backBarButtonItem = backButton
            
            var vc = segue.destinationViewController as! ColorgyClassmatePersonalPageViewController
            vc.setupClassmateId(self.indexTappedOnClassmate)
        }
    }
    
    // MARK: - mem warning
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
