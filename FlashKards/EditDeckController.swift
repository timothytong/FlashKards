//
//  EditDeckController.swift
//  FlashKards
//
//  Created by Timothy Tong on 2015-05-06.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit

class EditDeckController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SmallFlashCardCellDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    private var collection: FlashCardCollection!
    private var collectionArray: [FlashCard]!
    private var widthRatio: CGFloat!
    private var heightRatio: CGFloat!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.showsVerticalScrollIndicator = false
    }
    
    func configureWithCollection(collection: FlashCardCollection){
        self.collection = collection
        collectionArray = (collection.flashcards as NSSet).allObjects as! [FlashCard]
        collectionArray.sort({$0.cardID.integerValue < $1.cardID.integerValue})
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:SmallFlashCardCell = collectionView.dequeueReusableCellWithReuseIdentifier("flashcardCell", forIndexPath: indexPath) as! SmallFlashCardCell
        cell.delegate = self
        let flashCard = collectionArray[indexPath.row]
        cell.populateViewWithDict(flashCard.front as! NSDictionary, widthScale: widthRatio, heightScale: heightRatio, index: indexPath.item)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionArray.count
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
   
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsetsMake(5, 5, 5, 2.5); //top,left,bottom,right
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        var originalWidth = view.frame.width - 52
        var originalHeight = view.frame.height - 123 - 100
        if Utilities.IS_IPHONE4(){
            originalHeight += 23
        }
        let ratio = originalHeight/originalWidth
        var width = (view.frame.width - 16 - 40) / 3 // iPhone 6+/6
        if Utilities.IS_IPHONE5() || Utilities.IS_IPHONE4(){
            width = (view.frame.width - 16 - 25) / 2
        }
        let height = width * ratio
        widthRatio = width/originalWidth
        heightRatio = height/originalHeight
        return CGSize(width: width, height: height)
    }
    
    func smallFlashCardCellDeleteButtonTapped(index: Int) {
        collectionView.performBatchUpdates({ () -> Void in
            print("Deleting index \(index)")
            let card = self.collectionArray.removeAtIndex(index)
            self.collectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
            let collection = card.parentCollection
            if !card.forgotten{
                print("This is a remembered card.")
                collection.numCardsMemorized = collection.numCardsMemorized.integerValue - 1
            }
            collection.removeFlashcardsObject(card)
            collection.numCards = collection.numCards.integerValue - 1

            do {
                try collection.managedObjectContext!.save()
                print("Card successfully deleted from collection")
            } catch {
                print("Card cant be deleted!!")
            }
            


        }, completion: { (comeplete) -> Void in
            self.collectionView.reloadData()
        })
    }
}
