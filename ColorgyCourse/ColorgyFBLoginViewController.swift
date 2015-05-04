//
//  ColorgyFBLoginViewController.swift
//  ColorgyTimeTable
//
//  Created by David on 2015/4/27.
//  Copyright (c) 2015年 David. All rights reserved.
//

import UIKit

class ColorgyFBLoginViewController: UIViewController {

    @IBOutlet weak var revealMenuButton: UIBarButtonItem!
    
    var loginBackground: UIImageView!
    var colorgyLogo: UIImageView!
    
    var userAccount: UITextField!
    var userPassword: UITextField!
    
    var passwordLoginButton: UIButton!
    
    // facebook region
    var facebookLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //reveal region
        if self.revealViewController() != nil {
            revealMenuButton.target = self.revealViewController()
            revealMenuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        //
        
        // setup logo and backgorun
        self.setupLogoAndBackgorund()
        self.hideLogoBackground(false)
        self.showLogoAndBackground()
        
        // password and account login
        self.setupUserPasswordAndAccount()
        self.hideUserPasswordAndAccount(false)
        self.showUserPasswordAndAccount()
        
//        self.setupFacebookLoginButton()
//        self.hideFacebookButton(false)
//        self.showFacebookButton()
    }
    
    func setupFacebookLoginButton() {
        self.facebookLoginButton = UIButton(frame: CGRectMake(0, 0, 226, 48))
        self.facebookLoginButton.setImage(UIImage(named: "FacebookLogin"), forState: UIControlState.Normal)
        
        self.facebookLoginButton.center = CGPointMake(self.view.center.x, self.view.center.y + 130)
        
        self.view.addSubview(self.facebookLoginButton)
    }
    
    func setupLogoAndBackgorund() {
        
        var image = UIImage(named: "LoginBackground")
        var w = image?.size.width
        var h = image?.size.height
        self.loginBackground = UIImageView(frame: CGRectMake(0, 0, w!, h!))
        self.loginBackground.center.x = self.view.center.x
        self.loginBackground.image = image
        
        self.view.addSubview(self.loginBackground)
        
        var transformUp = CGAffineTransformMakeTranslation(0, -500)
        self.loginBackground.transform = transformUp
        
        // adding logo
        var logo = UIImage(named: "ColorgyLogo")
        w = logo?.size.width
        h = logo?.size.height
        self.colorgyLogo = UIImageView(frame: CGRectMake(0, 0, w!, h!))
        self.colorgyLogo.image = logo
        self.colorgyLogo.center.x = self.view.center.x
        self.colorgyLogo.center.y = self.view.center.y * 0.6
        
        self.view.backgroundColor = UIColor(red: 113/255.0, green: 112/255.0, blue: 113/255.0, alpha: 1)
        
        self.view.addSubview(self.colorgyLogo)
    }
    
    func hideFacebookButton(animated: Bool) {
        
        if animated {
            
        } else {
            self.facebookLoginButton.transform = CGAffineTransformMakeScale(0, 0)
        }
    }
    
    func showFacebookButton() {
        UIView.animateWithDuration(0.3, delay: 1.3, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.5, options: nil, animations: {
                self.facebookLoginButton.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: nil)
    }
    
    func hideLogoBackground(animated: Bool) {
        
        if animated {
            
        } else {
            self.loginBackground.transform = CGAffineTransformMakeTranslation(0, -500)
            self.colorgyLogo.transform = CGAffineTransformMakeScale(0, 0)
        }
    }
    
    func showLogoAndBackground() {
        
        UIView.animateWithDuration(1.0, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: nil, animations: {
                var transformDown = CGAffineTransformMakeTranslation(0, -50)
                self.loginBackground.transform = transformDown
            }, completion: nil)
        UIView.animateWithDuration(0.7, delay: 0.7, usingSpringWithDamping: 0.6, initialSpringVelocity: 1.0, options: nil, animations: {
                var makeAppear = CGAffineTransformMakeScale(1, 1)
                self.colorgyLogo.transform = makeAppear
            }, completion: nil)
    }
    
    func setupUserPasswordAndAccount() {
        
        // password login items
        self.userPassword = UITextField(frame: CGRectMake(0, 0, 300, 30))
        self.userPassword.borderStyle = UITextBorderStyle.RoundedRect
        self.userPassword.placeholder = "password"
        self.userPassword.center.x = self.view.center.x
        self.userPassword.center.y = self.view.center.y + 50
        self.view.addSubview(self.userPassword)
        
        self.userAccount = UITextField(frame: CGRectMake(0, 0, 300, 30))
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
    
    func hideUserPasswordAndAccount(animated: Bool) {
        
        if animated {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: nil, animations: {
            self.userPassword.transform = CGAffineTransformMakeScale(0, 0)
            }, completion: nil)
        UIView.animateWithDuration(0.5, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: nil, animations: {
            self.userAccount.transform = CGAffineTransformMakeScale(0, 0)
            }, completion: nil)
        UIView.animateWithDuration(0.5, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: nil, animations: {
            self.passwordLoginButton.transform = CGAffineTransformMakeScale(0, 0)
            }, completion: nil)
        } else {
            self.userPassword.transform = CGAffineTransformMakeScale(0, 0)
            self.userAccount.transform = CGAffineTransformMakeScale(0, 0)
            self.passwordLoginButton.transform = CGAffineTransformMakeScale(0, 0)
        }
    }
    
    func showUserPasswordAndAccount() {
        
        UIView.animateWithDuration(0.5, delay: 0.8+0.5, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: nil, animations: {
            self.userAccount.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: nil)
        UIView.animateWithDuration(0.5, delay: 0.9+0.5, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: nil, animations: {
            self.userPassword.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: nil)
        UIView.animateWithDuration(0.5, delay: 1.0+0.5, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: nil, animations: {
            self.passwordLoginButton.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
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
