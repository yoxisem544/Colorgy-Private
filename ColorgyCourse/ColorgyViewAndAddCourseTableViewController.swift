//
//  ColorgyViewAndAddCourseTableViewController.swift
//  ColorgyCourse
//
//  Created by David on 2015/5/4.
//  Copyright (c) 2015年 David. All rights reserved.
//

import UIKit
import CoreData

class ColorgyViewAndAddCourseTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {

    // MARK: - reveal menu
    @IBOutlet weak var revealMenuButon: UIBarButtonItem!
    
    // MARK: - declaration
    var parsedCourseData: NSArray!
    var courseData: NSMutableArray! = NSMutableArray()
    var searchCourse = UISearchController()
    
    var filteredCourse: NSMutableArray! = NSMutableArray()
    
    // MARK: - color
    var colorgyGreen: UIColor = UIColor(red: 228/255.0, green: 133/255.0, blue: 111/255.0, alpha: 1)
//    var colorgyGreen: UIColor = UIColor(red: 42/255.0, green: 171/255.0, blue: 147/255.0, alpha: 1)
    
    // MARK: - view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //reveal region
        if self.revealViewController() != nil {
            revealMenuButon.target = self.revealViewController()
            revealMenuButon.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        self.revealViewController().rearViewRevealWidth = 140
        //
        
        // tableview delegate and datasource
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // tableview style
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        // get json file
        let path = NSBundle.mainBundle().pathForResource("NCKU_samll_course", ofType: "json")
        var e: NSError?
        var courseData = NSData(contentsOfFile: path!)

        self.parsedCourseData = NSJSONSerialization.JSONObjectWithData(courseData!, options: nil, error: &e) as! NSArray
        if e != nil {
            println(e)
        } else {
            // parse json format to nsarray. easier to use
            for c in self.parsedCourseData {
                self.courseData.addObject( [c["course_name"] as! String, c["teacher_name"] as! String, c["time"] as! String, c["classroom"] as! String] )
            }
        }
        
        // setup search controller and its style
        self.searchCourse = UISearchController(searchResultsController: nil)
        self.searchCourse.searchResultsUpdater = self
        self.searchCourse.searchBar.sizeToFit()
        self.searchCourse.searchBar.placeholder = "搜尋並加入課程"
        // i want to select tableview while searching
        self.searchCourse.dimsBackgroundDuringPresentation = false
        // change search abr color
        self.searchCourse.searchBar.tintColor = self.colorgyGreen
        self.searchCourse.searchBar.barTintColor = UIColor(red: 113/255.0, green: 112/255.0, blue: 113/255.0, alpha: 1)
//        self.searchCourse.searchBar.searchBarStyle = UISearchBarStyle.Minimal
        self.tableView.bounces = false
        
        // add search bar to top of tableview
        self.tableView.tableHeaderView = self.searchCourse.searchBar
        
        //style fo search bar
        //if you dont add this, status bar will be ruin by the search
        self.definesPresentationContext = true
        
        self.getDataFromDatabase()
        self.storeDataToDatabase()
        self.isCourseAlreadyAddedToSelectedCourse()
    }
    
    // check if course is already added to selected course
    func isCourseAlreadyAddedToSelectedCourse() {
        
        var name = "digital circuit"
        var teacher = "Mrs. Chen"
        var location = "TR412"
        var time = "R4"
        
        var courses = self.getDataFromDatabase()
        if courses != nil {
            // get data!
            var isRepeated: Bool = false
            for cc in courses! {
                let c = cc as Course
                if c.name == name {
                    if c.teacher == teacher {
                        if c.location == location {
                            if c.time == time {
                                isRepeated = true
                                break
                            }
                        }
                    }
                }
            }
            
            // judge if is already repeated 
            if isRepeated {
                println("yes repeat")
            } else {
                println("no repeat")
            }
        }
    }
    
    // MARK: - operating database
    func getDataFromDatabase() -> [Course]? {
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext {
            let fetchRequest = NSFetchRequest(entityName: "Course")
            var e: NSError?
            var course: [Course] = managedObjectContext.executeFetchRequest(fetchRequest, error: &e) as! [Course]
            if e != nil {
                println("something error")
            } else {
                println("ok")
                for c in course {
                    println(c)
                }
            }
            
            // if sucessfullly get the selected coruse data
            // return it, as [Course] type
            return course
        }
        
        // if something wrong, return nil.
        return nil
    }
    
    // this function help you to store data into db
    func storeDataToDatabase() {
        
        // get out managedObjectContext
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext {
            
            // insert a new course, but not yet saved.
            var course = NSEntityDescription.insertNewObjectForEntityForName("Course", inManagedObjectContext: managedObjectContext) as! Course
            // assign its value to it's key
            course.name = "digital circuit"
            course.teacher = "Mrs. Chen"
            course.location = "TR412"
            course.time = "R4"
            
            var e: NSError?
            // to see if successfully store to db
            if managedObjectContext.save(&e) != true {
                // if i got a error
                println("error \(e)")
            } else {
                // if success
                println("store OK!")
            }
        }
    }
    
    // MARK: - Search bar update and filter
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        println("update!")
        self.filterContentForSearchText(self.searchCourse.searchBar.text)
        self.tableView.reloadData()
    }
    
    func filterContentForSearchText(searchText: String) {
        
        self.filteredCourse = []
        
        for data in self.courseData {
            var d = data as! NSArray
//            println(d)
            var name = d[0] as! String
            var teacher = d[1] as! String
            var time = d[2] as! String
            var location = d[3] as! String
            
            var match: Bool! = false
            
            if name.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil {
                match = true
            }
            if teacher.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil {
                match = true
            }
            if time.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil {
                match = true
            }
            if location.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil {
                match = true
            }
            
            if match! {
                self.filteredCourse.addObject(data)
            }

        }
        
        println(self.filteredCourse.count)
    }
    
    // MARK: - Table view region
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchCourse.active {
            return self.filteredCourse.count
        } else {
            return self.parsedCourseData.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if searchCourse.active {
            var cell = tableView.dequeueReusableCellWithIdentifier("ColorgyCourseCell", forIndexPath: indexPath) as! ColorgyCourseCell

            cell.name.text = self.filteredCourse[indexPath.row][0] as! String
            cell.teacher.text = self.filteredCourse[indexPath.row][1] as! String
            cell.time.text = self.filteredCourse[indexPath.row][2] as! String
            cell.location.text = self.filteredCourse[indexPath.row][3] as! String
            
            return cell
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("ColorgyCourseCell", forIndexPath: indexPath) as! ColorgyCourseCell
            
            cell.name.text = self.parsedCourseData[indexPath.row]["course_name"] as! String
            cell.teacher.text = self.parsedCourseData[indexPath.row]["teacher_name"] as! String
            cell.time.text = self.parsedCourseData[indexPath.row]["time"] as! String
            cell.location.text = self.parsedCourseData[indexPath.row]["classroom"] as! String
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if self.searchCourse.active {
            let optionMenu = UIAlertController(title: "\(self.filteredCourse[indexPath.row][0])", message: "\(self.filteredCourse[indexPath.row][1])\n\(self.filteredCourse[indexPath.row][2])\n\(self.filteredCourse[indexPath.row][3])", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "加入課程", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction!) -> Void in
                
            })
            let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction!) -> Void in
                optionMenu.dismissViewControllerAnimated(true, completion: nil)
            })
            
            optionMenu.addAction(ok)
            optionMenu.addAction(cancel)
            
            self.presentViewController(optionMenu, animated: true, completion: nil)
        }
    }
}
