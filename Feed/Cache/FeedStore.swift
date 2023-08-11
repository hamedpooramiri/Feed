//
//  FeedStore.swift
//  Feed
//
//  Created by hamedpouramiri on 8/11/23.
//

import Foundation

public protocol FeedStore {
    typealias DeleteCompletion = (Error?) -> Void
    typealias InsertCompletion = (Error?) -> Void
    func deleteFeeds(compeletion: @escaping DeleteCompletion)
    func insert(feeds: [LocalFeedItem], timeStamp: Date, completion: @escaping InsertCompletion)
}
