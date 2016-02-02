//
//  FileManager.swift
//  ReactNativeDeploy
//
//  Created by Alex Huang on 1/31/16.
//  Copyright © 2016 Alex Huang. All rights reserved.
//

import Foundation

/// The FileManager class is a wrapper for accessing and storing files in the application's filesystem.
public class FileManager {
    // MARK: Read
    static public func getFilePath(fileName: String, fileExtension: String = "") -> NSURL? {
        return getFilePath([], fileName: fileName, fileExtension: fileExtension)
    }

    static public func getFilePath(directories: [String], fileName: String, fileExtension: String) -> NSURL? {
        var fullFilePath: NSURL?
        if let filePath: String = getDocumentPath() {
            fullFilePath = NSURL(string: filePath)
            for directoryName: String in directories {
                fullFilePath?.URLByAppendingPathComponent(directoryName, isDirectory: true)
            }
            fullFilePath?.URLByAppendingPathComponent(fileName).URLByAppendingPathExtension(fileExtension)
        }
        return fullFilePath
    }

    // MARK: Write
    static public func writeToFileSystem(filePath: NSURL, data: NSData) throws {
        let file: NSFileHandle = try NSFileHandle(forWritingToURL: filePath)
        file.writeData(data)
        file.closeFile()
    }
    
    // MARK: Copy
    static public func copyToFileSystem(sourceFilePath: NSURL, destinationFilePath: NSURL) throws {
        let fileManager: NSFileManager = NSFileManager.defaultManager()
        try fileManager.copyItemAtURL(sourceFilePath, toURL: destinationFilePath)
    }
    
    // MARK: Delete
    static public func deleteFromFileSystem(filePath: NSURL) throws {
        let fileManager: NSFileManager = NSFileManager.defaultManager()
        try fileManager.removeItemAtURL(filePath)
    }
    
    static public func deleteFromFileSystem(fileName: String, fileExtension: String = "") throws {
        if let filePath: NSURL = getFilePath(fileName, fileExtension: fileExtension) {
            try deleteFromFileSystem(filePath)
        }
    }
    
    // MARK: Private Helper Functions
    private static func getDocumentPath() -> String? {
        return NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first
    }
}