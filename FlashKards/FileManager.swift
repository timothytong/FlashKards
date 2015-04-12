//
//  FileManager.swift
//  FlashKards
//
//  Created by Timothy Tong on 2015-04-03.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit
import Foundation
class FileManager: NSObject {
    var error: NSError?
    var paths: [AnyObject]!
    var documentsDirectory: String!
    let fileManager = NSFileManager.defaultManager()
    override init() {
        paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        documentsDirectory = paths[0] as! String
    }
    
    func createDirectoryWithName(name: String!){
        println("Creating new directory...")
        var dir = name
        var dataPath = documentsDirectory.stringByAppendingPathComponent("\(dir)")
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
        var dir = directoryName
        var dataPath = documentsDirectory.stringByAppendingPathComponent("\(dir)")
        println("Deleting all files in dir \(dataPath)")
        let url = NSURL(string: dataPath)!
        let enumerator = fileManager.enumeratorAtURL(url, includingPropertiesForKeys: nil, options: nil, errorHandler: nil)
        while let file = enumerator?.nextObject() as? String {
            println("Deleting")
            fileManager.removeItemAtURL(url.URLByAppendingPathComponent(file), error: nil)
        }
        completionHandler?()
    }
    
    func deleteDirectory(directoryName: String!, andAllItsFiles deleteAllFiles: Bool, withCompletionHandler completionHandler:()->()){
        var dir = directoryName
        if deleteAllFiles{
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
        } else{
            var originalDataPath = self.documentsDirectory.stringByAppendingPathComponent("\(dir)")
            var newDataPath = originalDataPath.stringByDeletingLastPathComponent
            println("COPYING TO DATAPATH: "+newDataPath)
            copyFilesInDirectory(originalDataPath, toDirectory: newDataPath, withCompletionHandler: { () -> () in
                if !self.fileManager.removeItemAtPath(originalDataPath, error: &self.error) {
                    println("Failed to delete directory: \(self.error!.localizedDescription)")
                }
                else{
                    println("Deleted directory \(originalDataPath)")
                }
                completionHandler()
                
            })
        }
        
    }
    
    func processString(string: String!)->String{
        let result = string.stringByReplacingOccurrencesOfString(" ", withString: "%20", options: .LiteralSearch, range: nil).stringByReplacingOccurrencesOfString("/", withString: "%2F", options: .LiteralSearch, range: nil)
        println("returning \(result)")
        return result
    }
    
    private func copyFilesInDirectory(fromDir: String, toDirectory toDir: String, withCompletionHandler handler: ()->()){
        println("from: \(fromDir)\nto: \(toDir)")
        var error: NSError?
        
        var contents = fileManager.contentsOfDirectoryAtPath(fromDir, error: &error)
        if let dirContents = contents{
            let enumerator = (dirContents as NSArray).objectEnumerator()

            while let file = enumerator.nextObject() as? String{
                let filePath = fromDir.stringByAppendingPathComponent(file)
                let destFilePath = toDir.stringByAppendingPathComponent(file)
                println("copying \(filePath)")
                if(fileManager.copyItemAtURL(NSURL(fileURLWithPath: filePath)!, toURL: NSURL(fileURLWithPath: destFilePath)!, error: &error)){
                    println("COPIED")
                }
                else{
                    println("COPY ERROR: \(error!.localizedDescription)")
                }
            }
            handler()
        }
    }
}


