//
//  ColorgyCourseDetailPageViewController.swift
//  ColorgyCourse
//
//  Created by David on 2015/7/19.
//  Copyright (c) 2015年 David. All rights reserved.
//

import UIKit

class ColorgyCourseDetailPageViewController: UIViewController {
    
    let headerViewHeight: CGFloat = 200
    let lowerLeftContentSpacing: CGFloat = 28
    let lecturerNameFontSize: CGFloat = 13
    let courseNameFontSize: CGFloat = 36
    
    // color
    let colorgyDimOrange: UIColor = UIColor(red: 226/255.0, green: 109/255.0, blue: 90/255.0, alpha: 1)
    let colorgyLightOrange: UIColor = UIColor(red: 248/255.0, green: 150/255.0, blue: 128/255.0, alpha: 1)
    
    var colorgyDetailContentView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        println("you are now in detail view")
        
        self.colorgyDetailContentView = self.DetailContentView()
        
        // add detail header card
        self.colorgyDetailContentView.addSubview(self.DetailHeaderView()!)
        
        self.view.addSubview(self.colorgyDetailContentView)
    }
    
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
