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
        let largestID = findLargestCardIDCollection()
        newCollection.collectionID = largestID + 1
        newCollection.name = name
        newCollection.numCards = 0
        newCollection.last_updated = NSDate.timeIntervalSinceReferenceDate()
        newCollection.time_created = NSDate.timeIntervalSinceReferenceDate()
        newCollection.lastReviewed = 0
        newCollection.largestCardID = 0
        newCollection.numCardsMemorized = 0
        
        // println("Saving, assigning id \(largestID+1)")
        var error: NSError?
        let success = managedContext.save(&error)
        completionHandler(success: success, newCollection: newCollection)
    }
    
    
    func getCollectionWithID(id: Int) -> FlashCardCollection?{
        var managedContext = appDelegate.managedObjectContext!
        var entity = NSEntityDescription.entityForName("Collection", inManagedObjectContext: managedContext)
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entity
        let predicate = NSPredicate(format: "collectionID == '\(id)'")
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
                return results[0] as? FlashCardCollection
            }
            else{
                // println("Empty array returned")
            }
        }
        return nil
        
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
    
    
    func findLargestCardIDCollection()->Int{
        var managedContext = appDelegate.managedObjectContext!
        var entity = NSEntityDescription.entityForName("Collection", inManagedObjectContext: managedContext)
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entity
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "collectionID", ascending: false)]
        var error: NSError?
        var fetchResults = managedContext.executeFetchRequest(fetchRequest, error: &error)
        if let results = fetchResults{
            if results.count > 0{
                let largest = (results[0] as! NSManagedObject).valueForKey("collectionID") as! Int
                 println("Found largest id \(largest)")
                return largest
            }
        }
        return 0
    }
    
    func addNewFlashcardWithData(newCardDict: NSDictionary, toCollection collection: FlashCardCollection){
        let frontDict = newCardDict["front"]! as! NSDictionary
        let backDict = newCardDict["back"]! as! NSDictionary
        
        var managedContext = appDelegate.managedObjectContext!
        var flashcardEntity = NSEntityDescription.entityForName("FlashCard", inManagedObjectContext: managedContext)
        var newCard = FlashCard(entity: flashcardEntity!, insertIntoManagedObjectContext: collection.managedObjectContext)
        
        newCard.front = frontDict
        newCard.back = backDict
        newCard.cardID = collection.largestCardID.integerValue + 1
        newCard.times_forgotten = 0
        newCard.forgotten = false
        newCard.time_created = NSDate.timeIntervalSinceReferenceDate()
        newCard.last_updated = NSDate.timeIntervalSinceReferenceDate()
        newCard.parentCollection = collection
        newCard.memorized = NSNumber(bool: false)
        newCard.latest_element_ID = newCardDict["latest_element_id"]! as! NSNumber
        collection.addFlashcardsObject(newCard)
        collection.largestCardID = collection.largestCardID.integerValue + 1
        collection.last_updated = NSDate.timeIntervalSinceReferenceDate()
        collection.numCards = collection.numCards.integerValue + 1
        var flashCardSaveError: NSError?
        var flashCardCollectionSaveError: NSError?

        
        let success = (newCard.managedObjectContext!.save(&flashCardSaveError) && collection.managedObjectContext!.save(&flashCardCollectionSaveError))
        if success{
            println("SUCCESSFULLY ADDED A CARD!!!")
        }
        else{
            println("FAILED ADDING A CARD!!!")
        }
    }
}
