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
    @NSManaged var location: String!
    @NSManaged var teacher: String!
    @NSManaged var time: String!
}
