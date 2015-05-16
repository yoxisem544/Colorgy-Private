//
//  NNTableViewCell.swift
//  ColorgyCourse
//
//  Created by David on 2015/5/15.
//  Copyright (c) 2015年 David. All rights reserved.
//

import UIKit

class NNTableViewCell: UITableViewCell {

    @IBOutlet weak var creditView: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var sessionView: UIView!
    
    @IBOutlet weak var creditCount: UILabel!
    
    var colorgyDarkGray = UIColor(red: 74/255.0, green: 74/255.0, blue: 74/255.0, alpha: 1)
    var colorgyDimOrange = UIColor(red: 226/255.0, green: 109/255.0, blue: 90/255.0, alpha: 1)
    var colorgyLightOrange = UIColor(red: 248/255.0, green: 150/255.0, blue: 128/255.0, alpha: 1)

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.creditView.backgroundColor = UIColor.whiteColor()
        self.bgView.backgroundColor = self.colorgyLightOrange
        self.bgView.layer.cornerRadius = 5
        self.bgView.layer.masksToBounds = true
        self.backgroundColor = self.colorgyDarkGray
        
        self.sessionView.backgroundColor = self.colorgyDimOrange
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.creditCount.textAlignment = NSTextAlignment.Center
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
//        self.bgView.alpha = 0.5
    }

}
