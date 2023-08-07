//
//  RemoteFeedLoader.swift
//  Feed
//
//  Created by hamedpouramiri on 8/7/23.
//

import Foundation

public class RemoteFeedLoader: FeedLoader {
    
    private let url: URL
    private let client: HttpClient
    
    public enum Error: Swift.Error {
        case invalidData
        case connectivity
    }
    
    public init(url: URL, client: HttpClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (LoadFeedResult) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            if case let .success(data, response) = result {
                if response.statusCode == 200 {
                    if let feedItemResponse = try? JSONDecoder().decode(APIFeedItemResponse.self, from: data) {
                        
                        completion(.success(feedItemResponse.items.map(\.feedItem)))
                    } else {
                        completion(.failure(Error.invalidData))
                    }
                } else {
                    completion(.failure(Error.invalidData))
                }
            } else {
                completion(.failure(Error.connectivity))
            }
            
        }
    }

}

struct APIFeedItemResponse: Decodable {
    let items: [APIFeedItem]
}

struct APIFeedItem: Decodable {

     let id: UUID
     let description: String?
     let location: String?
     let image: URL
    
    var feedItem: FeedItem {
        FeedItem(id: id, description: description, location: location, imageUrl: image)
    }

}
