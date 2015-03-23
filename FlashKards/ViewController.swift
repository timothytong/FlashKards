//
//  ViewController.swift
//  FlashKards
//
//  Created by Timothy Tong on 2015-03-22.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private weak var addCardsButton: UIBarButtonItem!
    private var flashcardCollections: Array<FlashCardCollection>!
    override func viewDidLoad() {
        super.viewDidLoad()
        // NavBar
        if let navbar = self.navigationController?.navigationBar{
            navbar.topItem!.title = "FLASHKARDS"
            navbar.barStyle = UIBarStyle.BlackTranslucent
            navbar.barTintColor = UIColor(red: 43/255, green: 43/255, blue: 43/255, alpha: 1)
            let navbarAttrs = [
                NSForegroundColorAttributeName:UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1),
                NSFontAttributeName:UIFont(name: "AvenirNextCondensed-Regular", size: 25)!
            ]
            navbar.titleTextAttributes = navbarAttrs
        }
        self.addCardsButton.tintColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        
        // Body
        self.view.backgroundColor = UIColor(red: 57/255, green: 57/255, blue: 57/255, alpha: 1)
        
        // TableView
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        var homePageCellNib = UINib(nibName: "FlashCardsOverviewCellTemplate", bundle: nil)
        self.tableView.registerNib(homePageCellNib, forCellReuseIdentifier: "homePageCell")
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.flashcardCollections = [];
        
        // Test collections
        let f1 = FlashCardCollection(collectionName: "漢字", progress: 40, lastReviewed: "2 days ago", numCards: 49)
        let f2 = FlashCardCollection(collectionName: "ひらがな", progress: 15, lastReviewed: "4 days ago", numCards: 38)
        let f3 = FlashCardCollection(collectionName: "Vocabularies", progress: 98, lastReviewed: "5 mins ago", numCards: 9)
        let f4 = FlashCardCollection(collectionName: "Korean", progress: 70, lastReviewed: "2 days ago", numCards: 144)
        
        self.flashcardCollections = [f1, f2, f3, f4]
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:FlashCardsOverviewCell = self.tableView.dequeueReusableCellWithIdentifier("homePageCell") as FlashCardsOverviewCell
        cell.populateCellWithCollection(self.flashcardCollections[indexPath.row])
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.flashcardCollections.count
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

