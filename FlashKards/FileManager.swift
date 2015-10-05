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
    var documentsDirectory: NSURL!
    let fileManager = NSFileManager.defaultManager()
    
    override init() {
        paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        documentsDirectory = NSURL(string: paths[0] as! String)!
    }
    
    func createDirectoryWithName(name: String!){
        print("Creating new directory...")
        let dir = name
        let dataPath = documentsDirectory.URLByAppendingPathComponent("\(dir)")
        if let pathString = dataPath.path {
            if !fileManager.fileExistsAtPath(pathString) {
                do {
                    try fileManager.createDirectoryAtPath(pathString, withIntermediateDirectories: false, attributes: nil)
                    print(" -- created datapath \(dataPath)")
                } catch {
                    print("cannot create dir!!")
                }
                
            }
            else{
                print(" -- datapath \(dataPath) exists - cleanup needed!")
                deleteFilesInDirectory(name, withCompletionHandler: nil)
            }
        } else {
            "Datapath is nil!"
        }
        
    }
    
    func deleteFilesInDirectory(directoryName: String!, withCompletionHandler completionHandler:(()->())?){
        let dir = directoryName
        let dataPath = documentsDirectory.URLByAppendingPathComponent("\(dir)")
        print("Deleting all files in dir \(dataPath)")
        let enumerator = fileManager.enumeratorAtURL(dataPath, includingPropertiesForKeys: nil, options: .SkipsHiddenFiles) { (url, error) -> Bool in
            print("Error when deleting")
            return false
        }
        while let file = enumerator?.nextObject() as? String {
            do {
                print("Trying to delete \(file)")
                try self.fileManager.removeItemAtURL(dataPath.URLByAppendingPathComponent(file))
            } catch {
                print("Unable to delete \(file)")
            }
            
        }
        
        
        completionHandler?()
    }
    
    func deleteDirectory(directoryName: String!, andAllItsFiles deleteAllFiles: Bool, withCompletionHandler completionHandler:()->()){
        print("-deleteDirectory")
        let dir = directoryName
        if deleteAllFiles{
            deleteFilesInDirectory(dir, withCompletionHandler: { () -> () in
                let dataPath = self.documentsDirectory.URLByAppendingPathComponent("\(dir)")
                do {
                    try self.fileManager.removeItemAtURL(dataPath)
                    print("    Deleted directory \(dataPath)")
                } catch {
                    print("    Failed to delete directory: \(self.error!.localizedDescription)")
                }
                completionHandler()
            })
        } else{
            let originalDataPath = self.documentsDirectory.URLByAppendingPathComponent("\(dir)")
            if let newDataPath = originalDataPath.URLByDeletingLastPathComponent {
                print("    COPYING TO DATAPATH: \(newDataPath.path)")
                copyFilesInDirectory(originalDataPath, toDirectory: newDataPath, withCompletionHandler: { () -> () in
                    do {
                        try self.fileManager.removeItemAtURL(originalDataPath)
                        print("    Deleted directory \(originalDataPath.path!)")
                    } catch {
                        print("    Failed to delete directory: \(originalDataPath.path!)")
                    }
                    completionHandler()
            })
        }
        
    }
    
}

func processString(string: String!)->String{
    let result = string.stringByReplacingOccurrencesOfString(" ", withString: "%20", options: .LiteralSearch, range: nil).stringByReplacingOccurrencesOfString("/", withString: "%2F", options: .LiteralSearch, range: nil)
    print("returning \(result)")
    return result
}

private func copyFilesInDirectory(fromDir: NSURL, toDirectory toDir: NSURL, withCompletionHandler handler: ()->()){
    print("-copyFilesInDirectory")
    print("    from: \(fromDir)\nto: \(toDir)")
    do {
        let contents = try fileManager.contentsOfDirectoryAtURL(fromDir, includingPropertiesForKeys: nil, options: .SkipsHiddenFiles)
        let enumerator = (contents as NSArray).objectEnumerator()
        while let file = enumerator.nextObject() as? String{
            let filePath = fromDir.URLByAppendingPathComponent(file)
            let destFilePath = toDir.URLByAppendingPathComponent(file)
            do {
                print("    Trying to copy \(filePath) to \(destFilePath)...")
                try fileManager.copyItemAtURL(filePath, toURL: destFilePath)
                print("    COPIED")
            } catch {
                print("    ERROR WHILE COPYING")
            }
        }
        handler()
        
    } catch {
        print("    Unable to read contents of directory at \(fromDir.path!)")
    }
}
}


