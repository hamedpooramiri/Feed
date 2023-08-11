//
//  FeedStore.swift
//  Feed
//
//  Created by hamedpouramiri on 8/11/23.
//

import Foundation

public enum FeedStoreRetrieveResult {
    case empty
    case failure(Error)
    case found(items: [LocalFeedItem], timeStamp: Date)
}

public protocol FeedStore {
    typealias DeleteCompletion = (Error?) -> Void
    typealias InsertCompletion = (Error?) -> Void
    typealias retrieveCompletion = (FeedStoreRetrieveResult) -> Void
    func deleteFeeds(completion: @escaping DeleteCompletion)
    func insert(feeds: [LocalFeedItem], timeStamp: Date, completion: @escaping InsertCompletion)
    func retrieve(completion: @escaping retrieveCompletion)
}
