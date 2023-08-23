//
//  CoreDataFeedStore+FeedImageStore.swift
//  Feed
//
//  Created by hamedpouramiri on 8/24/23.
//

import Foundation

extension CoreDataFeedStore: FeedImageStore {
    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageStore.InsertResult) -> Void) {
        perform { contex in
            completion(Result {
                try ManagedFeedItem.first(with: url, in: contex)
                    .map { $0.data = data }
                    .map(contex.save)
            })
        }
    }

    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageStore.RetrieveResult) -> Void) {
        perform { contex in
            completion(Result {
                 try ManagedFeedItem.first(with: url, in: contex)?.data
            })
        }
    }
}
