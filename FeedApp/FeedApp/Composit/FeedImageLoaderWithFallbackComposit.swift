//
//  FeedImageLoaderWithFallbackComposit.swift
//  FeedApp
//
//  Created by hamedpouramiri on 8/24/23.
//

import Feed

public final class FeedImageLoaderWithFallbackComposit: FeedImageLoader {
    
    private let primary: FeedImageLoader
    private let fallback: FeedImageLoader

    public init(primary: FeedImageLoader, fallback: FeedImageLoader) {
        self.primary = primary
        self.fallback = fallback
    }

    public func loadImage(with url: URL, completion: @escaping (FeedImageLoader.Result) -> Void) -> Feed.ImageLoaderTask {
        let task = WrappedTask()
        task.wrapped = primary.loadImage(with: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                completion(result)
            case .failure:
                task.wrapped = self.fallback.loadImage(with: url, completion: completion)
            }
        }
        return task
    }

    class WrappedTask: ImageLoaderTask {
        var wrapped: ImageLoaderTask?
        
        func cancel() {
            wrapped?.cancel()
        }
    }

}
