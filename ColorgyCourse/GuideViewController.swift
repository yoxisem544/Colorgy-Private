//
//  GuideViewController.swift
//  ColorgyCourse
//
//  Created by David on 2015/8/7.
//  Copyright (c) 2015年 David. All rights reserved.
//

import UIKit

class GuideViewController: UIViewController, UIPageViewControllerDataSource {

    var pageViewController: UIPageViewController!
    var pageImages: NSArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.pageImages = NSArray(objects: "guide1.jpg", "guide2.jpg", "guide3.jpg")
        
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("guidePageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        
        var startVC = self.viewControllersAtIndex(0) as GuideContentViewController
        var viewControllers = NSArray(object: startVC)
        
        self.pageViewController.setViewControllers(viewControllers as [AnyObject], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        
        self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - 60)
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
        
    }
    @IBAction func readGuideClick(sender: AnyObject) {
        
        var ud = NSUserDefaults.standardUserDefaults()
        ud.setBool(true, forKey: "isGuideShown")
        ud.synchronize()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var vc = storyboard.instantiateViewControllerWithIdentifier("ColorgyTabBarService") as! UITabBarController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func viewControllersAtIndex(index: Int) -> GuideContentViewController {
        
        if ((self.pageImages.count == 0) || (index >= self.pageImages.count)) {
            return GuideContentViewController()
        }
        
        var vc: GuideContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("guideContentViewController") as! GuideContentViewController
        
        vc.imageFile = self.pageImages[index] as! String
        vc.pageIndex = index
        
        return vc
    }
    
    // MARK: - page view controller data source
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        var vc = viewController as! GuideContentViewController
        var index = vc.pageIndex as Int
        
        if (index == 0 || index == NSNotFound) {
            return nil
        }
        
        index--
        return self.viewControllersAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        var vc = viewController as! GuideContentViewController
        var index = vc.pageIndex as Int
        
        if (index == NSNotFound) {
            return nil
        }
        
        index++
        
        if (index == self.pageImages.count) {
            return nil
        }
        
        return self.viewControllersAtIndex(index)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.pageImages.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
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
