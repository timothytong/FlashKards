//
//  CollectionsManager.swift
//  FlashKards
//
//  Created by Timothy Tong on 2015-03-25.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit
import CoreData

class CollectionsManager: NSObject {
    private var appDelegate: AppDelegate!
    
    override init(){
        super.init()
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    func addCollectionWithName(name: String!, andCompletionHandler completionHandler:(success:Bool, newCollection: FlashCardCollection)->()){
        var managedContext = appDelegate.managedObjectContext!
        var newCollection = NSEntityDescription.insertNewObjectForEntityForName("Collection", inManagedObjectContext: managedContext) as! FlashCardCollection
        let largestID = 0 //findLargestID()
        newCollection.collectionID = largestID + 1
        newCollection.name = name
        newCollection.numCards = 0
        newCollection.last_updated = NSDate.timeIntervalSinceReferenceDate()
        newCollection.time_created = NSDate.timeIntervalSinceReferenceDate()
        newCollection.lastReviewed = 0
        newCollection.numCardsMemorized = 0
        
        // println("Saving, assigning id \(largestID+1)")
        var error: NSError?
        let success = managedContext.save(&error)
        completionHandler(success: success, newCollection: newCollection)
    }
    
    func findLargestID()->Int{
        var managedContext = appDelegate.managedObjectContext!
        var entity = NSEntityDescription.entityForName("Collection", inManagedObjectContext: managedContext)
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entity
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        var error: NSError?
        var fetchResults = managedContext.executeFetchRequest(fetchRequest, error: &error)
        if let results = fetchResults{
            if results.count > 0{
                let largest = (results[0] as! NSManagedObject).valueForKey("id") as! Int
                // println("Found largest id \(largest)")
                return largest
            }
        }
        return -1
    }
    
    func searchExistingCollectionsWithName(collectionName: String!)->NSManagedObject?{
        var managedContext = appDelegate.managedObjectContext!
        var entity = NSEntityDescription.entityForName("Collection", inManagedObjectContext: managedContext)
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entity
        let predicate = NSPredicate(format: "name == '\(collectionName)'")
        fetchRequest.predicate = predicate
        /* sorting...
        let sortDescriptor = NSSortDescriptor(key: "lastReviewed", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        */
        var error: NSError?
        var fetchResults = managedContext.executeFetchRequest(fetchRequest, error: &error)
        if let results = fetchResults{
            if results.count > 0{
                // println("Found existing collection")
                return results[0] as? NSManagedObject
            }
            else{
                // println("Empty array returned")
            }
        }
        return nil
    }
    
    func deleteCollectionWithName(name: String!, completionHandler:(success: Bool)->Void){
        if let collectionCoreDataObj = searchExistingCollectionsWithName(name){
            // println()
            var managedContext = appDelegate.managedObjectContext!
            managedContext.deleteObject(collectionCoreDataObj)
            var error: NSError?
            let success = managedContext.save(&error)
            completionHandler(success: success)
        }
    }
    
    func fetchCollections()->Array<FlashCardCollection>{
        let fetchRequest = NSFetchRequest(entityName: "Collection")
        var error:NSError?
        var managedContext = appDelegate.managedObjectContext!
        var fetchResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]?
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        if let results = fetchResults{
            var collectionArray = Array<FlashCardCollection>()
            fetchResults = fetchResults!.reverse()
            return fetchResults as! [FlashCardCollection]
        }
        else {
            // println("Could not fetch \(error), \(error!.userInfo)")
            return []
        }
    }
    
    /*
    func convertCDObjectToCollection(cdObject: NSManagedObject)->FlashCardCollection{
    let collection = FlashCardCollection(
    collectionName: cdObject.valueForKey("name")? as String!,
    progress: cdObject.valueForKey("progress")? as Int,
    lastReviewed: cdObject.valueForKey("lastReviewed")? as String!,
    numCards: cdObject.valueForKey("numCards")? as Int!,
    id: cdObject.valueForKey("id") as Int!,
    time_created: cdObject.valueForKey("time_created") as Double!,
    last_updated: cdObject.valueForKey("last_updated") as Double!
    )
    return collection
    }
    */
    
    func findLargestCardIDInCollection()->Int{
        return 0
    }
    
    func addNewFlashcardWithData(newCardDict: NSDictionary!, toCollection collectionName: String!){
        let frontDict = newCardDict["front"]! as! NSDictionary
        let backDict = newCardDict["back"]! as! NSDictionary
        if let targetCollection = searchExistingCollectionsWithName(collectionName) as? FlashCardCollection{
            var managedContext = appDelegate.managedObjectContext!
            var flashcardEntity = NSEntityDescription.entityForName("FlashCard", inManagedObjectContext: managedContext)
            var newCard = NSManagedObject(entity: flashcardEntity!, insertIntoManagedObjectContext: targetCollection.managedObjectContext) as! FlashCard
            
            var frontData = NSKeyedArchiver.archivedDataWithRootObject(frontDict)
            newCard.front = frontDict
            newCard.back = backDict
            newCard.cardID = 0
            newCard.time_created = NSDate.timeIntervalSinceReferenceDate()
            newCard.last_updated = NSDate.timeIntervalSinceReferenceDate()
            newCard.parentCollection = targetCollection
            newCard.memorized = NSNumber(bool: false)
            targetCollection.addFlashcardsObject(newCard)
            targetCollection.last_updated = NSDate.timeIntervalSinceReferenceDate()
            targetCollection.numCards = targetCollection.numCards.integerValue + 1
            var flashCardSaveError: NSError?
            var flashCardCollectionSaveError: NSError?
            
            let success = (newCard.managedObjectContext!.save(&flashCardSaveError) && targetCollection.managedObjectContext!.save(&flashCardCollectionSaveError))
                if success{
                println("SUCCESSFULLY ADDED A CARD!!!")
                }
                else{
                println("FAILED ADDING A CARD!!!")
            }
        }
    }
}
