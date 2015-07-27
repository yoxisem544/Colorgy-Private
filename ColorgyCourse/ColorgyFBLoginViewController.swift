//
//  ColorgyFBLoginViewController.swift
//  ColorgyTimeTable
//
//  Created by David on 2015/4/27.
//  Copyright (c) 2015年 David. All rights reserved.
//

import UIKit

class ColorgyFBLoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - declaration
    // this is background of login view
    // green ink and logo
    var loginBackground: UIImageView!
    var colorgyLogo: UIImageView!
    
    // this is user who use account and password to login
    var userAccount: UITextField!
    var userPassword: UITextField!
    
    var passwordLoginButton: UIButton!
    
    // facebook region
    // user who use facebook to login
    var facebookLoginButton: UIButton!
    
    // switch between fb and password login
    var loginSwitchButton: UIButton!
    var loginMode: String!
    
    // MARK: - keyboard handler helper
    // keyboard height
    var keyboardHeight: CGFloat!
    var screenHeight: CGFloat!
    
    // MARK: - color
    var colorgyGray = UIColor(red: 113/255.0, green: 112/255.0, blue: 113/255.0, alpha: 1)
    var colorgyDimGray = UIColor(red: 74/255.0, green: 74/255.0, blue: 74/255.0, alpha: 1)
    var colorgyLightGray = UIColor(red: 238/255.0, green: 231/255.0, blue: 231/255.0, alpha: 1)
    
    // MARK: - view
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // setup logo and backgorun
        self.setupLogoAndBackgorund()
        self.hideLogoBackground()
        
        
        // password and account login
        self.setupUserPasswordAndAccount()
        self.hideUserPasswordAndAccount()
//        self.showUserPasswordAndAccount(1.3)
        
        self.setupFacebookLoginButton()
        self.hideFacebookButton()
        
        
        self.setupLoginSwitchButton()
        self.loginMode = "fb"
        
        // make keyboard show animation more naturally
        self.extendBottomOfView()
        // gestures to dismiss keyboard
        self.addTapGestureToDismissKeyboard()
        self.addSwipGestureToDismissKeyboard()
        
        self.screenHeight = self.view.frame.height
    }
    
    func extendBottomOfView() {
        // extend bottom of view
        var view = UIView(frame: CGRectMake(0, self.view.frame.height, self.view.frame.width, 37))
        view.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(view)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // always present animation after viewdidload
        // present it in viewdidappear
        self.showLogoAndBackground()
        self.showFacebookButton(1.3)
        
        // register notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // unregister notification
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // MARK: - keyboard handler
    func keyboardWillShow(notification: NSNotification) {
        println("keyboard will show")
        
        // get keyboard height
        var userInfo = notification.userInfo as! NSDictionary
        self.keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().size.height
        // keyboard show/hide animation curve
        let curveInt = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber as Int
        let curve = UIViewAnimationCurve(rawValue: curveInt)
        
        // animate view to proper position
        UIView.animateWithDuration(0.25, delay: 0, options: nil, animations: {
                UIView.setAnimationCurve(curve!)
                var topOffset = (self.screenHeight - self.keyboardHeight) * 0.35
                self.view.frame.origin.y = -(self.userAccount.frame.origin.y - topOffset)
            }, completion: nil)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        println("keyboard will show")
        self.view.frame.origin.y = 0
    }
    
    func addTapGestureToDismissKeyboard() {
        var tapGesture = UITapGestureRecognizer(target: self, action: "tapOnViewToDismissKeyboard")
        // need one finger tap to dismiss keyboard.
        tapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func tapOnViewToDismissKeyboard() {
        println("tap!")
        self.view.endEditing(true)
    }
    
    func addSwipGestureToDismissKeyboard() {
        var swipeGesture = UISwipeGestureRecognizer(target: self, action: "swipeToDismissKeyboard")
        swipeGesture.direction = UISwipeGestureRecognizerDirection.Down
        self.view.addGestureRecognizer(swipeGesture)
    }
    
    func swipeToDismissKeyboard() {
        println("swipe!")
        self.view.endEditing(true)
    }
    
    // MARK: - setup switch login button
    func setupLoginSwitchButton() {
        // style of login switch button
        self.loginSwitchButton = UIButton(frame: CGRectMake(0, 0, 180, 20))
        self.loginSwitchButton.setTitle("Email 登入", forState: UIControlState.Normal)
        self.loginSwitchButton.titleLabel?.font = UIFont(name: "STHeitiTC-Medium", size: 15)
        self.loginSwitchButton.setTitleColor(self.colorgyGray, forState: UIControlState.Normal)
        self.loginSwitchButton.center = CGPointMake(self.view.center.x, self.view.center.y + 200)
        
        // targets of login switch button
        self.loginSwitchButton.addTarget(self, action: "loginSwitchTouchUpInside", forControlEvents: UIControlEvents.TouchUpInside)
        self.loginSwitchButton.addTarget(self, action: "loginSwitchTouchDown", forControlEvents: UIControlEvents.TouchDown)
        self.loginSwitchButton.addTarget(self, action: "loginSwitchTouchDragExit", forControlEvents: UIControlEvents.TouchDragExit)
        self.loginSwitchButton.addTarget(self, action: "loginSwitchTouchDragEnter", forControlEvents: UIControlEvents.TouchDragEnter)
        self.loginSwitchButton.addTarget(self, action: "loginSwitchCancel", forControlEvents: UIControlEvents.TouchCancel)

        self.view.addSubview(self.loginSwitchButton)
    }
    
    func loginSwitchTouchUpInside() {
        println("touch")
        self.changeLoginSwitchAlpha(1)
        // switch mode
        if self.loginMode == "password" {
            // change to fb login
            self.loginMode = "fb"
            self.loginSwitchButton.setTitle("Email 登入", forState: UIControlState.Normal)
            // hide keyboard.
            self.view.endEditing(true)
            self.hideUserPasswordAndAccount()
            self.showFacebookButton(0)
        } else {
            // change to password login
            self.loginMode = "password"
            self.loginSwitchButton.setTitle("Facebook 登入", forState: UIControlState.Normal)
            self.hideFacebookButton()
            self.showUserPasswordAndAccount(0)
        }
    }
    
    func loginSwitchTouchDown() {
        println("down")
        self.changeLoginSwitchAlpha(0.5)
    }
    
    func loginSwitchTouchDragExit() {
        println("drag exit")
        self.changeLoginSwitchAlpha(1)
    }
    
    func loginSwitchTouchDragEnter() {
        println("drag enter")
        self.changeLoginSwitchAlpha(0.5)
    }
    
    func loginSwitchCancel() {
        println("touch cancel")
        self.changeLoginSwitchAlpha(1)
    }
    
    func changeLoginSwitchAlpha(alpha: CGFloat) {
        self.loginSwitchButton.alpha = alpha
    }
    
    // MARK: - setup Login backgorund and logo
    
    func setupLogoAndBackgorund() {
        // setup backgorund
        var image = UIImage(named: "LoginBackground")
        var w = image?.size.width
        var h = image?.size.height
        self.loginBackground = UIImageView(frame: CGRectMake(0, 0, w!, h!))
        self.loginBackground.center.x = self.view.center.x
        self.loginBackground.image = image
        
        self.view.addSubview(self.loginBackground)

        // adding logo
        var logo = UIImage(named: "ColorgyLogo")
        // w & h of logo
        w = logo?.size.width
        h = logo?.size.height

        // resize with varius device
        if self.view.frame.height <= 480 {
            // iphone 4s
            w = w! * CGFloat(320 / 375.0)
            h = h! * CGFloat(320 / 375.0)
        } else if self.view.frame.height <= 568 {
            // for 5 and 5s
            w = w! * CGFloat(320 / 375.0)
            h = h! * CGFloat(320 / 375.0)
        } else if self.view.frame.height <= 667 {
            // iphone 6
            // nothing to do. stay the same.
        } else {
            // for 6+
            w = w! * CGFloat(411 / 375.0)
            h = h! * CGFloat(411 / 375.0)
        }
        
        // set logo using logo image, set its position
        self.colorgyLogo = UIImageView(frame: CGRectMake(0, 0, w!, h!))
        self.colorgyLogo.image = logo
        self.colorgyLogo.center.x = self.view.center.x
        self.colorgyLogo.center.y = self.view.center.y * 0.6
        
        println(self.colorgyLogo)
        
        self.view.addSubview(self.colorgyLogo)
    }
    
    
    
    func hideLogoBackground() {
        
        if self.view.frame.height <= 480 {
            // iphone 4s
            self.loginBackground.transform = CGAffineTransformMakeTranslation(0, -850)
        } else if self.view.frame.height <= 568 {
            // for 5 and 5s
            self.loginBackground.transform = CGAffineTransformMakeTranslation(0, -850)
        } else if self.view.frame.height <= 667 {
            // iphone 6
            self.loginBackground.transform = CGAffineTransformMakeTranslation(0, -850)
        } else {
            // for 6+
            self.loginBackground.transform = CGAffineTransformMakeTranslation(0, -850)
        }
        
        self.colorgyLogo.transform = CGAffineTransformMakeScale(0, 0)
    }
    
    func showLogoAndBackground() {
        // when user enter this view, logo and background image need to animate from top to bottom.
        var transDown: CGAffineTransform!
        
        if self.view.frame.height <= 480 {
            // iphone 4s
            transDown = CGAffineTransformMakeTranslation(0, -518)
        } else if self.view.frame.height <= 568 {
            // for 5 and 5s
            transDown = CGAffineTransformMakeTranslation(0, -430)
        } else if self.view.frame.height <= 667 {
            // iphone 6
            transDown = CGAffineTransformMakeTranslation(0, -330)
        } else {
            // for 6+
            transDown = CGAffineTransformMakeTranslation(0, -261)
        }
        
        UIView.animateWithDuration(1.0, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: nil, animations: {
                // first drop down background image.
                self.loginBackground.transform = transDown
            }, completion: nil)
        UIView.animateWithDuration(0.7, delay: 0.7, usingSpringWithDamping: 0.6, initialSpringVelocity: 1.0, options: nil, animations: {
                // then show logo
                var makeAppear = CGAffineTransformMakeScale(1, 1)
                self.colorgyLogo.transform = makeAppear
            }, completion: nil)
    }
    
    
    // MARK: - Facebook setup region
    func setupFacebookLoginButton() {
        // style of facebook login button
        self.facebookLoginButton = UIButton(frame: CGRectMake(0, 0, 226, 48))
        // button image.
        self.facebookLoginButton.setImage(UIImage(named: "FacebookLogin"), forState: UIControlState.Normal)
        // position
        self.facebookLoginButton.center = CGPointMake(self.view.center.x, self.view.center.y + 130)
        
        self.view.addSubview(self.facebookLoginButton)
        
        // add target to fb login button.
        // what to do if user tap in this button
        self.facebookLoginButton.addTarget(self, action: "LoginToFacebook", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    
    
    func hideFacebookButton() {
        self.facebookLoginButton.transform = CGAffineTransformMakeScale(0, 0)
    }
    
    func showFacebookButton(delay: NSTimeInterval) {
        UIView.animateWithDuration(0.3, delay: delay, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.5, options: nil, animations: {
                self.facebookLoginButton.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: nil)
    }
    
    // MARK: - setup Account and Password
    func setupUserPasswordAndAccount() {
        var textFieldWidth: CGFloat! = 250
        
        if self.view.frame.height <= 480 {
            // iphone 4s
            textFieldWidth = textFieldWidth * (320 / 375)
        } else if self.view.frame.height <= 568 {
            // for 5 and 5s
            textFieldWidth = textFieldWidth * (320 / 375)
        } else if self.view.frame.height <= 667 {
            // iphone 6
            textFieldWidth = textFieldWidth * (375 / 375)
        } else {
            // for 6+
            textFieldWidth = textFieldWidth * (414 / 375)
        }
        
        // password login items
        self.userPassword = UITextField(frame: CGRectMake(0, 0, textFieldWidth, 30))
        self.userPassword.borderStyle = UITextBorderStyle.RoundedRect
        self.userPassword.placeholder = "Password"
        self.userPassword.center.x = self.view.center.x
        self.userPassword.center.y = self.view.center.y + 50
        self.view.addSubview(self.userPassword)
        // type => password
        self.userPassword.secureTextEntry = true
        // return button, set it to Go!
        self.userPassword.returnKeyType = UIReturnKeyType.Go
        
        self.userAccount = UITextField(frame: CGRectMake(0, 0, textFieldWidth, 30))
        self.userAccount.borderStyle = UITextBorderStyle.RoundedRect
        self.userAccount.placeholder = "Email"
        self.userAccount.center.x = self.view.center.x
        self.userAccount.center.y = self.view.center.y
        self.view.addSubview(self.userAccount)
        // return button, set it to Next!
        self.userAccount.returnKeyType = UIReturnKeyType.Next
        
        // button
        self.passwordLoginButton = UIButton(frame: CGRectMake(0, 0, 150, 45))
        self.passwordLoginButton.setTitle("登入", forState: UIControlState.Normal)
        self.passwordLoginButton.titleLabel?.font = UIFont(name: "STHeitiTC-Medium", size: 18)
        self.passwordLoginButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.passwordLoginButton.backgroundColor = UIColor.grayColor()
        self.passwordLoginButton.layer.cornerRadius = 10
        
        // password login tap setting
        self.passwordLoginButton.addTarget(self, action: "passwordLoginButtonTouchUpInside", forControlEvents: UIControlEvents.TouchUpInside)
        self.passwordLoginButton.addTarget(self, action: "passwordLoginButtonTouchDown", forControlEvents: UIControlEvents.TouchDown)
        self.passwordLoginButton.addTarget(self, action: "passwordLoginButtonDragExit", forControlEvents: UIControlEvents.TouchDragExit)
        self.passwordLoginButton.addTarget(self, action: "passwordLoginButtonDragEnter", forControlEvents: UIControlEvents.TouchDragEnter)
        self.passwordLoginButton.addTarget(self, action: "passwordLoginButtonCancel", forControlEvents: UIControlEvents.TouchCancel)

        // delegate
        self.userAccount.delegate = self
        self.userPassword.delegate = self
        
        self.passwordLoginButton.center = CGPointMake(self.view.center.x, self.view.center.y + 130)
        self.view.addSubview(self.passwordLoginButton)
    }
    
    func hideUserPasswordAndAccount() {
        self.userPassword.transform = CGAffineTransformMakeScale(0, 0)
        self.userAccount.transform = CGAffineTransformMakeScale(0, 0)
        self.passwordLoginButton.transform = CGAffineTransformMakeScale(0, 0)
    }
    
    func showUserPasswordAndAccount(delay: NSTimeInterval) {
        // animation to show textfields and button
        UIView.animateWithDuration(0.5, delay: delay, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: nil, animations: {
                self.userAccount.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: nil)
        UIView.animateWithDuration(0.5, delay: delay+0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: nil, animations: {
                self.userPassword.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: nil)
        UIView.animateWithDuration(0.5, delay: delay+0.2, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: nil, animations: {
                self.passwordLoginButton.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: nil)
    }
    
    // MARK:- password Login Button tap handler
    
    func passwordLoginButtonTouchUpInside() {
        self.changePasswordLoginButtonAlpha(1)
        self.changePasswordLoginButtonColor(self.colorgyGray)
        // login using password and account
        let username = self.userAccount.text
        let password = self.userPassword.text
        if username != "" && password != ""{
            if count(password) >= 8 {
                // legal password must be more then 8 digits
                self.view.endEditing(true)
                self.requestColorgyOAuthAccessTokenWithUserName(username, password: password)
            } else {
                self.alertUserWithError("密碼必須大於等於8碼！！")
                self.userPassword.becomeFirstResponder()
            }
        } else {
            self.alertUserWithError("帳號或密碼不能為空！！")
        }
    }
    
    func passwordLoginButtonTouchDown() {
        println("down")
        self.changePasswordLoginButtonAlpha(0.5)
        self.changePasswordLoginButtonColor(self.colorgyDimGray)
    }
    
    func passwordLoginButtonDragExit() {
        println("drag exit")
        self.changePasswordLoginButtonAlpha(1)
        self.changePasswordLoginButtonColor(self.colorgyGray)
    }
    
    func passwordLoginButtonDragEnter() {
        println("drag enter")
        self.changePasswordLoginButtonAlpha(0.5)
        self.changePasswordLoginButtonColor(self.colorgyDimGray)
    }
    
    func passwordLoginButtonCancel() {
        println("touch cancel")
        self.changePasswordLoginButtonAlpha(1)
        self.changePasswordLoginButtonColor(self.colorgyGray)
    }
    
    func changePasswordLoginButtonAlpha(alpha: CGFloat) {
        self.passwordLoginButton.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: alpha), forState: UIControlState.Normal)
    }
    
    func changePasswordLoginButtonColor(color: UIColor) {
        self.passwordLoginButton.backgroundColor = color
    }

    // MARK: - facebook login helper function
    func LoginToFacebook() {
        if FBSession.activeSession().isOpen {
            // user is already login.
            // do somthing here
        } else {
            // user request login to fb
            // extended permission: email -> this is a must!
            FBSession.openActiveSessionWithReadPermissions(["email"], allowLoginUI: true, completionHandler: { (session:FBSession!, state:FBSessionState, error: NSError!) in
                
                // completion handler
                // first detect if something went wrong
                if error != nil {
                    self.alertUserWithError("登入FB時出錯囉！")
                } else {
                    println("login fb success!")
                    var ud = NSUserDefaults.standardUserDefaults()
                    // get user profile photo
                    FBRequest.requestForMe().startWithCompletionHandler{
                        (connection:FBRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
                        
                        if result != nil {
                            var id = result["id"] as! String
                            println(result)
                            var smallProfilePhoto = NSData(contentsOfURL: NSURL(string: "https://graph.facebook.com/\(id)/picture?width=128&height=128")!)!
                            var bigProfilePhoto = NSData(contentsOfURL: NSURL(string: "https://graph.facebook.com/\(id)/picture?width=640&height=640")!)!
                            ud.setObject(smallProfilePhoto, forKey: "smallFBProfilePhoto")
                            ud.setObject(bigProfilePhoto, forKey: "bigFBProfilePhoto")
                            ud.synchronize()
                        }
                    }
                    if session.accessTokenData != nil {
                        self.requestColorgyOAuthAccessTokenWithFBToken(session.accessTokenData.accessToken)
                    } else {
                        println("fuc!!!!!")
                        self.alertUserWithError("FB登入出錯了！")
                    }
                }
            })
        }
    }
    
    // AFNetworking POST helper
    func requestColorgyOAuthAccessTokenWithFBToken(token: String) {
        
        let afManager = AFHTTPSessionManager(baseURL: NSURL(string: "https://colorgy.io/oauth/token"))
        
        afManager.requestSerializer = AFJSONRequestSerializer()
        afManager.responseSerializer = AFJSONResponseSerializer()
        
        println("fb token \(token)")
        
        let params = [
            "grant_type": "password",
            // 應用程式ID application id, in colorgy server
            "client_id": "ad2d3492de7f83f0708b5b1db0ac7041f9179f78a168171013a4458959085ba4",
            "client_secret": "d9de77450d6365ca8bd6717bbf8502dfb4a088e50962258d5d94e7f7211596a3",
            "username": "facebook:access_token",
            "password": token,
            "scope": "public account offline_access"
        ]
        
        // hide switch while posting
        self.loginSwitchButton.hidden = true
        
        afManager.POST("https://colorgy.io/oauth/token", parameters: params, success: { (task:NSURLSessionDataTask!, responseObject: AnyObject!) in
                println("succccc post")
                println(responseObject)
            
                let access_token = responseObject["access_token"] as! String
                let created_at = String(stringInterpolationSegment: responseObject["created_at"])
                let expires_in = String(stringInterpolationSegment: responseObject["expires_in"])
                let refresh_token = responseObject["refresh_token"] as! String
                let token_type = responseObject["token_type"] as! String
            
                // wait for animation to finish, then store login info
                var delay = dispatch_time(DISPATCH_TIME_NOW, Int64( 1 * Double(NSEC_PER_SEC)))
                dispatch_after(delay, dispatch_get_main_queue()) {
                    self.userSuccessfullyLoginToColorgyWithToken(access_token, created_at: created_at, expires_in: expires_in, refresh_token: refresh_token, token_type: token_type, loginType: "fb")
                }
    
            }, failure: { (task: NSURLSessionDataTask!, error: NSError!) in
                println("error post")
                self.alertUserWithError("與 Colorgy Server 溝通時發生錯誤！")
                // show switch if user got a error while login
                
                println(error)
                self.loginSwitchButton.hidden = false
            })
    }
    
    func userSuccessfullyLoginToColorgyWithToken(token: String, created_at: String, expires_in: String, refresh_token: String, token_type: String, loginType: String) {
        
        var ud = NSUserDefaults.standardUserDefaults()
        ud.setObject(token, forKey: "ColorgyAccessToken")
        ud.setObject(created_at, forKey: "ColorgyCreatedTime")
        ud.setObject(expires_in, forKey: "ColorgyExpireTime")
        ud.setObject(refresh_token, forKey: "ColorgyRefreshToken")
        ud.setObject(token_type, forKey: "ColorgyTokenType")
        
        // set user to login
        ud.setObject("yes", forKey: "isLogin")
        // set user login type
        ud.setObject(loginType, forKey: "loginType")
        
        // sync setting
        ud.synchronize()
        
        // get user name and  school
        let afManager = AFHTTPSessionManager(baseURL: NSURL(string: "https://colorgy.io/oauth/token"))
        let access_token = ud.objectForKey("ColorgyAccessToken") as! String
        afManager.GET("https://colorgy.io/api/v1/me?access_token=" + access_token, parameters: nil, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) in
            println(responseObject)
                let name = responseObject["name"] as! String
                ud.setObject(name, forKey: "userName")
                ud.synchronize()
                if let res = responseObject["organizations"] as? NSArray {
                    ud.setObject(res[0] as! String, forKey: "userSchool")
                    ud.synchronize()
                } else {
                    // if not, block this user.
//                    self.alertUserWithError("你必須在Colorgy上驗證學校信箱之後才能開始使用！")
//                    self.loginSwitchButton.hidden = false
                    ud.setObject("NotYetAuthorized", forKey: "userSchool")
                    ud.synchronize()
                }
                // if user is authed to Colorgy
                println("ready to switch view")
                self.animateLogoOff()
                // wait for animate logo off to finish
                var delay = dispatch_time(DISPATCH_TIME_NOW, Int64( 1 * Double(NSEC_PER_SEC)))
                dispatch_after(delay, dispatch_get_main_queue()) {
                    println("fire!")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    var vc = storyboard.instantiateViewControllerWithIdentifier("ColorgyTabBarService") as! UITabBarController
                    self.presentViewController(vc, animated: true, completion: nil)
                }
            
                ud.synchronize()
            
            
            }, failure: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) in
                
            })
    }
    
    func alertUserWithError(error: String) {
        
        let errorAlert = UIAlertController(title: "哦！出錯了！😨", message: "\(error)", preferredStyle: UIAlertControllerStyle.Alert)
        let dismiss = UIAlertAction(title: "知道了！", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction!) -> Void in
            errorAlert.dismissViewControllerAnimated(true, completion: nil)
        })
        
        // if user login error, close fbsession everytime.
        FBSession.activeSession().closeAndClearTokenInformation()
        // clear settings
        var ud = NSUserDefaults.standardUserDefaults()
        ud.setObject(nil, forKey: "isLogin")
        ud.setObject(nil, forKey: "loginTpye")
        ud.setObject(nil, forKey: "smallFBProfilePhoto")
        ud.setObject(nil, forKey: "bigFBProfilePhoto")
        ud.setObject(nil, forKey: "ColorgyAccessToken")
        ud.setObject(nil, forKey: "ColorgyCreatedTime")
        ud.setObject(nil, forKey: "ColorgyExpireTime")
        ud.setObject(nil, forKey: "ColorgyRefreshToken")
        ud.setObject(nil, forKey: "ColorgyTokenType")
        ud.setObject(nil, forKey: "courseDataFromServer")
        ud.setObject(nil, forKey: "userName")
        ud.setObject(nil, forKey: "userSchool")
        ud.synchronize()

        errorAlert.addAction(dismiss)
        self.presentViewController(errorAlert, animated: true, completion: nil)
    }
    
    // MARK: - textfield delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField == self.userAccount {
            self.userPassword.becomeFirstResponder()
        } else if textField == self.userPassword {
            println("login GO!")
            self.view.endEditing(true)
            NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: "passwordLoginButtonTouchUpInside", userInfo: nil, repeats: false)
        }
        
        return true
    }
    
    // MARK: - login animation
    
    func animateLogoOff() {
        println("offff")
        
        var transDown: CGAffineTransform!

        if self.view.frame.height <= 480 {
            // iphone 4s
            transDown = CGAffineTransformMakeTranslation(0, -518 + 30)
        } else if self.view.frame.height <= 568 {
            // for 5 and 5s
            transDown = CGAffineTransformMakeTranslation(0, -430 + 30)
        } else if self.view.frame.height <= 667 {
            // iphone 6
            transDown = CGAffineTransformMakeTranslation(0, -330 + 30)
        } else {
            // for 6+
            transDown = CGAffineTransformMakeTranslation(0, -261 + 30)
        }
        
        // animate down
        UIView.animateWithDuration(0.5, delay: 0.5, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.colorgyLogo.transform = transDown
            }, completion: nil)
        UIView.animateWithDuration(0.5, delay: 0.5, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.loginBackground.transform = transDown
            }, completion: nil)
        // animate up
        UIView.animateWithDuration(1, delay: 1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: nil, animations: {
                self.colorgyLogo.transform = CGAffineTransformMakeTranslation(0, -1000)
            }, completion: nil)
        UIView.animateWithDuration(1, delay: 1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: nil, animations: {
                self.loginBackground.transform = CGAffineTransformMakeTranslation(0, -1000)
            }, completion: nil)
        
        // fade out buttons
        UIView.animateWithDuration(0.5, animations: {
            self.loginSwitchButton.alpha = 0
            self.facebookLoginButton.alpha = 0
            self.userAccount.alpha = 0
            self.userPassword.alpha = 0
            self.passwordLoginButton.alpha = 0
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - account password login regin
    func requestColorgyOAuthAccessTokenWithUserName(username: String, password: String) {
        
        let afManager = AFHTTPSessionManager(baseURL: NSURL(string: "https://colorgy.io/oauth/token"))
        
        afManager.requestSerializer = AFJSONRequestSerializer()
        afManager.responseSerializer = AFJSONResponseSerializer()
        
        let params = [
            "grant_type": "password",
            // 應用程式ID application id, in colorgy server
            "client_id": "ad2d3492de7f83f0708b5b1db0ac7041f9179f78a168171013a4458959085ba4",
            "client_secret": "d9de77450d6365ca8bd6717bbf8502dfb4a088e50962258d5d94e7f7211596a3",
            "username": username,
            "password": password,
            "scope": "public account offline_access"
        ]
        
        // hide switch while posting
        self.loginSwitchButton.hidden = true
        
        afManager.POST("https://colorgy.io/oauth/token", parameters: params, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) in
            println("succccc post")
            println(responseObject)
            
            let access_token = responseObject["access_token"] as! String
            let created_at = String(stringInterpolationSegment: responseObject["created_at"])
            let expires_in = String(stringInterpolationSegment: responseObject["expires_in"])
            let refresh_token = responseObject["refresh_token"] as! String
            let token_type = responseObject["token_type"] as! String
            
            // wait for animation to finish, then store login info
            var delay = dispatch_time(DISPATCH_TIME_NOW, Int64( 1 * Double(NSEC_PER_SEC)))
            dispatch_after(delay, dispatch_get_main_queue()) {
                self.userSuccessfullyLoginToColorgyWithToken(access_token, created_at: created_at, expires_in: expires_in, refresh_token: refresh_token, token_type: token_type, loginType: "account")
            }
            afManager.GET("https://colorgy.io/api/v1/me?access_token=" + access_token, parameters: nil, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) in

                    let name = responseObject["name"] as! String
                    var ud = NSUserDefaults.standardUserDefaults()
                    ud.setObject(name, forKey: "userName")
                    ud.synchronize()
                }, failure: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) in
                    
                })
            
            }, failure: { (task: NSURLSessionDataTask!, error: NSError!) in
                println("error post")
                self.alertUserWithError("登入時發生錯誤！請確認帳號密碼無誤！如果忘記帳號與密碼，請到\nhttp://colorgy.io\n查詢。")
                // show switch if user got a error while login
                
                println(error)
                self.loginSwitchButton.hidden = false
            })
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
