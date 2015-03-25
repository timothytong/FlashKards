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
    
    func saveCollection(collection: FlashCardCollection!, completionHandler:(success:Bool, newCollectionCDObject: NSManagedObject)->Void){
        println("Saving")
        let newCollection = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        newCollection.setValue(collection.collectionName, forKey: "name")
        newCollection.setValue(collection.progress, forKey: "progress")
        newCollection.setValue(collection.lastReviewed, forKey: "lastReviewed")
        newCollection.setValue(collection.numCards, forKey: "numCards")
        var error: NSError?
        let success = managedContext.save(&error)
        completionHandler(success: success, newCollectionCDObject: newCollection)
    }
    
    func searchExistingCollectionsWithName(collectionName: String!)->NSManagedObject?{
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let entity = NSEntityDescription.entityForName("Collection", inManagedObjectContext: managedContext)
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
            return (results[0] as NSManagedObject)
        }
        return nil
    }
    
    func deleteCollectionWithName(name: String!, completionHandler:(success: Bool)->Void){
        if let collectionCoreDataObj = searchExistingCollectionsWithName(name){
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            managedContext.deleteObject(collectionCoreDataObj)
            var error: NSError?
            let success = managedContext.save(&error)
            completionHandler(success: success)
        }
    }

}
