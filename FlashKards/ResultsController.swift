//
//  ResultsController.swift
//  FlashKards
//
//  Created by Timothy Tong on 2015-04-24.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit

class ResultsController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    @IBOutlet weak var exitControllerBtn: UIButton!
    @IBOutlet var sepLine: UIView!
    @IBOutlet weak var sepLineWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    private var resultsArray: Array<Dictionary<String, String>>!
    private var statusSectionCellCount = 0
    private var dataSectionCellCount = 0
    private var totalEntries = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        exitControllerBtn.tag = 0
        exitControllerBtn.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
        sepLineWidthConstraint.constant = 0
        tableView.sectionIndexBackgroundColor = UIColor.clearColor()
        tableView.sectionIndexColor = UIColor.whiteColor()
        tableView.backgroundColor = UIColor(red: 62/255, green: 62/255, blue: 62/255, alpha: 1)
        tableView.separatorStyle = .None
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        sepLineWidthConstraint.constant = self.view.frame.width - 30
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseIn, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }) { (complete) -> Void in
        }
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            for i in 0 ..< self.totalEntries{
                self.delay(0.3 * Double(i), closure: { () -> () in
                    let indexPath: NSIndexPath!
                    if i == 0{
                        indexPath = NSIndexPath(forRow: 0, inSection: 0)
                        self.statusSectionCellCount = 1
                    }
                    else{
                        indexPath = NSIndexPath(forRow: i - 1, inSection: 1)
                        self.dataSectionCellCount++
                    }
                    self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    if i != 0 && i != self.totalEntries - 1{
                        if let cell: reviewSummaryCell = self.tableView.cellForRowAtIndexPath(indexPath) as?reviewSummaryCell{
                            UIView.animateWithDuration(1.2, animations: { () -> Void in
                                cell.sepLine.alpha = 1
                            })
                        }
                        
                    }
                })
            }
        })
        
    }
    
    func configureWithResults(results: NSDictionary, andCollection collection: FlashCardCollection) {
        resultsArray = Array<Dictionary<String, String>>()
        let resultDicts = NSMutableDictionary(dictionary: results)
        let statusDict = ["status": resultDicts.objectForKey("status")! as! String]
        resultsArray.append(statusDict)
        resultDicts.removeObjectForKey("status")
        for key in resultDicts.allKeys {
            let dict = [key as! String: results.objectForKey(key)! as! String] as Dictionary
            resultsArray.append(dict)
        }
        totalEntries = resultsArray.count
    }
    
    func buttonPressed(sender: UIButton){
        switch(sender.tag){
        case 0:
            self.dismissViewControllerAnimated(true, completion: nil)
        default:
            break
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 60
        }
        return 80
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var returnCell: UITableViewCell!
        if indexPath.section == 0{
            let dict = resultsArray[0] as Dictionary
            var cell = tableView.dequeueReusableCellWithIdentifier("reviewSummaryStatusCell") as! ReviewSummaryStatusCell
            cell.configureWithDict(dict)
            returnCell = cell
        }
        else{
            let dict = resultsArray[indexPath.row + 1] as Dictionary
            var cell = tableView.dequeueReusableCellWithIdentifier("reviewSummaryCell") as! reviewSummaryCell
            cell.configureWithDict(dict)
            returnCell = cell
        }
        returnCell.backgroundColor = UIColor(red: 62/255, green: 62/255, blue: 62/255, alpha: 1)
        returnCell.userInteractionEnabled = false
        return returnCell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return statusSectionCellCount
        }
        else if section == 1{
            return dataSectionCellCount //resultsArray.count - 1
        }
        return 0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var label = UILabel()
        label.textColor = UIColor.whiteColor()
        label.backgroundColor = UIColor(red: 62/255, green: 62/255, blue: 62/255, alpha: 1)
        label.font = UIFont(name: "AvenirNextCondensed-Regular", size: 16)
        if(section == 0) {
            label.text = "S T A T U S"
        }
        else{
            label.text = "S T A T S"
        }
        return label
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}
