//
//  ColorgySideMenuViewController.swift
//  
//
//  Created by David on 2015/5/5.
//
//

import UIKit

class ColorgySideMenuViewController: UIViewController {
    
    var colorgyDarkGray: UIColor = UIColor(red: 59/255.0, green: 58/255.0, blue: 59/255.0, alpha: 1)
    var colorgyDimOrange: UIColor = UIColor(red: 228/255.0, green: 133/255.0, blue: 111/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        println("load")
        
        self.view.backgroundColor = self.colorgyDarkGray
        self.setupProfilePhoto()
        self.setupWave()
        
        self.setupButtonWith("選課", action: "pushSegueToselectCourse:", order: 1)
        self.setupButtonWith("課表", action: "pushSegueToTimetable:", order: 2)
        self.setupButtonWith("關於我們", action: "kj", order: 3)
        
    }
    
    func setupProfilePhoto() {
        
        var profile = UIImageView(frame: CGRectMake(39, 60, 62, 62))
        profile.backgroundColor = UIColor.grayColor()
        profile.layer.cornerRadius = 31
        profile.layer.borderWidth = 3
        profile.layer.borderColor = UIColor.whiteColor().CGColor
        profile.image = UIImage(named: "HoungYu")
        profile.layer.masksToBounds = true
        
        self.view.addSubview(profile)
    }
    
    func setupWave() {
        
        var waveImg = UIImage(named: "wave")
        var w = waveImg?.size.width
        var h = waveImg?.size.height
        println(h)
        
        var wave = UIImageView(frame: CGRectMake(0, 150, w!, h!))
        wave.image = waveImg
        
        self.view.addSubview(wave)
    }
    
    func setupButtonWith(title: String, action: String, order: Int) {
        
        var offset = CGFloat(150 + 43) + CGFloat(order - 1) * 75 + 0.5 * CGFloat(order)
        
        var button = UIButton(frame: CGRectMake(0, offset, 140, 75))
        var titleLabel = UILabel(frame: CGRectMake(0, 33, 140, 30))
        
        titleLabel.text = title
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.textColor = UIColor.whiteColor()
        
        var pinImg = UIImage(named: "Pin")
        var w = pinImg?.size.width
        var h = pinImg?.size.height
        var pin = UIImageView(frame: CGRectMake(0, 18, w!, h!))
        pin.center.x = button.center.x
        pin.image = pinImg
        
        button.backgroundColor = self.colorgyDimOrange
        button.addSubview(titleLabel)
        button.addSubview(pin)
        
        // hook push segue
        button.addTarget(self, action: NSSelectorFromString(action), forControlEvents: UIControlEvents.TouchUpInside)
        button.addTarget(self, action: "buttonTouchDragEnter:", forControlEvents: UIControlEvents.TouchDragEnter)
        button.addTarget(self, action: "buttonTouchDragExit:", forControlEvents: UIControlEvents.TouchDragExit)
        button.addTarget(self, action: "buttonTouchDown:", forControlEvents: UIControlEvents.TouchDown)
        
        
        self.view.addSubview(button)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logout(sender: AnyObject) {
        var ud = NSUserDefaults.standardUserDefaults()
        ud.setObject(nil, forKey: "isLogin")
        FBSession.activeSession().closeAndClearTokenInformation()
        ud.synchronize()
    }
    
    
    // MARK: - button behavior
    func buttonTouchDown(sender: UIButton) {
        sender.alpha = 0.77
    }
    
    func buttonTouchDragEnter(sender: UIButton) {
        sender.alpha = 0.77
    }
    
    func buttonTouchDragExit(sender: UIButton) {
        sender.alpha = 1.0
    }
    
    // MARK: - push segue region
    func pushSegueToTimetable(sender: UIButton) {
        sender.alpha = 1.0
        performSegueWithIdentifier("timetable", sender: self)
    }
    
    func pushSegueToselectCourse(sender: UIButton) {
        sender.alpha = 1.0
        performSegueWithIdentifier("selectCourse", sender: self)
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
