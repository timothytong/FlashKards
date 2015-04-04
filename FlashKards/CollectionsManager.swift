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
    private var managedContext: NSManagedObjectContext!
    private var entity: NSEntityDescription!
    override init(){
        super.init()
        appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        managedContext = appDelegate.managedObjectContext!
        entity = NSEntityDescription.entityForName("Collection", inManagedObjectContext: managedContext)
    }
    
    func addCollection(collection: FlashCardCollection!, completionHandler:(success:Bool)->()){
        let largestID = findLargestID()
        let newCollection = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        newCollection.setValue(collection.collectionName, forKey: "name")
        newCollection.setValue(collection.progress, forKey: "progress")
        newCollection.setValue(collection.lastReviewed, forKey: "lastReviewed")
        newCollection.setValue(collection.numCards, forKey: "numCards")
        newCollection.setValue(largestID+1, forKey: "id")
        // println("Saving, assigning id \(largestID+1)")
        var error: NSError?
        let success = managedContext.save(&error)
        completionHandler(success: success)
    }
    
    func findLargestID()->Int{
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
            managedContext.deleteObject(collectionCoreDataObj)
            var error: NSError?
            let success = managedContext.save(&error)
            completionHandler(success: success)
        }
    }
    
    func fetchCollections()->Array<FlashCardCollection>{
        let fetchRequest = NSFetchRequest(entityName: "Collection")
        var error:NSError?
        var fetchResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        if let results = fetchResults{
            var collectionArray = Array<FlashCardCollection>()
            fetchResults = fetchResults!.reverse()
            for fetchResult in fetchResults!{
                collectionArray.append(convertCDObjectToCollection(fetchResult))
            }
            return collectionArray
        }
        else {
            // println("Could not fetch \(error), \(error!.userInfo)")
            return []
        }
    }
    
    func convertCDObjectToCollection(cdObject: NSManagedObject)->FlashCardCollection{
        let collection = FlashCardCollection(
            collectionName: cdObject.valueForKey("name")? as String!,
            progress: cdObject.valueForKey("progress")? as Int,
            lastReviewed: cdObject.valueForKey("lastReviewed")? as String!,
            numCards: cdObject.valueForKey("numCards")? as Int!,
            id: cdObject.valueForKey("id") as Int!
        )
        return collection
    }
}
