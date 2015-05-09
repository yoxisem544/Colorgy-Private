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
    
    // filteredcoures is courses that filtered by search text
    var filteredCourse: NSMutableArray! = NSMutableArray()
    
    // courses user added to their timetable
    var coursesAddedToTimetable: NSMutableArray!
    
    // background dimmer view
    var dimmer: UIView!
    
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
        let path = NSBundle.mainBundle().pathForResource("CCU_courses", ofType: "json")
        var e: NSError?
        var courseData = NSData(contentsOfFile: path!)

        self.parsedCourseData = NSJSONSerialization.JSONObjectWithData(courseData!, options: nil, error: &e) as! NSArray
        if e != nil {
            println(e)
        } else {
            // parse json format to nsarray. easier to use
            for c in self.parsedCourseData {
                self.courseData.addObject( [c["name"] as! String, c["lecturer"] as! String, c["periods"] as! NSArray, c["credits"] as! Int] )
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
        
//        self.searchCourse.dimsBackgroundDuringPresentation = true

        // add search bar to top of tableview
        self.tableView.tableHeaderView = self.searchCourse.searchBar
        
        //style fo search bar
        //if you dont add this, status bar will be ruin by the search
        self.definesPresentationContext = true
        
//        self.getDataFromDatabase()
//        self.storeDataToDatabase()
//        self.isCourseAlreadyAddedToSelectedCourse()
        
        // fetch data at the very begining
        self.fetchDataAndUpdateSelectedCourses()
        
        // dimmer test region
        self.dimmer = UIView(frame: CGRectMake(0, 44, self.view.frame.width, self.view.frame.height))
        self.dimmer.backgroundColor = UIColor.blackColor()
        self.dimmer.alpha = 0.5
        self.tableView.addSubview(self.dimmer)
        self.dimmer.hidden = true
    }
    
    // check if course is already added to selected course
    func isCourseAlreadyAddedToSelectedCourse(course: NSArray) -> Bool{
        
        var name = course[0] as! String
        var teacher = course[1] as! String
        var location = course[2] as! String
        var time = course[3] as! String
        
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
            
            return isRepeated
        }
        
        // empty course
        return false
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
                println("ok count: \(course.count)")
            }
            
            // if sucessfullly get the selected coruse data
            // return it, as [Course] type
            return course
        }
        
        // if something wrong, return nil.
        return nil
    }
    
    // this function help you to store data into db
    func storeDataToDatabase(courseToAdd: NSArray) {
        
        println("store")
        // get out managedObjectContext
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext {
            
            // insert a new course, but not yet saved.
            var course = NSEntityDescription.insertNewObjectForEntityForName("Course", inManagedObjectContext: managedObjectContext) as! Course
            // assign its value to it's key
            course.name = courseToAdd[0] as! String
            course.teacher = courseToAdd[1] as! String
            course.location = courseToAdd[2] as! String
            course.time = courseToAdd[3] as! String
            
            println(course.name)
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
    
    func fetchDataAndUpdateSelectedCourses() {
        
        // first get out the data from db
        if let coursesFromDB = self.getDataFromDatabase() {
            // if successfully get course data, parse it.

            // if courseaddedtotimetable is nil, alloc it.
            // or if there are some data in it re alloc it to make it a clean table.
            // then get data from db again
            self.coursesAddedToTimetable = NSMutableArray()

            for c in coursesFromDB {
                self.coursesAddedToTimetable.addObject([c.name, c.teacher, c.time, c.location])
            }
        }
        // after getting data from db
        // reload tableview
        self.tableView.reloadData()
    }
    
    // MARK: - Search bar update and filter
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        println("update!")
        self.filterContentForSearchText(self.searchCourse.searchBar.text)
        self.tableView.reloadData()
        
        if self.searchCourse.active && self.searchCourse.searchBar.text != "" {
            // user is searching course
            // do something if user is using search bar
            // light up backgoround view if user is searching
            self.dimmerViewisOn(false)
        } else {
            // user is viewing selected courses
            // display it to user
            self.fetchDataAndUpdateSelectedCourses()
            // dim backgoround view if user is not searching
            if self.searchCourse.active {
                // if user is searching but not entering anything, dim the view
                self.dimmerViewisOn(true)
            } else {
                // if user leave search, light up view
                self.dimmerViewisOn(false)
            }
        }
    }
    
    func dimmerViewisOn(isOn: Bool) {

        if isOn {
            self.dimmer.hidden = false
        } else {
            self.dimmer.hidden = true
        }
        
    }
    
    
    func filterContentForSearchText(searchText: String) {
        
        self.filteredCourse = []
        
        for data in self.courseData {
            var d = data as! NSArray
//            println(d)
            var name = d[0] as! String
            var teacher = d[1] as! String
            var periods = d[2] as! NSArray
            var location = "\(d[3])"
            
            var match: Bool! = false
            
            if name.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil {
                match = true
            }
            if teacher.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil {
                match = true
            }
            for p in periods {
                if let location = p[2]{
                    let loca = location as! String
                    if loca.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil {
                        match = true
                    }
                }
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
        
        if searchCourse.active && self.searchCourse.searchBar.text != "" {
            // dim view alittle if user is not yet entering any keywords.
                return self.filteredCourse.count
            
        } else {
            if self.coursesAddedToTimetable == nil {
                // if there is nothing in it, fetch data from db
                self.fetchDataAndUpdateSelectedCourses()
            }
            return self.coursesAddedToTimetable.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if searchCourse.active && searchCourse.searchBar.text != "" {
            var cell = tableView.dequeueReusableCellWithIdentifier("ColorgyCourseCell", forIndexPath: indexPath) as! ColorgyCourseCell

            cell.name.text = self.filteredCourse[indexPath.row][0] as! String
            cell.teacher.text = self.filteredCourse[indexPath.row][1] as! String
            cell.time.text = self.filteredCourse[indexPath.row][2][0] as! String
            cell.location.text = "\(self.filteredCourse[indexPath.row][3])"
            
            return cell
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("ColorgyCourseCell", forIndexPath: indexPath) as! ColorgyCourseCell
            
//            cell.name.text = self.parsedCourseData[indexPath.row]["course_name"] as! String
//            cell.teacher.text = self.parsedCourseData[indexPath.row]["teacher_name"] as! String
//            cell.time.text = self.parsedCourseData[indexPath.row]["time"] as! String
//            cell.location.text = self.parsedCourseData[indexPath.row]["classroom"] as! String
            
            cell.name.text = self.coursesAddedToTimetable[indexPath.row][0] as! String
            cell.teacher.text = self.coursesAddedToTimetable[indexPath.row][1] as! String
            cell.time.text = self.coursesAddedToTimetable[indexPath.row][2] as! String
            cell.location.text = self.coursesAddedToTimetable[indexPath.row][3] as! String
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if self.searchCourse.active {
            
            // get out all the data, easy to read.
            let name = self.filteredCourse[indexPath.row][0] as! String
            let teacher = self.filteredCourse[indexPath.row][1] as! String
            let time = self.filteredCourse[indexPath.row][2] as! String
            let location = self.filteredCourse[indexPath.row][3] as! String
            let optionMenu = UIAlertController(title: "\(name)", message: "\(teacher)\n\(time)\n\(location)", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "加入課程", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction!) -> Void in
                var packedCourseArray = [name , teacher, time, location] as NSArray
                if !self.isCourseAlreadyAddedToSelectedCourse(packedCourseArray) {
                    // if this course is not selected...... add it
                    self.storeDataToDatabase(packedCourseArray)
                }
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
