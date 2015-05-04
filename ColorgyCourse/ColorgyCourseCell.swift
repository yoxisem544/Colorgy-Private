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
    var colorgySeparatorGreen: UIColor = UIColor(red: 54/255.0, green: 191/255.0, blue: 163/255.0, alpha: 1)

    @IBOutlet weak var horizontalSeparatorLine: UIView!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var teacher: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var location: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.verticalSeparatorLine.backgroundColor = self.colorgySeparatorGreen
        self.horizontalSeparatorLine.backgroundColor = self.colorgySeparatorGreen
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
