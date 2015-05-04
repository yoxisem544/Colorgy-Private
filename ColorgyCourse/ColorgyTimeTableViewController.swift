//
//  ColorgyTimeTableViewController.swift
//  ColorgyTimeTable
//
//  Created by David on 2015/4/27.
//  Copyright (c) 2015年 David. All rights reserved.
//

import UIKit

class ColorgyTimeTableViewController: UIViewController {
    
    @IBOutlet weak var revealMenuButton: UIBarButtonItem!
    
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
    
    // color region
    var colorgyGreen: UIColor = UIColor(red: 42/255.0, green: 171/255.0, blue: 147/255.0, alpha: 1)
    var colorgyDarkGray: UIColor = UIColor(red: 74/255.0, green: 74/255.0, blue: 74/255.0, alpha: 1)
    var timetableWhite: UIColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //reveal region
        if self.revealViewController() != nil {
            revealMenuButton.target = self.revealViewController()
            revealMenuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
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
        
        self.view.addSubview(self.ColorgyTimeTableView())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func ColorgyTimeTableView() -> UIScrollView {
        
        // set its bounds
        var view = UIScrollView(frame: CGRectMake(0, 0, self.screenWidth, self.screenHeight))
        view.backgroundColor = self.colorgyGreen
        
        // set timetable scrollview's content size
        // width matches device width
        // height is headerBarHeight and coursescount height and some spacing
        view.contentSize = CGSizeMake(self.screenWidth, self.headerHeight + self.colorgyTimeTableCell.height * CGFloat(self.courseCount))
        
        // add grid view
        view.addSubview(self.ColorgyTimeTableColumnView())
        view.addSubview(self.ColorgyTimeTableRowSessionView("morning"))
        view.addSubview(self.ColorgyTimeTableRowSessionView("afternoon"))
        view.addSubview(self.ColorgyTimeTableRowSessionView("night"))
        
        return view as UIScrollView
    }
    
    func ColorgyTimeTableColumnView() -> UIView {
        // this view is vertical view
        // this is days from mon to fri
        var view = UIView(frame: CGRectMake(self.timetableSpacing + self.sideBarWidth, 0.0, self.colorgyTimeTableCell.width * 5, self.headerHeight + self.colorgyTimeTableCell.height * CGFloat(self.courseCount)))
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
        
        var view = UIView(frame: CGRectMake(self.timetableSpacing, self.headerHeight + timeOffset, self.sideBarWidth + self.colorgyTimeTableCell.width * CGFloat(5), self.colorgyTimeTableCell.height * courses))
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
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
