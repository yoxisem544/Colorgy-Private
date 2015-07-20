//
//  ColorgyCourseDetailPageViewController.swift
//  ColorgyCourse
//
//  Created by David on 2015/7/19.
//  Copyright (c) 2015年 David. All rights reserved.
//

import UIKit

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
    
    // color
    let colorgyDimOrange: UIColor = UIColor(red: 226/255.0, green: 109/255.0, blue: 90/255.0, alpha: 1)
    let colorgyLightOrange: UIColor = UIColor(red: 248/255.0, green: 150/255.0, blue: 128/255.0, alpha: 1)
    var colorgyDarkGray = UIColor(red: 74/255.0, green: 74/255.0, blue: 74/255.0, alpha: 1)
    var timetableLineColor: UIColor = UIColor(red: 216/255.0, green: 216/255.0, blue: 216/255.0, alpha: 1)
    // detail information 的 內容字的顏色
    var colorgyGray = UIColor(red: 113/255.0, green: 112/255.0, blue: 113/255.0, alpha: 1)
    // background color
    var timetableBackgroundColor: UIColor = UIColor(red: 250/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1)
    
    var colorgyDetailContentView: UIScrollView!

    // MARK: - view
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        println("you are now in detail view")
        
        self.colorgyDetailContentView = self.DetailContentView()
        
        // add detail header card
        var detailHeaderView = self.DetailHeaderView()!
        self.colorgyDetailContentView.addSubview(detailHeaderView)
        
        // content
        var content = NSMutableArray()
        content.addObject(["地點", "San Francisco"])
        content.addObject(["日期", "Oct 10"])
        content.addObject(["代碼", "A1234567890"])
        content.addObject(["地點", "San Francisco"])
        content.addObject(["日期", "Oct 10"])
        content.addObject(["代碼", "A1234567890"])
        content.addObject(["特", "A1234567890"])
        content.addObject(["別", "A1234567890"])
        content.addObject(["做的", "可以丟鎮列他幫你處理"])
        
        // add detail information
        var detailInformationView = self.DetailInformationContainerViewWithContent(content)
        // move information view to header view's bottom
        detailInformationView.center.x = detailHeaderView.center.x
        detailInformationView.frame.origin.y = detailHeaderView.frame.height + self.headerAndDetailInformationSpacing
        self.colorgyDetailContentView.addSubview(detailInformationView)
        
        // buttons
        var button = self.pushButtonWithTitle("課程評論", selector: "yo")!
        button.center.x = detailHeaderView.center.x
        button.frame.origin.y = detailInformationView.frame.origin.y + detailInformationView.frame.height + self.contentSpacing
        self.colorgyDetailContentView.addSubview(button)
        
        // classmates
        var classmatesView = self.MyClassmatesViewWithClassmates([])
        classmatesView.center.x = detailHeaderView.center.x
        classmatesView.frame.origin.y = button.frame.origin.y + button.frame.height + self.contentSpacing
        self.colorgyDetailContentView.addSubview(classmatesView)
        
        self.view.addSubview(self.colorgyDetailContentView)
        
        self.view.backgroundColor = self.timetableBackgroundColor
    }
    
    // container of detail view, scrollview
    func DetailContentView() -> UIScrollView {
        
        var detailContentView = UIScrollView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
        detailContentView.contentSize = CGSizeMake(self.view.frame.width, self.view.frame.height * 2)
        
        return detailContentView
    }
    
    // MARK: - detail header view and its contents.
    func DetailHeaderView() -> UIView? {
        
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
        let lecturerLabel = self.LowerLeftLecturerNameViewWithName("小ㄐㄐ")
        lecturerLabel.frame.origin.y = contentView.center.y + contentView.bounds.height / 2 + offsetHeightToContentView
        lecturerLabel.frame.origin.x = self.lowerLeftContentSpacing
        detailHeaderView.addSubview(lecturerLabel)
        
        // course label
        let offsetHeightToLecturerLabel: CGFloat = 13
        let courseLabel = self.LowerLeftTitleViewWithCourseName("網友們分享請將內容拍照存檔並寄信給管理員，再附上你個人的PS 經管理員")
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
            button.backgroundColor = self.colorgyGray
        })
    }
    
    func pushButtonTouchDragEnter(button: UIButton) {
        println("pushButtonTouchDragEnter")
        
        UIView.animateWithDuration(0.1, animations: {
            button.backgroundColor = self.colorgyGray
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
        
        if classmates != nil {
            // classmate ball height
            let classmateTopSpacing: CGFloat = 27
            let classmateToLeftSpacing: CGFloat = 26
            let classmateToClassmateSpacing: CGFloat = 18
            let everyRowClassmateCounts: CGFloat = 5
            let classmateWidth: CGFloat = (containerView.frame.width - 2 * classmateToLeftSpacing - (everyRowClassmateCounts - 1) * classmateToClassmateSpacing) / everyRowClassmateCounts
            println(classmateWidth)
            
            // calculate rows
//            let rows = classmates?.count
            let rows = 3
            
            for row in 1...rows {
                // generate classmates!
                let classmatesContainerViewHeight: CGFloat = classmateWidth + classmateToClassmateSpacing
                var classmatesContainerView = UIView(frame: CGRectMake(0, titleBackgroundViewHeight + classmateTopSpacing + CGFloat(row - 1) * classmatesContainerViewHeight, containerView.frame.width, classmatesContainerViewHeight))
                for i in 1...5 {
                    var classmatePhoto = UIImageView(frame: CGRectMake(classmateToLeftSpacing + CGFloat(i - 1) * (classmateWidth + classmateToClassmateSpacing), 0, classmateWidth, classmateWidth))
                    classmatePhoto.image = UIImage(named: "1-2.jpg")
                    classmatePhoto.layer.masksToBounds = true
                    classmatePhoto.layer.cornerRadius = classmatePhoto.frame.width / 2
                    classmatesContainerView.addSubview(classmatePhoto)
                }
                
                containerView.addSubview(classmatesContainerView)
            }
            // adjust height of outer container view.
            // do something
            let classmatesContainerViewHeight: CGFloat = classmateWidth + classmateToClassmateSpacing
            containerView.frame.size.height = containerView.frame.height + classmateTopSpacing + classmatesContainerViewHeight * CGFloat(rows)
        }
        
        
        
        
        
        containerView.addSubview(titleBackgroundView)
        
        
        
        return containerView
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
