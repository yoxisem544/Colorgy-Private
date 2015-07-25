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
    var headerViewHeight: CGFloat = 190
    
    // views
    var classmateContentScrollView: UIScrollView!
    
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
        
        self.view.addSubview(self.DetailHeaderView()!)
        
        // set back button to no string
        var backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton
        
        // never adjust this for me.....fuck
        // this is very important line!
        self.automaticallyAdjustsScrollViewInsets = false
        
    }
    
    // MARK: - header view
    func DetailHeaderView() -> UIView? {
        
        var detailHeaderView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, self.headerViewHeight))
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
