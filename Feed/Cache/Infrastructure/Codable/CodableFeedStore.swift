//
//  CodableFeedStore.swift
//  Feed
//
//  Created by hamedpouramiri on 8/12/23.
//

import Foundation

public class CodableFeedStore: FeedStore {

    private let storeURL: URL
    private let queue =  DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)

    public init(storeURL: URL) {
        self.storeURL = storeURL
    }

    public func insert(feeds: [LocalFeedItem], timeStamp: Date, completion: @escaping InsertCompletion) {
        let storeURL = storeURL
        queue.async(flags: .barrier) {
            let feedItems = feeds.map(CodableFeedItem.init)
            let cache = Cache(feedItems: feedItems, timeStamp: timeStamp)
            completion(Result(catching: {
                let jsonEncoded = try JSONEncoder().encode(cache)
                try jsonEncoded.write(to: storeURL)
            }))
        }
    }

    public func retrieve(completion: @escaping retrieveCompletion) {
        let storeURL = storeURL
        queue.async {
            completion(RetrieveResult(catching: {
                guard let data = try? Data(contentsOf: storeURL) else {
                    return .none
                }
                let cache = try JSONDecoder().decode(Cache.self, from: data)
                return (items: cache.feedItems.map(\.localFeed), timeStamp: cache.timeStamp)
            }))
        }
    }

    public func deleteFeeds(completion: @escaping DeleteCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            completion(Result {
                guard FileManager.default.fileExists(atPath: storeURL.path()) else {
                    return
                }
                try FileManager.default.removeItem(at: storeURL)
            })
        }
    }
}

extension CodableFeedStore {

    private struct Cache: Codable {
        var feedItems: [CodableFeedItem]
        var timeStamp: Date
    }

    private struct CodableFeedItem: Codable {
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

}
