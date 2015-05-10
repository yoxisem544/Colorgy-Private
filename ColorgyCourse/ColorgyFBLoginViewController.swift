//
//  ColorgyFBLoginViewController.swift
//  ColorgyTimeTable
//
//  Created by David on 2015/4/27.
//  Copyright (c) 2015年 David. All rights reserved.
//

import UIKit

class ColorgyFBLoginViewController: UIViewController {
    
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
    
    // MARK: - view
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // keyboard
        
        
        // setup logo and backgorun
        self.setupLogoAndBackgorund()
        self.hideLogoBackground(false)
        self.showLogoAndBackground()
        
        // password and account login
        self.setupUserPasswordAndAccount()
        self.hideUserPasswordAndAccount()
//        self.showUserPasswordAndAccount(1.3)
        
        self.setupFacebookLoginButton()
        self.hideFacebookButton()
        self.showFacebookButton(1.3)
        
        self.setupLoginSwitchButton()
        self.loginMode = "password"
        println(self.view.frame)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    // MARKL - setup switch login button
    func setupLoginSwitchButton() {
        self.loginSwitchButton = UIButton(frame: CGRectMake(0, 0, 180, 20))
        self.loginSwitchButton.setTitle("hi", forState: UIControlState.Normal)
        self.loginSwitchButton.center = CGPointMake(self.view.center.x, self.view.center.y+200)
        
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
        if self.loginMode == "password" {
            self.loginMode = "fb"
            self.loginSwitchButton.setTitle("password", forState: UIControlState.Normal)
            self.hideUserPasswordAndAccount()
            self.showFacebookButton(0)
        } else {
            self.loginMode = "password"
            self.loginSwitchButton.setTitle("facebook", forState: UIControlState.Normal)
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
        
        self.loginSwitchButton.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: alpha), forState: UIControlState.Normal)
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
        w = logo?.size.width
        h = logo?.size.height
        
        // resize with varius screen
        if self.view.frame.height == 667 {
            // for iPhone 6
            
        } else if self.view.frame.height == 568 {
            // for iPhone 5S
            w = w! * CGFloat(320 / 375.0)
            h = h! * CGFloat(320 / 375.0)
        } else if self.view.frame.height == 736 {
            // for 6+
            w = w! * CGFloat(411 / 375.0)
            h = h! * CGFloat(411 / 375.0)
        } else if self.view.frame.height == 480 {
            // for 4s
            w = w! * CGFloat(320 / 375.0)
            h = h! * CGFloat(320 / 375.0)
        }
        
        self.colorgyLogo = UIImageView(frame: CGRectMake(0, 0, w!, h!))
        self.colorgyLogo.image = logo
        self.colorgyLogo.center.x = self.view.center.x
        self.colorgyLogo.center.y = self.view.center.y * 0.6
        
        self.view.backgroundColor = UIColor(red: 113/255.0, green: 112/255.0, blue: 113/255.0, alpha: 1)
        
        self.view.addSubview(self.colorgyLogo)
    }
    
    
    
    func hideLogoBackground(animated: Bool) {
        
        if animated {
            
        } else {
            if self.view.frame.height == 667 {
                // for iPhone 6
                self.loginBackground.transform = CGAffineTransformMakeTranslation(0, -850)
            } else if self.view.frame.height == 568 {
                // for iPhone 5S
                self.loginBackground.transform = CGAffineTransformMakeTranslation(0, -850)
            } else if self.view.frame.height == 736 {
                // for 6+
                self.loginBackground.transform = CGAffineTransformMakeTranslation(0, -850)
            } else if self.view.frame.height == 480 {
                // for 4s
                self.loginBackground.transform = CGAffineTransformMakeTranslation(0, -850)
            }
            self.colorgyLogo.transform = CGAffineTransformMakeScale(0, 0)
        }
    }
    
    func showLogoAndBackground() {
        
        var transDown: CGAffineTransform!
        if self.view.frame.height == 667 {
            // for iPhone 6
            transDown = CGAffineTransformMakeTranslation(0, -330)
        } else if self.view.frame.height == 568 {
            // for iPhone 5S
            transDown = CGAffineTransformMakeTranslation(0, -430)
        } else if self.view.frame.height == 736 {
            // for 6+
            transDown = CGAffineTransformMakeTranslation(0, -261)
        } else if self.view.frame.height == 480 {
            // for 4s
            transDown = CGAffineTransformMakeTranslation(0, -518)
        }
        
        UIView.animateWithDuration(1.0, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: nil, animations: {
                self.loginBackground.transform = transDown
            }, completion: nil)
        UIView.animateWithDuration(0.7, delay: 0.7, usingSpringWithDamping: 0.6, initialSpringVelocity: 1.0, options: nil, animations: {
                var makeAppear = CGAffineTransformMakeScale(1, 1)
                self.colorgyLogo.transform = makeAppear
            }, completion: nil)
    }
    
    
    // MARK: - Facebook setup region
    func setupFacebookLoginButton() {
        self.facebookLoginButton = UIButton(frame: CGRectMake(0, 0, 226, 48))
        self.facebookLoginButton.setImage(UIImage(named: "FacebookLogin"), forState: UIControlState.Normal)
        
        self.facebookLoginButton.center = CGPointMake(self.view.center.x, self.view.center.y + 130)
        
        self.view.addSubview(self.facebookLoginButton)
        
        // add target to fb login button.
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
    
    // MARK: - setup up Account and Password
    func setupUserPasswordAndAccount() {
        
        var textFieldWidth: CGFloat! = 250
        if self.view.frame.height == 667 {
            // for iPhone 6
            textFieldWidth = textFieldWidth * (375 / 375)
        } else if self.view.frame.height == 568 {
            // for iPhone 5S
            textFieldWidth = textFieldWidth * (320 / 375)
        } else if self.view.frame.height == 736 {
            // for 6+
            textFieldWidth = textFieldWidth * (414 / 375)
        } else if self.view.frame.height == 480 {
            // for 4s
            textFieldWidth = textFieldWidth * (320 / 375)
        }
        
        // password login items
        self.userPassword = UITextField(frame: CGRectMake(0, 0, textFieldWidth, 30))
        self.userPassword.borderStyle = UITextBorderStyle.RoundedRect
        self.userPassword.placeholder = "password"
        self.userPassword.center.x = self.view.center.x
        self.userPassword.center.y = self.view.center.y + 50
        self.view.addSubview(self.userPassword)
        
        self.userAccount = UITextField(frame: CGRectMake(0, 0, textFieldWidth, 30))
        self.userAccount.borderStyle = UITextBorderStyle.RoundedRect
        self.userAccount.placeholder = "account"
        self.userAccount.center.x = self.view.center.x
        self.userAccount.center.y = self.view.center.y
        self.view.addSubview(self.userAccount)
        
        // button
        self.passwordLoginButton = UIButton(frame: CGRectMake(0, 0, 150, 45))
        self.passwordLoginButton.setTitle("Login", forState: UIControlState.Normal)
        self.passwordLoginButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.passwordLoginButton.backgroundColor = UIColor.grayColor()
        self.passwordLoginButton.layer.cornerRadius = 10

        
        self.passwordLoginButton.center = CGPointMake(self.view.center.x, self.view.center.y + 130)
        self.view.addSubview(self.passwordLoginButton)
    }
    
    func hideUserPasswordAndAccount() {

        self.userPassword.transform = CGAffineTransformMakeScale(0, 0)
        self.userAccount.transform = CGAffineTransformMakeScale(0, 0)
        self.passwordLoginButton.transform = CGAffineTransformMakeScale(0, 0)
    }
    
    func showUserPasswordAndAccount(delay: NSTimeInterval) {
        
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
                    
//                    println(session.accessTokenData.accessToken)
//                    FBSession.activeSession().closeAndClearTokenInformation()
                    if session.accessTokenData != nil {
                        self.requestColorgyOAuthAccessTokenWithFBToken(session.accessTokenData.accessToken)
                    } else {
                        println("fuc!!!!!")
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
        
        let params = [
            "grant_type": "password",
            "client_id": "de323349f404663158c5fbd8f149c126040371128cddbf4702b3d8d40206d29c",
            "client_secret": "54178a05f5c0980f2a42ed41090e4dcce31c2a86787fa1d329c596afe1edacb2",
            "username": "facebook:access_token",
            "password": token,
            "scope": "public account offline_access"
        ]
        
        afManager.POST("https://colorgy.io/oauth/token", parameters: params, success: { (task:NSURLSessionDataTask!, responseObject: AnyObject!) in
                println("succccc post")
                println(responseObject)
            
                let access_token = responseObject["access_token"] as! String
                let created_at = String(stringInterpolationSegment: responseObject["created_at"])
                let expires_in = String(stringInterpolationSegment: responseObject["expires_in"])
                let refresh_token = responseObject["refresh_token"] as! String
                let token_type = responseObject["token_type"] as! String
            
                self.animateLogoOff()
            
                // wait for animation to finish, then store login info
                var delay = dispatch_time(DISPATCH_TIME_NOW, Int64( 1 * Double(NSEC_PER_SEC)))
                dispatch_after(delay, dispatch_get_main_queue()) {
                    self.userSuccessfullyLoginToColorgyWithToken(access_token, created_at: created_at, expires_in: expires_in, refresh_token: refresh_token, token_type: token_type)
                }
    
            }, failure: { (task: NSURLSessionDataTask!, error: NSError!) in
                println("error post")
                self.alertUserWithError("與 Colorgy Server 溝通時發生錯誤！")
            })
    }
    
    func userSuccessfullyLoginToColorgyWithToken(token: String, created_at: String, expires_in: String, refresh_token: String, token_type: String) {
        
        var ud = NSUserDefaults.standardUserDefaults()
        ud.setObject(token, forKey: "ColorgyAccessToken")
        ud.setObject(created_at, forKey: "ColorgyCreatedTime")
        ud.setObject(expires_in, forKey: "ColorgyExpireTime")
        ud.setObject(refresh_token, forKey: "ColorgyRefreshToken")
        ud.setObject(token_type, forKey: "ColorgyTokenType")
        
        // set user login type as fb
        ud.setObject("fb", forKey: "isLogin")
        
        // sync setting
        ud.synchronize()
        
        println("ready to switch view")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var vc = storyboard.instantiateViewControllerWithIdentifier("ColorgyService") as! SWRevealViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func alertUserWithError(error: String) {
        
        let errorAlert = UIAlertController(title: "哦！出錯了！😨", message: "\(error)", preferredStyle: UIAlertControllerStyle.Alert)
        let dismiss = UIAlertAction(title: "知道了！", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction!) -> Void in
            errorAlert.dismissViewControllerAnimated(true, completion: nil)
            // if user login error, close fbsession everytime.
            FBSession.activeSession().closeAndClearTokenInformation()
        })
        errorAlert.dismissViewControllerAnimated(true, completion: {
            
        })
        errorAlert.addAction(dismiss)
        self.presentViewController(errorAlert, animated: true, completion: nil)
    }
    
    // MARK: - login animation
    
    func animateLogoOff() {
        println("offff")
        
        var transDown: CGAffineTransform!
        if self.view.frame.height == 667 {
            // for iPhone 6
            transDown = CGAffineTransformMakeTranslation(0, -330 + 30)
        } else if self.view.frame.height == 568 {
            // for iPhone 5S
            transDown = CGAffineTransformMakeTranslation(0, -430 + 30)
        } else if self.view.frame.height == 736 {
            // for 6+
            transDown = CGAffineTransformMakeTranslation(0, -261 + 30)
        } else if self.view.frame.height == 480 {
            // for 4s
            transDown = CGAffineTransformMakeTranslation(0, -518 + 30)
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
        })
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
