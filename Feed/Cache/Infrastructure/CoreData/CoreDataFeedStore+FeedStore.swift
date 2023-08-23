//
//  CoreDataFeedStore+FeedStore.swift
//  Feed
//
//  Created by hamedpouramiri on 8/24/23.
//

import Foundation

extension CoreDataFeedStore: FeedStore {
    public func deleteFeeds(completion: @escaping DeleteCompletion) {
        perform { context in
            completion(DeleteResult {
                try ManagedCache.deleteCache(in: context)
            })
        }
    }
    
    public func insert(feeds: [Feed.LocalFeedItem], timeStamp: Date, completion: @escaping InsertCompletion) {
        perform { context in
            completion(InsertResult {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timeStamp
                managedCache.feed = ManagedFeedItem.item(from: feeds, in: context)
                try context.save()
            })
        }
    }
    
    public func retrieve(completion: @escaping retrieveCompletion) {
        perform { context in
            completion(RetrieveResult(catching: {
                try ManagedCache.find(in: context).map { cache in
                    return (items: cache.localFeed, timeStamp: cache.timestamp)
                }
            }))
        }
    }
}
