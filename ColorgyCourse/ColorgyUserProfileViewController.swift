//
//  ColorgyUserProfileViewController.swift
//  ColorgyCourse
//
//  Created by David on 2015/5/10.
//  Copyright (c) 2015年 David. All rights reserved.
//

import UIKit

class ColorgyUserProfileViewController: UIViewController {

    var colorgyLightOrange: UIColor = UIColor(red: 228/255.0, green: 133/255.0, blue: 111/255.0, alpha: 1)
    var colorgyDarkGray: UIColor = UIColor(red: 59/255.0, green: 58/255.0, blue: 59/255.0, alpha: 1)
    
    @IBOutlet weak var revealMenuButton: UIBarButtonItem!
    
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
        var ud = NSUserDefaults.standardUserDefaults()
        var data = ud.objectForKey("bigFBProfilePhoto") as! NSData
        self.setupUserPhotoWithPhoto(UIImage(data: data))

        var name = ud.objectForKey("userFBName") as! String
        self.setupUserInfoViewWithName(name, school: "臺灣科技大學", phone: "0900-000-000")
        self.setupBottomBar()
        
        self.view.backgroundColor = self.colorgyDarkGray
        
        self.fetchCourseDataFromServer()
    }
    
    // MARK: - fetch data from server
    func fetchCourseDataFromServer() {
        
        var front_url = "https://colorgy.io:443/api/test/courses.json?per_page=5000&&&&&access_token="
        var ud = NSUserDefaults.standardUserDefaults()
        var token = ud.objectForKey("ColorgyAccessToken") as! String
        let url = front_url + token
        
        println(url)
        
        let afManager = AFHTTPSessionManager(baseURL: NSURL(string: url))
        
        afManager.requestSerializer = AFJSONRequestSerializer()
        afManager.responseSerializer = AFJSONResponseSerializer()
        
        let params = []
        
        afManager.GET(url, parameters: params, success: { (task:NSURLSessionDataTask!, responseObject: AnyObject!) in
            
            var resArr = responseObject as! NSArray
            var parsedResData = NSMutableArray()
            
            var arcData = self.archive(resArr)
            
            var ud = NSUserDefaults.standardUserDefaults()
            ud.setObject(arcData, forKey: "courseFromServer")
            ud.synchronize()
            println("get course from server")
            }, failure: { (task: NSURLSessionDataTask!, error: NSError!) in
                println("error post")
        })
    }
    
    // MARK: - compress data
    
    func archive(array: AnyObject) -> NSData {
        let a = array as! NSArray
        return NSKeyedArchiver.archivedDataWithRootObject(array)
    }
    
    func unarchive(data: NSData) -> NSArray {
        return NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSArray
    }
    
    //MARK: - setup
    
    func setupUserPhotoWithPhoto(photo: UIImage!) {
        
        var w = self.view.frame.width * 0.826
        var view = UIView(frame: CGRectMake(0, 0, w, w))
        
        view.layer.borderColor = UIColor.whiteColor().CGColor
        view.layer.borderWidth = 9
        view.layer.cornerRadius = w / 2
        
        view.backgroundColor = self.colorgyLightOrange
        
        view.center.x = self.view.center.x
        view.center.y = self.view.center.y * 0.8
        
        var innerView = UIImageView(frame: CGRectMake(0, 0, view.frame.width - 40, view.frame.width - 40))
        innerView.image = photo
        innerView.layer.cornerRadius = innerView.frame.width / 2
        innerView.layer.masksToBounds = true
        innerView.center = view.center
        
        self.view.addSubview(view)
        self.view.addSubview(innerView)
    }
    
    func setupUserInfoViewWithName(name: String, school: String, phone: String) {
        
        var h = self.view.frame.height * 0.27
        var view = UIView(frame: CGRectMake(0, 0, self.view.frame.width, h))
        
        view.backgroundColor = UIColor(red: 74/255.0, green: 74/255.0, blue: 74/255.0, alpha: 0.8)
        
        
        view.center.y = self.view.frame.height * 0.7
        view.center.x = self.view.center.x
        
//        view.layer.shadowColor = UIColor.blackColor().CGColor
        view.layer.shadowOpacity = 0.5
        // enlarge view.bounds first, in order to let shadow show in bottom
        var bounds = view.bounds.size
        bounds.height = bounds.height + 2
        view.layer.shadowPath = UIBezierPath(rect: CGRectMake(view.bounds.origin.x + 3, view.bounds.origin.y + 3, bounds.width, bounds.height)).CGPath
//        view.layer.shadowOffset = CGSizeMake(30, 30)  
        
        // name label
        var uname = UILabel(frame: CGRectMake(0, 30, self.view.frame.width * 0.8, 36))
        uname.font = UIFont(name: "Heiti TC", size: 36)
        uname.textColor = self.colorgyLightOrange
        uname.textAlignment = NSTextAlignment.Center
        uname.center.x = view.center.x
        
        uname.text = name
        
        view.addSubview(uname)
        
        // school label
        var uschool = UILabel(frame: CGRectMake(0, 94, self.view.frame.width * 0.8, 17))
        uschool.font = UIFont(name: "Heiti TC", size: 17)
        uschool.textColor = UIColor.whiteColor()
        uschool.textAlignment = NSTextAlignment.Center
        uschool.center.x = view.center.x
        
        uschool.text = "學校： " + school
        
        view.addSubview(uschool)
        
        // tel label
        var uphone = UILabel(frame: CGRectMake(0, 125, self.view.frame.width * 0.8, 17))
        uphone.font = UIFont(name: "Heiti TC", size: 17)
        uphone.textColor = UIColor.whiteColor()
        uphone.textAlignment = NSTextAlignment.Center
        uphone.center.x = view.center.x
        
        uphone.text = "電話： " + phone
        
        view.addSubview(uphone)
        
        self.view.addSubview(view)
    }
    
    func setupBottomBar() {
        
        var img1 = UIImage(named: "profileBottom1")
        var img2 = UIImage(named: "profileBottom2")
        
        let w1 = img1?.size.width
        let h1 = img1?.size.height
        let w2 = img2?.size.width
        let h2 = img2?.size.height
        
        var v1 = UIImageView(frame: CGRectMake(0, 0, w1!, h1!))
        var v2 = UIImageView(frame: CGRectMake(0, 0, w2!, h2!))
        
        v1.image = img1
        v2.image = img2
        
        v1.center = CGPointMake(self.view.center.x, self.view.frame.height - 20)
        v2.center = CGPointMake(self.view.center.x, self.view.frame.height - 25)
        
        self.view.addSubview(v1)
        self.view.addSubview(v2)
        
        UIView.animateWithDuration(20, delay: 0, options: UIViewAnimationOptions.Repeat | UIViewAnimationOptions.Autoreverse, animations: {
            v1.transform = CGAffineTransformMakeTranslation(200, 0)
        }, completion: nil)
        
        UIView.animateWithDuration(15, delay: 0, options: UIViewAnimationOptions.Repeat | UIViewAnimationOptions.Autoreverse, animations: {
            v2.transform = CGAffineTransformMakeTranslation(200, 0)
            }, completion: nil)
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
