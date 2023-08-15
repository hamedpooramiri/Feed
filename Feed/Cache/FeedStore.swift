//
//  FeedStore.swift
//  Feed
//
//  Created by hamedpouramiri on 8/11/23.
//

import Foundation

public typealias CachedFeed = (items: [LocalFeedItem], timeStamp: Date)

public protocol FeedStore {

    typealias DeleteResult = Result<Void, Error>
    typealias DeleteCompletion = (DeleteResult) -> Void

    typealias InsertResult = Result<Void, Error>
    typealias InsertCompletion = (InsertResult) -> Void

    typealias RetrieveResult = Result<CachedFeed?, Error>
    typealias retrieveCompletion = (RetrieveResult) -> Void

    func deleteFeeds(completion: @escaping DeleteCompletion)
    func insert(feeds: [LocalFeedItem], timeStamp: Date, completion: @escaping InsertCompletion)
    func retrieve(completion: @escaping retrieveCompletion)
}
