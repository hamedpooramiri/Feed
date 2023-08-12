//
//  CodableFeedStore.swift
//  Feed
//
//  Created by hamedpouramiri on 8/12/23.
//

import Foundation

public class CodableFeedStore {

    let storeURL: URL

    struct Cache: Codable {
        var feedItems: [CodableFeedItem]
        var timeStamp: Date
    }

    struct CodableFeedItem: Codable {
        public let id: UUID
        public let description: String?
        public let location: String?
        public let imageUrl: URL
        
        init(localFeed: LocalFeedItem) {
            id = localFeed.id
            description = localFeed.description
            location = localFeed.location
            imageUrl = localFeed.imageUrl
        }
        
        public var localFeed: LocalFeedItem {
            .init(id: id, description: description, location: location, imageUrl: imageUrl)
        }
    }
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }

    public func insert(feeds: [LocalFeedItem], timeStamp: Date, completion: @escaping FeedStore.InsertCompletion) {
        let codablefeeds = feeds.map(CodableFeedItem.init)
        let jsonEncoded = try! JSONEncoder().encode(Cache(feedItems: codablefeeds, timeStamp: timeStamp))
        try! jsonEncoded.write(to: storeURL)
        completion(nil)
    }

   public func retrieve(completion: @escaping FeedStore.retrieveCompletion) {
       do {
           let data = try Data(contentsOf: storeURL)
           let cache = try JSONDecoder().decode(Cache.self, from: data)
           completion(.found(items: cache.feedItems.map(\.localFeed), timeStamp: cache.timeStamp))
       } catch {
           completion(.empty)
       }
   }

}
