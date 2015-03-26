//
//  FlashcardsSummaryController
//  FlashKards
//
//  Created by Timothy Tong on 2015-03-26.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit
class FlashcardsSummaryController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet private weak var tableViewTopConstraint: NSLayoutConstraint!
    // If iPhone 4 move up!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var suggestedActionLabel: UILabel!
    private var collectionManager: CollectionsManager!
    private var flashcardCollection: FlashCardCollection!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionManager = CollectionsManager()
        if let navController = navigationController{
            navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
            navController.navigationBar.tintColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
            let nib = UINib(nibName: "CollectionSummaryCellTemplate", bundle: nil)
            tableView.registerNib(nib, forCellReuseIdentifier: "summaryCell")
            tableView.separatorStyle = .None
            tableView.scrollEnabled = false
        }
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureWithCollection(flashcardCol: FlashCardCollection!){
        flashcardCollection = flashcardCol
        navigationItem.title = flashcardCollection.collectionName
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK: - UITableView
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: CollectionSummaryCell = tableView.dequeueReusableCellWithIdentifier("summaryCell") as CollectionSummaryCell
        let numCards = flashcardCollection.numCards
        let relTimeDiff = calculateRelativeDate(flashcardCollection.lastReviewed)
        switch indexPath.row{
        case 0:
            cell.populateFieldsWithNumberString("\(numCards)", Subtext1: "KARDS", andSubtext2: "In collection")
        case 1:
            cell.populateFieldsWithNumberString("\(flashcardCollection.progress)", Subtext1: "PERCENT", andSubtext2: "Memorized")
        default:
            cell.populateFieldsWithNumberString(relTimeDiff[0], Subtext1: relTimeDiff[1], andSubtext2: "Last reviewed")
        }
        let substring = (relTimeDiff[1] as NSString).substringToIndex(3)
        if numCards == 0 { suggestedActionLabel.text = "Suggested Action:\nAdd some FlashKards." }
        else if (substring != "MIN") && (substring != "HOU"){ suggestedActionLabel.text = "Suggested Action:\nReview the FlashKards." }
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func calculateRelativeDate(timeStamp: String!)->[String]{
        let currentTime: Double = NSTimeIntervalSince1970
        let doubleTimeStamp: Double = (timeStamp == "Never") ? currentTime : (timeStamp as NSString).doubleValue
        let diff = currentTime - doubleTimeStamp
        var returnArray = [String]()
        var time: String, unit: String
        switch diff{
        case 0...300:
            time = "<5"
            unit = "MINS"
        case 301...3600:
            time = "\(diff/60)"
            unit = (time == "1") ? "MIN" : "MINS"
        case 3601...86400:
            time = "\(diff/3600)"
            unit = (time == "1") ? "HOUR" : "HOURS"
        case 86401...2678400:
            time = "\(diff/86400)"
            unit = (time == "1") ? "DAY" : "DAYS"
        case 2678401...31622400:
            time = "\(diff/2678400)"
            unit = (time == "1") ? "MONTH" : "MONTHS"
        default:
            time = ">1"
            unit = "YEAR"
        }
        returnArray.append(time)
        returnArray.append(unit)
        return returnArray
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
