//
//  ViewController.swift
//  FlashKards
//
//  Created by Timothy Tong on 2015-03-22.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddCollectionPopupDelegate, ConfirmDeletePopupDelegate{
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private weak var addCardsButton: UIBarButtonItem!
    private var flashcardCollections: Array<FlashCardCollection>!
    private var newCollectionPopup: AddCollectionPopup!
    private var deleteCollectionPopup: ConfirmDeletePopup!
    private var dimLayer: UIView!
    private var rowOfInterest: NSIndexPath?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // NavBar
        if let navbar = navigationController?.navigationBar{
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
        view.backgroundColor = UIColor(red: 57/255, green: 57/255, blue: 57/255, alpha: 1)
        
        // TableView
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        var homePageCellNib = UINib(nibName: "FlashCardsOverviewCellTemplate", bundle: nil)
        tableView.registerNib(homePageCellNib, forCellReuseIdentifier: "homePageCell")
        tableView.allowsMultipleSelection = false
        flashcardCollections = [];
        
        // Test collections
        let f1 = FlashCardCollection(collectionName: "Canadian French", progress: 40, lastReviewed: "2 days ago", numCards: 49)
        let f2 = FlashCardCollection(collectionName: "ひらがな", progress: 15, lastReviewed: "4 days ago", numCards: 38)
        let f3 = FlashCardCollection(collectionName: "Vocabularies", progress: 100, lastReviewed: "5 mins ago", numCards: 1)
        let f4 = FlashCardCollection(collectionName: "漢字", progress: 70, lastReviewed: "2 days ago", numCards: 144)
        flashcardCollections = [f1, f2, f3, f4]
        
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
        deleteCollectionPopup = ConfirmDeletePopup(frame: CGRect(x: 35, y: view.frame.height/5, width: view.frame.width - 70, height: view.frame.height * 3/5))
        deleteCollectionPopup.alpha = 0
        deleteCollectionPopup.transform = CGAffineTransformMakeScale(1.1, 1.1)
        deleteCollectionPopup.delegate = self
        navigationController?.view.addSubview(deleteCollectionPopup)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:FlashCardsOverviewCell = tableView.dequeueReusableCellWithIdentifier("homePageCell") as FlashCardsOverviewCell
        cell.populateCellWithCollection(flashcardCollections[indexPath.row])
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
            openConfirmDeletePopupWithCollectionName((flashcardCollections[indexPath.row] as FlashCardCollection).collectionName)
            rowOfInterest = indexPath
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
    
    func addCollectionPopupDoneButtonDidPressedWithInput(input: String!) {
        closeAddColPopup()
        let newCollection = FlashCardCollection(collectionName: input, progress: 0, lastReviewed: "Never", numCards: 0)
        flashcardCollections.insert(newCollection, atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        })
    }
    
    // MARK: ConfirmDeletePopup
    private func openConfirmDeletePopupWithCollectionName(collectionName: String!){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.deleteCollectionPopup.collectionName = collectionName
            UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.dimLayer.alpha = 1
                }, completion: { (complete) -> Void in
            })
            UIView.animateWithDuration(0.1, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.deleteCollectionPopup.alpha = 0.5
                self.deleteCollectionPopup.transform = CGAffineTransformMakeScale(1.2, 1.2)
                }, completion: { (complete) -> Void in
                    UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                        self.deleteCollectionPopup.alpha = 1
                        self.deleteCollectionPopup.transform = CGAffineTransformIdentity
                        }, completion: { (complete) -> Void in
                    })
            })
        })
    }
    
    private func closeConfirmDeletePopup(){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.dimLayer.alpha = 0
                self.deleteCollectionPopup.transform = CGAffineTransformMakeScale(0.8, 0.8)
                self.deleteCollectionPopup.alpha = 0
                }, completion: { (complete) -> Void in
                    self.deleteCollectionPopup.transform = CGAffineTransformMakeScale(1.1, 1.1)
            })
        })
    }
    
    func confirmDeletePopupConfirmDidTapped() {
        closeConfirmDeletePopup()
        if let rowOfInterest = self.rowOfInterest{
            flashcardCollections.removeAtIndex(rowOfInterest.row)
            tableView.deleteRowsAtIndexPaths([rowOfInterest], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        else{
            println("Deletion error")
        }
    }
    
    func confirmDeletePopupCancelDidTapped() {
        closeConfirmDeletePopup()
        tableView.setEditing(false, animated: true)
    }
}

