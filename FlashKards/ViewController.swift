//
//  ViewController.swift
//  FlashKards
//
//  Created by Timothy Tong on 2015-03-22.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, InputPopupDelegate {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private weak var addCardsButton: UIBarButtonItem!
    private var flashcardCollections: Array<FlashCardCollection>!
    private var newCollectionPopup: InputPopup!
    private var dimLayer: UIView!
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
        flashcardCollections = [];
        
        // Test collections
        let f1 = FlashCardCollection(collectionName: "漢字", progress: 40, lastReviewed: "2 days ago", numCards: 49)
        let f2 = FlashCardCollection(collectionName: "ひらがな", progress: 15, lastReviewed: "4 days ago", numCards: 38)
        let f3 = FlashCardCollection(collectionName: "Vocabularies", progress: 98, lastReviewed: "5 mins ago", numCards: 9)
        let f4 = FlashCardCollection(collectionName: "Korean", progress: 70, lastReviewed: "2 days ago", numCards: 144)
        flashcardCollections = [f1, f2, f3, f4]
        
        // Dim layer
        dimLayer = UIView(frame: UIScreen.mainScreen().bounds)
        dimLayer.backgroundColor = UIColor(white: 0, alpha: 0.6)
        dimLayer.userInteractionEnabled = true
        dimLayer.alpha = 0
        navigationController?.view.addSubview(dimLayer)
        
        // New collection popup
        newCollectionPopup = InputPopup(frame: CGRect(x: 35, y: view.frame.height/5, width: view.frame.width - 70, height: view.frame.height * 3/5))
        newCollectionPopup.alpha = 0
        newCollectionPopup.transform = CGAffineTransformMakeScale(1.1, 1.1)
        newCollectionPopup.delegate = self
        navigationController?.view.addSubview(newCollectionPopup)
        
    }
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
    
    func closeAddColPopup(){
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
    
    func inputPopupWillClose() {
        closeAddColPopup()
    }
}

