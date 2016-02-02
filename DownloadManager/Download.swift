//
//  Download.swift
//  ReactNativeDeploy
//
//  Created by Alex Huang on 1/31/16.
//  Copyright © 2016 Alex Huang. All rights reserved.
//

import Foundation

/// The Download class represents an active download. It is immutable and provides functionality to return new Download objects given state changes.
public class Download: NSObject {
    let downloadURL: NSURL
    let destinationURL: NSURL

    let isDownloading: Bool
    let downloadTask: NSURLSessionDownloadTask?
    let resumeData: NSData?

    let progressSize: Int64
    let downloadSize: Int64
    var progress: Float {
        if downloadSize == 0 {
            return 0.0
        } else {
            return Float(progressSize) / Float(downloadSize)
        }
    }

    init(downloadURL: NSURL, destinationURL: NSURL, isDownloading: Bool, progressSize: Int64, downloadSize: Int64, downloadTask: NSURLSessionDownloadTask?, resumeData: NSData?) {
        self.downloadURL = downloadURL
        self.destinationURL = destinationURL
        self.isDownloading = isDownloading
        self.progressSize = progressSize
        self.downloadSize = downloadSize
        self.downloadTask = downloadTask
        self.resumeData = resumeData
    }

    convenience init(downloadURL: NSURL, destinationURL: NSURL) {
        self.init(downloadURL: downloadURL, destinationURL: destinationURL, isDownloading: false, progressSize: 0, downloadSize: 0, downloadTask: nil, resumeData: nil)
    }

    // MARK: Property Changes
    public func downloadWithProgress(newProgressSize: Int64, newDownloadSize: Int64) -> Download {
        return Download(downloadURL: downloadURL, destinationURL: destinationURL, isDownloading: isDownloading, progressSize: newProgressSize, downloadSize: newDownloadSize, downloadTask: downloadTask, resumeData: resumeData)
    }

    public func downloadWithPauseState(newResumeData: NSData? = nil) -> Download {
        return Download(downloadURL: downloadURL, destinationURL: destinationURL, isDownloading: false, progressSize: progressSize, downloadSize: downloadSize, downloadTask: downloadTask, resumeData: newResumeData)
    }

    public func downloadWithResumeState(newDownloadTask: NSURLSessionDownloadTask) -> Download {
        return Download(downloadURL: downloadURL, destinationURL: destinationURL, isDownloading: true, progressSize: progressSize, downloadSize: downloadSize, downloadTask: newDownloadTask, resumeData: resumeData)
    }

    // MARK: Helpers
    public func getProgressSizeString() -> String {
        return NSByteCountFormatter.stringFromByteCount(self.progressSize, countStyle: NSByteCountFormatterCountStyle.Binary)
    }

    public func getDownloadSizeString() -> String {
        return NSByteCountFormatter.stringFromByteCount(self.downloadSize, countStyle: NSByteCountFormatterCountStyle.Binary)
    }
}