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
    // course data parsed from json file, save it as a array
    var parsedCourseData: NSArray!
    // parse parsedCourseData in to courseData, for easier usage
    var courseData: NSMutableArray! = NSMutableArray()
    // search controller, let this view able to search.
    var searchCourse = UISearchController()
    
    // filteredcoures is courses that filtered by search text
    var filteredCourse: NSMutableArray! = NSMutableArray()
    
    // courses user added to their timetable
    var coursesAddedToTimetable: NSMutableArray!
    
    // background dimmer view
    var dimmer: UIView!
    
    // MARK: - color
    var colorgyGreen: UIColor = UIColor(red: 228/255.0, green: 133/255.0, blue: 111/255.0, alpha: 1)
    var colorgyDarkGray = UIColor(red: 74/255.0, green: 74/255.0, blue: 74/255.0, alpha: 1)
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
        self.tableView.backgroundColor = self.colorgyDarkGray
        // navi style
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // get json file
//        let path = NSBundle.mainBundle().pathForResource("CCU_courses", ofType: "json")
        var e: NSError?
//        var courseData = NSData(contentsOfFile: path!)
        
        // fetch data
        var ud = NSUserDefaults.standardUserDefaults()
        // first init self.parsedCourseData
        self.parsedCourseData = []
        if ud.objectForKey("courseFromServer") != nil {
            var courseData = NSData(data: ud.objectForKey("courseFromServer") as! NSData)
            
            self.parsedCourseData = self.unarchive(courseData)
            println("length is \(self.parsedCourseData.count)")
            if e != nil {
                println(e)
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
        self.searchCourse.searchBar.tintColor = UIColor.whiteColor()
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
    
    // MARK: - Fetch data from server
    
    
    // MARK: - compare data
    
    // check if course is already added to selected course
    func isCourseAlreadyAddedToSelectedCourse(code: String) -> Bool{
        
        var courses = self.getDataFromDatabase()
        if courses != nil {
            // get data!
            var isRepeated: Bool = false
            for cc in courses! {
                let c = cc as Course
                if c.uuid == code {
                    isRepeated = true
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
    func storeDataToDatabase(name: String, lecturer: String, credits: Int, uuid: String, sessions: AnyObject) {
        
        println("store")
        // get out managedObjectContext
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext {
            
            // insert a new course, but not yet saved.
            var course = NSEntityDescription.insertNewObjectForEntityForName("Course", inManagedObjectContext: managedObjectContext) as! Course
            // assign its value to it's key
            course.name = name
            course.lecturer = lecturer
            course.credits = credits as Int
            course.uuid = uuid
            
            course.day_1 = sessions[0][0] as! String
            course.day_2 = sessions[1][0] as! String
            course.day_3 = sessions[2][0] as! String
            course.day_4 = sessions[3][0] as! String
            course.day_5 = sessions[4][0] as! String
            course.day_6 = sessions[5][0] as! String
            course.day_7 = sessions[6][0] as! String
            course.day_8 = sessions[7][0] as! String
            course.day_9 = sessions[8][0] as! String
            
            course.period_1 = sessions[0][1] as! String
            course.period_2 = sessions[1][1] as! String
            course.period_3 = sessions[2][1] as! String
            course.period_4 = sessions[3][1] as! String
            course.period_5 = sessions[4][1] as! String
            course.period_6 = sessions[5][1] as! String
            course.period_7 = sessions[6][1] as! String
            course.period_8 = sessions[7][1] as! String
            course.period_9 = sessions[8][1] as! String
            
            course.location_1 = sessions[0][2] as! String
            course.location_2 = sessions[1][2] as! String
            course.location_3 = sessions[2][2] as! String
            course.location_4 = sessions[3][2] as! String
            course.location_5 = sessions[4][2] as! String
            course.location_6 = sessions[5][2] as! String
            course.location_7 = sessions[6][2] as! String
            course.location_8 = sessions[7][2] as! String
            course.location_9 = sessions[8][2] as! String
     
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

    
    // fetch data and update view, this function will update selected course.
    // these data are from db
    func fetchDataAndUpdateSelectedCourses() {
        
        // first get out the data from db
        if let coursesFromDB = self.getDataFromDatabase() {
            // if successfully get course data, parse it.

            // if courseaddedtotimetable is nil, alloc it.
            // or if there are some data in it re alloc it to make it a clean table.
            // then get data from db again
            self.coursesAddedToTimetable = NSMutableArray()

            for c in coursesFromDB {
                let weekdays = ["Mon", "Tue", "wed", "Thu", "Fri", "Sat", "Sun"]
                var location = ""
                var period = ""
                
                if c.day_1 != "<null>" {
                    period += weekdays[c.day_1.toInt()!] + c.period_1 + " "
                    location += c.location_1 + " "
                }
                if c.day_2 != "<null>" {
                    period += weekdays[c.day_2.toInt()!] + c.period_2 + " "
                    location += c.location_2 + " "
                }
                if c.day_3 != "<null>" {
                    period += weekdays[c.day_3.toInt()!] + c.period_3 + " "
                    location += c.location_3 + " "
                }
                if c.day_4 != "<null>" {
                    period += weekdays[c.day_4.toInt()!] + c.period_4 + " "
                    location += c.location_4 + " "
                }
                if c.day_5 != "<null>" {
                    period += weekdays[c.day_5.toInt()!] + c.period_5 + " "
                    location += c.location_5 + " "
                }
                if c.day_6 != "<null>" {
                    period += weekdays[c.day_6.toInt()!] + c.period_6 + " "
                    location += c.location_6 + " "
                }
                if c.day_7 != "<null>" {
                    period += weekdays[c.day_7.toInt()!] + c.period_7 + " "
                    location += c.location_7 + " "
                }
                if c.day_8 != "<null>" {
                    period += weekdays[c.day_8.toInt()!] + c.period_8 + " "
                    location += c.location_8 + " "
                }
                if c.day_9 != "<null>" {
                    period += weekdays[c.day_9.toInt()!] + c.period_9 + " "
                    location += c.location_9 + " "
                }
                
                
                self.coursesAddedToTimetable.addObject([c.name, c.lecturer, c.credits, c.uuid, period, location])
            }
        }
        // after getting data from db
        // reload tableview
        self.tableView.reloadData()
    }
    
    // MARK: - compress data
    
    func archive(array: AnyObject) -> NSData {
        let a = array as! NSArray
        return NSKeyedArchiver.archivedDataWithRootObject(array)
    }
    
    func unarchive(data: NSData) -> NSArray {
        return NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSArray
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
        
        // this function will filter data and display to user
        // first clear filtered course
        self.filteredCourse = []
        
        // loop through all course data
        for data in self.parsedCourseData {
            var name = data["name"] as! String
            var lecturer = data["lecturer"] as! String
            let c = data["credits"]
            var credits = "\(c)"
            var uuid = data["code"] as! String
            
            var match: Bool! = false
            
            if name.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil {
                match = true
            }
            if lecturer.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil {
                match = true
            }
//            for p in periods {
//                if let location = p[2]{
//                    let loca = location as! String
//                    if loca.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil {
//                        match = true
//                    }
//                }
//            }
            if credits.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil {
                match = true
            }
            
            // if match search text, add to filter course, ready to display to user
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
            println("count of add : " + "\(self.coursesAddedToTimetable.count)")
            return self.coursesAddedToTimetable.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if searchCourse.active && searchCourse.searchBar.text != "" {
            var cell = tableView.dequeueReusableCellWithIdentifier("ColorgyCourseCardCell", forIndexPath: indexPath) as! ColorgyCourseCardCell

//            cell.name.text = self.filteredCourse[indexPath.row]["name"] as! String
//            cell.teacher.text = self.filteredCourse[indexPath.row]["lecturer"] as! String
//            cell.time.text = self.filteredCourse[indexPath.row]["code"] as! String
//            let s = self.filteredCourse[indexPath.row]["credits"]
//            cell.location.text = "\(s)"
            
            cell.name.text = self.filteredCourse[indexPath.row]["name"] as! String
            cell.lecturer.text = self.filteredCourse[indexPath.row]["lecturer"] as! String
            cell.code.text = self.filteredCourse[indexPath.row]["code"] as! String
            var c = self.filteredCourse[indexPath.row]["credits"] as! Int
            cell.credits.text = "\(c)"
            
            return cell
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("ColorgyCourseCardCell", forIndexPath: indexPath) as! ColorgyCourseCardCell
            
            cell.name.text = self.coursesAddedToTimetable[indexPath.row][0] as! String
            cell.code.text = self.coursesAddedToTimetable[indexPath.row][3] as! String
            var c = self.coursesAddedToTimetable[indexPath.row][2] as! Int
            cell.credits.text = "\(c)"
            cell.lecturer.text = self.coursesAddedToTimetable[indexPath.row][1] as! String
            cell.period.text = self.coursesAddedToTimetable[indexPath.row][4] as! String
            cell.location.text = self.coursesAddedToTimetable[indexPath.row][5] as! String
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 140
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if self.searchCourse.active {
            
            // get out all the data, easy to read.
            let name = self.filteredCourse[indexPath.row]["name"] as! String
            let lecturer = self.filteredCourse[indexPath.row]["lecturer"] as! String
            let credits = self.filteredCourse[indexPath.row]["credits"] as! Int
            let uuid = self.filteredCourse[indexPath.row]["code"] as! String
            
            let optionMenu = UIAlertController(title: "\(name)", message: "\(lecturer)\n\(credits)", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "加入課程", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction!) -> Void in
                if !self.isCourseAlreadyAddedToSelectedCourse(self.filteredCourse[indexPath.row]["code"] as! String) {
                    // if this course is not selected...... add it
                    var sessions = NSMutableArray()
                    for i in 1...9 {
                        let day = self.filteredCourse[indexPath.row]["day_" + "\(i)"]
                        let session = self.filteredCourse[indexPath.row]["period_" + "\(i)"]
                        let location = self.filteredCourse[indexPath.row]["location_" + "\(i)"]
                        
                        sessions.addObject(["\(day!!)", "\(session!!)", "\(location!!)"])
                    }
                    println(sessions)
                    self.storeDataToDatabase(name, lecturer: lecturer, credits: credits, uuid: uuid, sessions: sessions)
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
