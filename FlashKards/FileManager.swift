//
//  FileManager.swift
//  FlashKards
//
//  Created by Timothy Tong on 2015-04-03.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit

class FileManager: NSObject {
    var error: NSError?
    var paths: [AnyObject]!
    var documentsDirectory: String!
    let fileManager = NSFileManager.defaultManager()
    override init() {
        paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        documentsDirectory = paths[0] as String
    }
    
    func createDirectoryWithName(name: String!){
        println("Creating new directory...")
        var dir = processString(name)
        var dataPath = documentsDirectory.stringByAppendingPathComponent("\(name)")
        if (!fileManager.fileExistsAtPath(dataPath)) {
            fileManager.createDirectoryAtPath(dataPath, withIntermediateDirectories: false, attributes: nil, error: &error)
            println(" -- created datapath \(dataPath)")
        }
        else{
            println(" -- datapath \(dataPath) exists - cleanup needed!")
            deleteFilesInDirectory(name, withCompletionHandler: nil)
        }
    }
    
    func deleteFilesInDirectory(directoryName: String!, withCompletionHandler completionHandler:(()->())?){
        var dir = processString(directoryName)
        var dataPath = documentsDirectory.stringByAppendingPathComponent("\(dir)")
        let url = NSURL(string: dataPath)!
        let enumerator = fileManager.enumeratorAtURL(url, includingPropertiesForKeys: nil, options: nil, errorHandler: nil)
        while let file = enumerator?.nextObject() as? String {
            fileManager.removeItemAtURL(url.URLByAppendingPathComponent(file), error: nil)
        }
        completionHandler?()
    }
    
    func deleteDirectory(directoryName: String!, withCompletionHandler completionHandler:()->()){
        var dir = processString(directoryName)
        deleteFilesInDirectory(dir, withCompletionHandler: { () -> () in
            var dataPath = self.documentsDirectory.stringByAppendingPathComponent("\(dir)")
            if !self.fileManager.removeItemAtPath(dataPath, error: &self.error) {
                println("Failed to delete directory: \(self.error!.localizedDescription)")
            }
            else{
                println("Deleted directory \(dataPath)")
            }
            completionHandler()
        })
    }
    
    func processString(string: String!)->String{
        return string.stringByReplacingOccurrencesOfString(" ", withString: "%20", options: .LiteralSearch, range: nil).stringByReplacingOccurrencesOfString("/", withString: "%2F", options: .LiteralSearch, range: nil)
    }
}


