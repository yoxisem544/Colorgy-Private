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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        println(self.classmateId)
        
        // add spinner
        self.setupSpinner()
        self.spinner.center = self.view.center
        self.view.addSubview(self.spinner)
        self.animateSpinner()
        
        self.getUserCourseDataWithUserId("\(self.classmateId)")
        var a = self.getUserAvatarWithUserId("\(self.classmateId)")
        println(a)
        
        // set back button to no string
        var backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton
        
        // never adjust this for me.....fuck
        // this is very important line!
        self.automaticallyAdjustsScrollViewInsets = true
        
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
        
        println("self.colorgyTimeTableView.frame \(self.colorgyTimeTableView.frame)")
        println("self.classmateContentScrollView.contentSize \(self.classmateContentScrollView.contentSize)")
        println("self.profileHeaderView.frame \(self.profileHeaderView.frame)")
        
        self.view.addSubview(self.classmateContentScrollView)
    }
    
    // MARK: - timetable grid view and content view
    func ColorgyTimeTableView() -> UIView {
        
        // set its bounds
        var height = self.colorgyTimeTableCell.height * 15 + self.timetableSpacing * 2 + self.headerHeight
        var view = UIView(frame: CGRectMake(0, 0, self.screenWidth, height))
        // background color of timetable
        view.backgroundColor = self.timetableBackgroundColor
        
//        // set timetable scrollview's content size
//        // width matches device width
//        // height is headerBarHeight and coursescount height and some spacing
//        view.contentSize = CGSizeMake(self.screenWidth, self.headerHeight + self.colorgyTimeTableCell.height * CGFloat(self.courseCount) + CGFloat(2) * self.timetableSpacing)
//        // this is nav bar height -> 64
//        view.contentInset.top = 64
//        // this is tab bar height -> 49
//        view.contentInset.bottom = 49
//        view.contentOffset.y = -64
        
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
        
        var detailHeaderView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, self.profileHeaderViewHeight))
        detailHeaderView.backgroundColor = UIColor.blueColor()
        detailHeaderView.layer.cornerRadius = 5
        // grow back the radius
        detailHeaderView.frame.size.height += detailHeaderView.layer.cornerRadius
        
        
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
    
    // MARK: - server
    func getUserCourseDataWithUserId(userId: String) {
        
        // i dont use AFNetworking here.
        // i dont want async here.
        let ud = NSUserDefaults.standardUserDefaults()
        let afManager = AFHTTPSessionManager(baseURL: NSURL(string: "https://colorgy.io/oauth/token"))
        // get user name and  school
        let access_token = ud.objectForKey("ColorgyAccessToken") as! String
        
        var url = "https://colorgy.io:443/api/v1/user_courses.json?filter%5Buser_id%5D=" + userId + "&&&&&&&&&&access_token=" + access_token
        println(url)
       
        
        afManager.GET(url, parameters: nil, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) in
            
            // unpack response object using JSON
            let json = JSON(responseObject)
            println(json)
            
            
            }, failure: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) in
                // TODO: 處理錯誤GET
                println("error \(responseObject)")
        })
    
//        return nil
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
