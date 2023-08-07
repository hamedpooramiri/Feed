//
//  RemoteFeedLoader.swift
//  Feed
//
//  Created by hamedpouramiri on 8/7/23.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HttpClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public class RemoteFeedLoader {
    
    private let url: URL
    private let client: HttpClient
    
    public enum Error: Swift.Error {
        case invalidData
        case connectivity
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(RemoteFeedLoader.Error)
    }
    
    public init(url: URL, client: HttpClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            if case let .success(data, response) = result {
                if response.statusCode == 200 {
                    if let feedItemResponse = try? JSONDecoder().decode(APIFeedItemResponse.self, from: data) {
                        
                        completion(.success(feedItemResponse.items.map(\.feedItem)))
                    } else {
                        completion(.failure(.invalidData))
                    }
                } else {
                    completion(.failure(.invalidData))
                }
            } else {
                completion(.failure(.connectivity))
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
