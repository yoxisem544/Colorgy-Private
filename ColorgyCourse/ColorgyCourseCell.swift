//
//  ColorgyCourseCell.swift
//  ColorgyCourse
//
//  Created by David on 2015/5/4.
//  Copyright (c) 2015年 David. All rights reserved.
//

import UIKit

class ColorgyCourseCell: UITableViewCell {

    @IBOutlet weak var verticalSeparatorLine: UIView!
    var colorgyOrange: UIColor = UIColor(red: 246/255.0, green: 150/255.0, blue: 114/255.0, alpha: 1)

    @IBOutlet weak var horizontalSeparatorLine: UIView!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var teacher: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var location: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // style of cell
        // set separator line color, and backgroundcolor
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.verticalSeparatorLine.backgroundColor = UIColor.whiteColor()
        self.horizontalSeparatorLine.backgroundColor = UIColor.whiteColor()
        self.contentView.backgroundColor = self.colorgyOrange
        
        // set text color
        self.name.textColor = UIColor.whiteColor()
        self.teacher.textColor = UIColor.whiteColor()
        self.time.textColor = UIColor.whiteColor()
        self.location.textColor = UIColor.whiteColor()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
