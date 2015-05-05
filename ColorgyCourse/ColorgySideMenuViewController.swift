//
//  ColorgySideMenuViewController.swift
//  
//
//  Created by David on 2015/5/5.
//
//

import UIKit

class ColorgySideMenuViewController: UIViewController {

    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var waveImage: UIImageView!
    @IBOutlet weak var personalInfo: UIButton!
    @IBOutlet weak var editTimetable: UIButton!
    @IBOutlet weak var aboutUs: UIButton!
    
    var colorgyDarkGray: UIColor = UIColor(red: 59/255.0, green: 58/255.0, blue: 59/255.0, alpha: 1)
    var colorgyDimOrange: UIColor = UIColor(red: 228/255.0, green: 133/255.0, blue: 111/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        println("load")
        self.view.backgroundColor = self.colorgyDarkGray
        self.profilePhoto.image = UIImage(named: "HoungYu")
        self.profilePhoto.layer.cornerRadius = 35
        self.profilePhoto.layer.masksToBounds = true
        self.profilePhoto.layer.borderWidth = 3
        self.profilePhoto.layer.borderColor = UIColor.whiteColor().CGColor
        
        self.userName.textColor = UIColor.whiteColor()
        self.userName.text = "大魟魚"
        
        self.waveImage.image = UIImage(named: "wave")
        
        self.personalInfo.backgroundColor = self.colorgyDimOrange
        self.editTimetable.backgroundColor = self.colorgyDimOrange
        self.aboutUs.backgroundColor = self.colorgyDimOrange
        
        self.personalInfo.setTitle("個人資料", forState: UIControlState.Normal)
        self.editTimetable.setTitle("編輯課表", forState: UIControlState.Normal)
        self.aboutUs.setTitle("關於我們", forState: UIControlState.Normal)
        
        self.personalInfo.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.editTimetable.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.aboutUs.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
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
