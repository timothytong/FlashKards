//
//  HomeController.swift
//  FlashKards
//
//  Created by Timothy Tong on 2015-03-22.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit
class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddCollectionPopupDelegate,PopupDelegate{
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private weak var addCardsButton: UIBarButtonItem!
    private var newCollectionPopup: AddCollectionPopup!
    private var deleteCollectionPopup: Popup!
    private var dimLayer: UIView!
    private var rowOfInterest: NSIndexPath?
    private var flashcardCollections: Array<FlashCardCollection>!
    private var collectionsManager: CollectionsManager!
    private var fileManager: FileManager!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // NavBar
        if let navbar = navigationController?.navigationBar{
            navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
            navbar.topItem!.title = "FLASHKARDS"
            navbar.barStyle = UIBarStyle.BlackTranslucent
            navbar.barTintColor = UIColor(red: 43/255, green: 43/255, blue: 43/255, alpha: 1)
            let navbarAttrs = [
                NSForegroundColorAttributeName:UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1),
                NSFontAttributeName:UIFont(name: "AvenirNextCondensed-Regular", size: 25)!
            ]
            navbar.titleTextAttributes = navbarAttrs
        }
        addCardsButton.tintColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        addCardsButton.action = "openAddColPopup"
        addCardsButton.target = self
        
        // Body
        tableView.backgroundColor = UIColor(red: 57/255, green: 57/255, blue: 57/255, alpha: 1)
        
        // TableView
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        var homePageCellNib = UINib(nibName: "FlashCardsOverviewCellTemplate", bundle: nil)
        tableView.registerNib(homePageCellNib, forCellReuseIdentifier: "homePageCell")
        tableView.allowsMultipleSelection = false
        
        // Collections
        flashcardCollections = [FlashCardCollection]()
        
        
        // Dim layer
        dimLayer = UIView(frame: UIScreen.mainScreen().bounds)
        dimLayer.backgroundColor = UIColor(white: 0, alpha: 0.6)
        dimLayer.userInteractionEnabled = true
        dimLayer.alpha = 0
        navigationController?.view.addSubview(dimLayer)
        
        // New collection popup
        newCollectionPopup = AddCollectionPopup(frame: CGRect(x: 35, y: view.frame.height/5, width: view.frame.width - 70, height: view.frame.height * 3/5))
        newCollectionPopup.alpha = 0
        newCollectionPopup.transform = CGAffineTransformMakeScale(1.1, 1.1)
        newCollectionPopup.delegate = self
        navigationController?.view.addSubview(newCollectionPopup)
        
        // Delete collection confirmation popup
        deleteCollectionPopup = Popup(frame: CGRect(x: 35, y: view.frame.height/3, width: view.frame.width - 70, height: view.frame.height/3))
        deleteCollectionPopup.delegate = self
        
        // Collections Manager
        collectionsManager = CollectionsManager()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        flashcardCollections = collectionsManager.fetchCollections()
        tableView.reloadData()
        fileManager = FileManager()
    }
    override func viewWillDisappear(animated: Bool){
        super.viewWillDisappear(animated)
        fileManager = nil
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:FlashCardsOverviewCell = tableView.dequeueReusableCellWithIdentifier("homePageCell") as FlashCardsOverviewCell
        let collection = flashcardCollections[indexPath.row]
        cell.populateCellWithCollection(collection)
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flashcardCollections.count
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete{
            //            openPopup((flashcardCollections[indexPath.row] as FlashCardCollection).collectionName)
            let collectionToBeDeleted = flashcardCollections[indexPath.row]
            deleteCollectionPopup.message = "Confirm delete:\n\(collectionToBeDeleted.collectionName)?"
            navigationController?.view.addSubview(deleteCollectionPopup)
            deleteCollectionPopup.show()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                    self.dimLayer.alpha = 1
                    }, completion: { (complete) -> Void in
                })
            })
            rowOfInterest = indexPath
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        performSegueWithIdentifier("showSummary", sender: indexPath)
    }
    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSummary"{
            let indexPath: NSIndexPath = sender! as NSIndexPath
            let flashcardsSummaryVC: FlashcardsSummaryController = segue.destinationViewController as FlashcardsSummaryController
            let collection = flashcardCollections[indexPath.row]
            flashcardsSummaryVC.configureWithCollection(collection)
        }
    }
    
    
    // MARK: AddCollectionPopup
    func openAddColPopup(){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.dimLayer.alpha = 1
                }, completion: { (complete) -> Void in
            })
            UIView.animateWithDuration(0.1, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.newCollectionPopup.alpha = 0.5
                self.newCollectionPopup.transform = CGAffineTransformMakeScale(1.2, 1.2)
                }, completion: { (complete) -> Void in
                    UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                        self.newCollectionPopup.alpha = 1
                        self.newCollectionPopup.transform = CGAffineTransformIdentity
                        }, completion: { (complete) -> Void in
                    })
            })
        })
    }
    
    private func closeAddColPopup(){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.dimLayer.alpha = 0
                self.newCollectionPopup.transform = CGAffineTransformMakeScale(0.8, 0.8)
                self.newCollectionPopup.alpha = 0
                }, completion: { (complete) -> Void in
                    self.newCollectionPopup.transform = CGAffineTransformMakeScale(1.1, 1.1)
            })
        })
    }
    
    func addCollectionPopupWillClose() {
        closeAddColPopup()
    }
    
    func addCollectionInputAlreadyExists(input: String!)->Bool{
        if let collectionOfSameName = collectionsManager.searchExistingCollectionsWithName(input){
            return true
        }
        return false
    }
    
    func addCollectionPopupDoneButtonDidPressedWithInput(input: String!){
        closeAddColPopup()
        var newCollection = FlashCardCollection(collectionName: input, progress: 100, lastReviewed: "Never", numCards: 0, id: nil, time_created: NSTimeIntervalSince1970, last_updated: NSTimeIntervalSince1970)
        collectionsManager.addCollection(newCollection, completionHandler: { (success, newID) -> Void in
            if success{
                self.fileManager.createDirectoryWithName(newCollection.collectionName)
                newCollection.id = newID
                self.flashcardCollections.insert(newCollection, atIndex: 0)
                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                })
            }
        })
    }
    
    // MARK: ConfirmDeletePopup
    func popupConfirmBtnDidTapped(popup: Popup) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.dimLayer.alpha = 0
                }, completion: { (complete) -> Void in
                    self.deleteCollectionPopup.removeFromSuperview()
            })
        })
        if let rowOfInterest = self.rowOfInterest{
            //            println("Deleting row \(rowOfInterest); CDObjCount: \(flashcardCoreDataObjs.count); tableRowsCount: \(tableView.numberOfRowsInSection(0))")
            let collectionToBeDeleted = flashcardCollections[rowOfInterest.row]
            collectionsManager.deleteCollectionWithName(collectionToBeDeleted.collectionName, completionHandler: { (success) -> Void in
                if success{
                    println("deletion success")
                    self.fileManager.deleteDirectory(collectionToBeDeleted.collectionName, withCompletionHandler: { () -> () in
                        println("Running completion handler...")
                        self.flashcardCollections.removeAtIndex(rowOfInterest.row)
                        self.tableView.deleteRowsAtIndexPaths([rowOfInterest], withRowAnimation: UITableViewRowAnimation.Automatic)
                    })
                }
                else{
                    println("Deletion Error")
                }
            })
        }
        else{
            println("rowOfInterest NOT FOUND")
        }
    }
    
    func popupCancelBtnDidTapped(popup: Popup) {
        println("CANCEL")
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.dimLayer.alpha = 0
                }, completion: { (complete) -> Void in
            })
        })
        tableView.setEditing(false, animated: true)
    }
    
}

