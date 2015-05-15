//
//  Course.swift
//  ColorgyTimeTable
//
//  Created by David on 2015/5/1.
//  Copyright (c) 2015年 David. All rights reserved.
//

import Foundation
import CoreData

class Course: NSManagedObject {
   
    @NSManaged var name: String!
    @NSManaged var lecturer: String!
    @NSManaged var periods: NSData!
    @NSManaged var credits: Int
    @NSManaged var uuid: String!
}
