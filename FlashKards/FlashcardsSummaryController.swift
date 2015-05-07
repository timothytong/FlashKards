//
//  FlashcardsSummaryController
//  FlashKards
//
//  Created by Timothy Tong on 2015-03-26.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit
class FlashcardsSummaryController: UIViewController, UITableViewDelegate, UITableViewDataSource, PopupDelegate {
    @IBOutlet private weak var editButton: UIButton!
    @IBOutlet private weak var tableViewTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var buttonsBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var suggestedActionLabel: UILabel!
    private var collectionManager: CollectionsManager!
    @IBOutlet weak var tableViewSugActionVConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewSugActVConstraint: NSLayoutConstraint!
    private var flashcardCollection: FlashCardCollection!
    private var updateSummaryTimer: NSTimer!
    private var showResultsScreen = false
    private var quizResultsDict: NSDictionary?
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
        if Utilities.IS_IPHONE4(){
            tableViewTopConstraint.constant -= 20
            tableViewSugActionVConstraint.constant -= 10
        }
        else if !Utilities.IS_IPHONE5(){
            buttonsBottomConstraint.constant += 20
            tableViewTopConstraint.constant += 30
            tableViewSugActVConstraint.constant += 40
        }
        editButton.addTarget(self, action: "editButtonPressed", forControlEvents: .TouchUpInside)
        // Do any additional setup after loading the view.
    }
    
    func editButtonPressed(){
        var featureNotAvailablePopup = Popup(frame: CGRect(x: 35, y: view.frame.height/3, width: view.frame.width - 70, height: view.frame.height/3))
        featureNotAvailablePopup.numOptions = 1
        featureNotAvailablePopup.message = "Sorry, this feature is not yet available."
        featureNotAvailablePopup.cancelBtnText = "OK"
        featureNotAvailablePopup.delegate = self
        navigationController?.view.addSubview(featureNotAvailablePopup)
        featureNotAvailablePopup.show()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        updateSummaryTimer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "updateSummary", userInfo: nil, repeats: true)
        if showResultsScreen {
            showResultsScreen = false
            if let dict = self.quizResultsDict{
                println("Showing results screen")
                self.performSegueWithIdentifier("showResults", sender: self)
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        if updateSummaryTimer != nil{
            updateSummaryTimer.invalidate()
            updateSummaryTimer = nil
        }
        
    }
    
    func updateSummary(){
        tableView.reloadData()
    }
    
    func configureWithCollection(flashcardCol: FlashCardCollection!){
        flashcardCollection = flashcardCol
        println("\(flashcardCollection.name.capitalizedString)")
        navigationItem.title = flashcardCollection.name.uppercaseString
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK: - UITableView
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: CollectionSummaryCell = tableView.dequeueReusableCellWithIdentifier("summaryCell") as! CollectionSummaryCell
        let numCards = flashcardCollection.numCards
        let kardOrKards = (numCards == 1) ? "K A R D" : "K A R D S"
        let relTimeDiff = calculateRelativeDate(flashcardCollection.lastReviewed.doubleValue)
        switch indexPath.row{
        case 0:
            cell.populateFieldsWithNumberString("\(numCards)", Subtext1: kardOrKards, andSubtext2: "In collection")
        case 1:
            let numCardsMem = flashcardCollection.numCardsMemorized.integerValue
            let numCards = flashcardCollection.numCards.integerValue
            let progress = (numCards == 0 && numCardsMem == 0) ? 100 : numCardsMem * 100 / numCards
            cell.populateFieldsWithNumberString("\(progress)", Subtext1: "P E R C E N T", andSubtext2: "Memorized")
        case 2:
            cell.populateFieldsWithNumberString(relTimeDiff[0], Subtext1: relTimeDiff[1], andSubtext2: "Last reviewed")
        default:
            break
        }
        // TODO: Add more details... time created, updated, numCardsMemorized
        let subString = count(relTimeDiff[1]) > 2 ? (relTimeDiff[1] as NSString).substringToIndex(3) as String : ""
        if numCards.integerValue < 10 { suggestedActionLabel.text = "Suggested Action:\nAdd some FlashKards." }
        if ((subString != "MIN") && (subString != "HOU") && (numCards.integerValue >= 10)) { suggestedActionLabel.text = "Suggested Action:\nReview the FlashKards." }
        if numCards.integerValue >= 10 && ((subString == "MIN") || (subString == "HOU")) { suggestedActionLabel.text = "Do something else,\n come back later." }
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func calculateRelativeDate(timeStamp: Double!)->[String]{
        if timeStamp == 0{
            return ["X", "NEVER"]
        }
        
        let currentTime: Double = NSDate.timeIntervalSinceReferenceDate()
        let diff = currentTime - timeStamp
        var returnArray = [String]()
        var time: String, unit: String
        switch diff{
        case 0...3600:
            time = "\(Int(diff/60))"
            unit = (time == "1") ? "M I N" : "M I N S"
        case 3601...86400:
            time = "\(Int(diff/3600))"
            unit = (time == "1") ? "H O U R" : "H O U R S"
        case 86401...2678400:
            time = "\(Int(diff/86400))"
            unit = (time == "1") ? "D A Y" : "D A Y S"
        case 2678401...31622400:
            time = "\(Int(diff/2678400))"
            unit = (time == "1") ? "M O N T H" : "M O N T HS"
        default:
            time = ">1"
            unit = "Y E A R"
        }
        returnArray.append(time)
        returnArray.append(unit)
        return returnArray
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "ReviewCollection" {
            if flashcardCollection.numCards.integerValue < 1{
                var reviewNotAvailablePopup = Popup(frame: CGRect(x: 35, y: view.frame.height/3, width: view.frame.width - 70, height: view.frame.height/3))
                reviewNotAvailablePopup.numOptions = 1
                reviewNotAvailablePopup.message = "No cards in deck."
                reviewNotAvailablePopup.cancelBtnText = "OK"
                reviewNotAvailablePopup.delegate = self
                navigationController?.view.addSubview(reviewNotAvailablePopup)
                reviewNotAvailablePopup.show()
                return false
            }
        }
        return true
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "addFlashcard"{
            let customizeFKVC: CustomizeCardController = segue.destinationViewController as! CustomizeCardController
            customizeFKVC.configureWithCollection(flashcardCollection)
            let fileManager = FileManager()
            fileManager.createDirectoryWithName("\(fileManager.processString(flashcardCollection.name))/tmp")
        }
        else if segue.identifier == "ReviewCollection"{
            let reviewVC: ReviewFlashcardController = segue.destinationViewController as! ReviewFlashcardController
            reviewVC.configureWithCollection(flashcardCollection)
            flashcardCollection.lastReviewed = NSDate.timeIntervalSinceReferenceDate()
            /*
            navigationController?.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
            presentViewController(reviewVC, animated: true, completion: nil)
            */
        }
        else if segue.identifier == "showResults"{
            let resultsVC: ResultsController = segue.destinationViewController as! ResultsController
            if let resultsDict = quizResultsDict{
                resultsVC.configureWithResults(resultsDict, andCollection: flashcardCollection)
            }
            else{
                println("SOMETHING IS WRONG")
            }
        }
    }
    
    func popupCancelBtnDidTapped(popup: Popup) {
        popup.removeFromSuperview()
    }
    
    @IBAction func unwindToSummary(sender: UIStoryboardSegue)
    {
        println("unwinded to summary, destination \(sender.destinationViewController), originating VC \(sender.sourceViewController)")
        if sender.identifier == "completeReview"{
            println("Complete Review")
            let sourceController = sender.sourceViewController as! ReviewFlashcardController
            showResultsScreen = true
            quizResultsDict = sourceController.quizResultsDict
        }
    }
}
