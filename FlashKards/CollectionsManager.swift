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
        appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    }
    
    func addCollectionWithName(name: String!, andCompletionHandler completionHandler:(success:Bool, newCollection: FlashCardCollection)->()){
        var managedContext = appDelegate.managedObjectContext!
        var newCollection = NSEntityDescription.insertNewObjectForEntityForName("Collection", inManagedObjectContext: managedContext) as FlashCardCollection
        let largestID = 0 //findLargestID()
        newCollection.collectionID = largestID + 1
        newCollection.name = name
        newCollection.numCards = 0
        newCollection.progress = 100
        newCollection.last_updated = NSTimeIntervalSince1970
        newCollection.time_created = NSTimeIntervalSince1970
        newCollection.lastReviewed = NSTimeIntervalSince1970
        
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
                let largest = (results[0] as NSManagedObject).valueForKey("id") as Int
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
        let predicate = NSPredicate(format: "collectionName == '\(collectionName)'")
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
        var fetchResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        if let results = fetchResults{
            var collectionArray = Array<FlashCardCollection>()
            fetchResults = fetchResults!.reverse()
            return fetchResults as [FlashCardCollection]
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
        let frontDict = newCardDict["front"]! as NSDictionary
        let backDict = newCardDict["back"]! as NSDictionary
        if let targetCollection = searchExistingCollectionsWithName(collectionName){
            var managedContext = appDelegate.managedObjectContext!
            var flashcardEntity = NSEntityDescription.entityForName("FlashCard", inManagedObjectContext: managedContext)
            var newCard = NSManagedObject(entity: flashcardEntity!, insertIntoManagedObjectContext: targetCollection.managedObjectContext)
            
            var frontData = NSKeyedArchiver.archivedDataWithRootObject(frontDict)
            newCard.setValue(frontDict, forKey: "front")
            newCard.setValue(backDict, forKey: "back")
            newCard.setValue(0, forKey: "id")
            var error: NSError?
            
            let success = newCard.managedObjectContext!.save(&error)
            if success{
                println("SUCCESSFULLY ADDED A CARD!!!")
            }
            else{
                println("FAILED ADDING A CARD!!!")
            }
        }
    }
}
