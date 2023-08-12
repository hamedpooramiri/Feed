//
//  CodableFeedStore.swift
//  Feed
//
//  Created by hamedpouramiri on 8/12/23.
//

import Foundation

public class CodableFeedStore: FeedStore {

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

    public func insert(feeds: [LocalFeedItem], timeStamp: Date, completion: @escaping InsertCompletion) {
        let feedItems = feeds.map(CodableFeedItem.init)
        let cache = Cache(feedItems: feedItems, timeStamp: timeStamp)
        do {
            let jsonEncoded = try JSONEncoder().encode(cache)
            try jsonEncoded.write(to: storeURL)
            completion(nil)
        } catch{
           completion(error)
        }
    }

   public func retrieve(completion: @escaping retrieveCompletion) {
       do {
           guard let data = try? Data(contentsOf: storeURL) else {
               return completion(.empty)
           }
           let cache = try JSONDecoder().decode(Cache.self, from: data)
           completion(.found(items: cache.feedItems.map(\.localFeed), timeStamp: cache.timeStamp))
       } catch {
           completion(.failure(error))
       }
   }

    public func deleteFeeds(completion: @escaping DeleteCompletion) {
        do {
            guard FileManager.default.fileExists(atPath: storeURL.path()) else {
                return completion(nil)
            }
            try FileManager.default.removeItem(at: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
}
