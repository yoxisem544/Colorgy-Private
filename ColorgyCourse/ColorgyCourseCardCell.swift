//
//  ColorgyCourseCardCell.swift
//  ColorgyCourse
//
//  Created by David on 2015/5/16.
//  Copyright (c) 2015年 David. All rights reserved.
//

import UIKit

class ColorgyCourseCardCell: UITableViewCell {

    @IBOutlet weak var cardBackgroundView: UIView!
    
    @IBOutlet weak var code: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var period: UILabel!
    @IBOutlet weak var name: UILabel!

    
    @IBOutlet weak var lecturerBackgorundView: UIView!
    @IBOutlet weak var lecturer: UILabel!
    @IBOutlet weak var credits: UILabel!
    @IBOutlet weak var creditsBackgroundView: UIView!
    
    @IBOutlet weak var addButton: UIButton!
    
    
    
    var colorgyDarkGray = UIColor(red: 74/255.0, green: 74/255.0, blue: 74/255.0, alpha: 1)
    var colorgyDimOrange = UIColor(red: 226/255.0, green: 109/255.0, blue: 90/255.0, alpha: 1)
    var colorgyLightOrange = UIColor(red: 248/255.0, green: 150/255.0, blue: 128/255.0, alpha: 1)
    var colorgyBackgroundColor: UIColor = UIColor(red: 250/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // change card color
        self.cardBackgroundView.backgroundColor = self.colorgyLightOrange
        self.cardBackgroundView.layer.masksToBounds = true
        self.cardBackgroundView.layer.cornerRadius = 8
        
        // lecturer color
        self.lecturerBackgorundView.backgroundColor = self.colorgyDimOrange
        
        // credit color
        self.creditsBackgroundView.backgroundColor = UIColor.whiteColor()
        
        // style of cell
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.backgroundColor = self.colorgyBackgroundColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
