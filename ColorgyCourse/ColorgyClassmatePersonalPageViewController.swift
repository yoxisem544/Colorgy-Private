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
        
        // set back button to no string
        var backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
