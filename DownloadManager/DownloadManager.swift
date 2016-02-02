//
//  DownloadManager.swift
//  ReactNativeDeploy
//
//  Created by Alex Huang on 1/31/16.
//  Copyright © 2016 Alex Huang. All rights reserved.
//

import Foundation

/// The DownloadManager class utilizes background session tasks to manage the downloading of files from the internet based on NSURLs
public class DownloadManager: NSObject {
    public static let sharedInstance: DownloadManager = {
        return DownloadManager()
    }()

    private lazy var downloadSession: NSURLSession = {
        let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("com.ReactNativeDeploy.DownloadManager.SessionConfiguration")
        let session: NSURLSession = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()

    override init() {
        super.init()
        _ = self.downloadSession
    }

    // MARK: Active Download Management
    private var downloads: [String: Download] = [String: Download]()

    public func getDownloads() -> [Download] {
        return Array(downloads.values)
    }

    public func getDownload(downloadURL: NSURL) -> Download? {
        return downloads[downloadURL.absoluteString]
    }

    // MARK: Download Management
    public func startDownload(downloadURL: NSURL, destinationFilePath: NSURL) {
        let downloadTask: NSURLSessionDownloadTask = downloadSession.downloadTaskWithURL(downloadURL)
        let download: Download = Download(downloadURL: downloadURL, destinationURL: destinationFilePath, isDownloading: true, progressSize: 0, downloadSize: 0, downloadTask: downloadTask, resumeData: nil)
        download.downloadTask?.resume()
        registerActiveDownload(download)
    }

    public func pauseDownload(downloadURL: NSURL) {
        if let download: Download = getDownload(downloadURL) where download.isDownloading {
            download.downloadTask?.cancelByProducingResumeData({ (data: NSData?) -> Void in
                self.registerActiveDownload(download.downloadWithPauseState(data))
            })
        }
    }

    public func resumeDownload(downloadURL: NSURL) {
        if let download: Download = getDownload(downloadURL) {
            let downloadTask: NSURLSessionDownloadTask
            if let resumeData = download.resumeData {
                downloadTask = downloadSession.downloadTaskWithResumeData(resumeData)
            } else {
                downloadTask = downloadSession.downloadTaskWithURL(download.downloadURL)
            }
            download.downloadTask?.resume()
            registerActiveDownload(download.downloadWithResumeState(downloadTask))
        }
    }

    public func cancelDownload(downloadURL: NSURL) {
        if let download: Download = getDownload(downloadURL) {
            download.downloadTask?.cancel()
            downloads[downloadURL.absoluteString] = nil
        }
    }
    
    // MARK: Private Helper Functions
    private func registerActiveDownload(download: Download) {
        var newDownloads = downloads.filter { _,_ in return true }
        newDownloads.append((download.downloadURL.absoluteString, download))
        downloads = toDictionary(newDownloads) { ($0.0, $0.1) }
    }

    private func removeActiveDownload(downloadURL: NSURL) {
        let downloadURLString: String = downloadURL.absoluteString
        let newDownloads: [(String, Download)] = downloads.filter({ (tuple: (downloadURLString: String, download: Download)) -> Bool in
            return downloadURLString != tuple.downloadURLString
        })
        downloads = toDictionary(newDownloads) { ($0.0, $0.1) }
    }

    // Takes a tuple and transforms into a dictionary. Dictionary filter function unfortunately returns a tuple array so this is a workaround.
    private func toDictionary<E, K: Hashable, V>(array: [E], transformer: (element: E) -> (key: K, value: V)?) -> Dictionary<K, V> {
        return array.reduce([:]) { (var dictionary, element) in
            if let (key, value) = transformer(element: element)
            {
                dictionary[key] = value
            }
            return dictionary
        }
    }
}

// MARK: NSURLSessionDownloadDelegate
extension DownloadManager: NSURLSessionDownloadDelegate {
    @objc public func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        if let downloadURL: NSURL = downloadTask.originalRequest?.URL,
            let download: Download = getDownload(downloadURL) {
                let destinationURL = download.destinationURL
                do {
                    try FileManager.deleteFromFileSystem(destinationURL)
                    try FileManager.copyToFileSystem(downloadURL, destinationFilePath: destinationURL)
                } catch {
                    // Note: Intentionally Do Nothing
                }
                removeActiveDownload(downloadURL)
        }
    }

    public func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if let downloadURL: NSURL = downloadTask.originalRequest?.URL,
            let download: Download = getDownload(downloadURL) {
                registerActiveDownload(download.downloadWithProgress(totalBytesWritten, newDownloadSize: totalBytesExpectedToWrite))
        }
    }
}