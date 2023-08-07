//
//  RemoteFeedLoader.swift
//  Feed
//
//  Created by hamedpouramiri on 8/7/23.
//

import Foundation

public enum Result {
    case success(HTTPURLResponse)
    case failure(RemoteFeedLoader.Error)
}

public protocol HttpClient {
    func get(from url: URL, completion: @escaping (Result) -> Void)
}

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
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            if case .success(let response) = result, response.statusCode != 200 {
                completion(.failure(.invalidData))
            } else {
                completion(result)
            }
        
        }
    }

}
