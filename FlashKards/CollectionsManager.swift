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
        let managedContext = appDelegate.managedObjectContext
        let newCollection = NSEntityDescription.insertNewObjectForEntityForName("Collection", inManagedObjectContext: managedContext) as! FlashCardCollection
        let largestID = findLargestCardIDCollection()
        newCollection.collectionID = largestID + 1
        newCollection.name = name
        newCollection.numCards = 0
        newCollection.last_updated = NSDate.timeIntervalSinceReferenceDate()
        newCollection.time_created = NSDate.timeIntervalSinceReferenceDate()
        newCollection.lastReviewed = 0
        newCollection.largestCardID = 0
        newCollection.numCardsMemorized = 0
        
        // print("Saving, assigning id \(largestID+1)")
        do {
            try managedContext.save()
            completionHandler(success: true, newCollection: newCollection)
        } catch {
            print("CANNOT ADD COLLECTION WITH NAME")
            completionHandler(success: false, newCollection: newCollection)
        }
        
        
    }
    
    
    func getCollectionWithID(id: Int) -> FlashCardCollection?{
        let managedContext = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entityForName("Collection", inManagedObjectContext: managedContext)
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entity
        let predicate = NSPredicate(format: "collectionID == '\(id)'")
        fetchRequest.predicate = predicate
        /* sorting...
        let sortDescriptor = NSSortDescriptor(key: "lastReviewed", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        */
        
        do {
            var fetchResults = try managedContext.executeFetchRequest(fetchRequest)
            if fetchResults.count > 0{
                // print("Found existing collection")
                return fetchResults[0] as? FlashCardCollection
            }
        } catch {
            return nil
        }
        return nil
    }
    
    func searchExistingCollectionsWithName(collectionName: String!)->NSManagedObject?{
        print("-searchExistingCollectionsWithName")
        let managedContext = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entityForName("Collection", inManagedObjectContext: managedContext)
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entity
        let predicate = NSPredicate(format: "name == '\(collectionName)'")
        fetchRequest.predicate = predicate
        /* sorting...
        let sortDescriptor = NSSortDescriptor(key: "lastReviewed", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        */
        do {
            let fetchResults = try managedContext.executeFetchRequest(fetchRequest)
            if fetchResults.count > 0{
                print("    Found existing collection")
                return fetchResults[0] as? NSManagedObject
            }
            else{
                print("    Empty array returned")
            }
            
        } catch {
            print("    Error executing fetch")
            return nil
        }
        return nil
    }
    
    func deleteCollectionWithName(name: String!, completionHandler:(success: Bool)->Void){
        if let collectionCoreDataObj = searchExistingCollectionsWithName(name){
            // print()
            let managedContext = appDelegate.managedObjectContext
            managedContext.deleteObject(collectionCoreDataObj)
            do {
                try managedContext.save()
                completionHandler(success: true)
            } catch {
                completionHandler(success: false)
            }
            
        }
    }
    
    func fetchCollections()->Array<FlashCardCollection>{
        let fetchRequest = NSFetchRequest(entityName: "Collection")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        let managedContext = appDelegate.managedObjectContext
        do {
            var fetchResults = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            fetchResults = fetchResults.reverse()
            return fetchResults as! [FlashCardCollection]
        } catch {
            // print("Could not fetch \(error), \(error!.userInfo)")
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
        let managedContext = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entityForName("Collection", inManagedObjectContext: managedContext)
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entity
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "collectionID", ascending: false)]
        do {
            var fetchResults = try managedContext.executeFetchRequest(fetchRequest)
            if fetchResults.count > 0{
                let largest = (fetchResults[0] as! NSManagedObject).valueForKey("collectionID") as! Int
                print("Found largest id \(largest)")
                return largest
            }
            
        } catch {
            return 0
        }
        return 0
    }
    
    func addNewFlashcardWithData(newCardDict: NSDictionary, toCollection collection: FlashCardCollection){
        let frontDict = newCardDict["front"]! as! NSDictionary
        let backDict = newCardDict["back"]! as! NSDictionary
        
        let managedContext = appDelegate.managedObjectContext
        let flashcardEntity = NSEntityDescription.entityForName("FlashCard", inManagedObjectContext: managedContext)
        let newCard = FlashCard(entity: flashcardEntity!, insertIntoManagedObjectContext: collection.managedObjectContext)
        
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
        
        do {
            try newCard.managedObjectContext!.save()
            try collection.managedObjectContext!.save()
            print("SUCCESSFULLY ADDED A CARD!!!")
        } catch {
            print("FAILED ADDING A CARD!!!")
        }
    }
}
