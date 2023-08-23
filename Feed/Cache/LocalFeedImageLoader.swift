//
//  LocalFeedImageLoader.swift
//  Feed
//
//  Created by hamedpouramiri on 8/23/23.
//

import Foundation

public class LocalFeedImageLoader {
    
    public typealias Result = FeedImageLoader.Result
    
    private let store: FeedImageStore
    
    public init(store: FeedImageStore) {
        self.store = store
    }
    
    public func loadImage(with url: URL, completion: @escaping (Result) -> Void) {
        store.retrieveImage(for: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}
