//
//  FeedLoaderWithFallbackComposit.swift
//  FeedApp
//
//  Created by hamedpouramiri on 8/24/23.
//

import Feed

public final class FeedLoaderWithFallbackComposit: FeedLoader {
    
    private let primary: FeedLoader
    private let fallback: FeedLoader

    public init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }

    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                completion(result)
            case .failure:
                self.fallback.load(completion: completion)
            }
        }
    }
}
