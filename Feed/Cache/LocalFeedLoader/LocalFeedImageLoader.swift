//
//  LocalFeedImageLoader.swift
//  Feed
//
//  Created by hamedpouramiri on 8/23/23.
//

import Foundation

public class LocalFeedImageLoader {
    
    private let store: FeedImageStore
    
    public init(store: FeedImageStore) {
        self.store = store
    }
}

extension LocalFeedImageLoader: FeedImageCacher {
    
    public typealias SaveResult = FeedImageCacher.Result

    public enum SaveError: Error {
           case failed
    }

    public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data, for: url) { [weak self] result in
            guard self != nil else { return }
            completion(result.mapError { _ in SaveError.failed }.flatMap {.success(())})
        }
    }
}

extension LocalFeedImageLoader: FeedImageLoader {
    public typealias LoadResult = FeedImageLoader.Result

    public enum LoadError: Error {
        case failed
        case notFound
    }
    
    public func loadImage(with url: URL, completion: @escaping (LoadResult) -> Void) -> ImageLoaderTask {
        let task = LocalFeedImageLoaderTask(completion)
        store.retrieve(dataForURL: url) { [weak self] result in
            guard self != nil else { return }
            task.complete(with: result
                .mapError { _ in LoadError.failed }
                .flatMap { data in
                    data.map { .success($0) } ?? .failure(LoadError.notFound)
                }
            )
        }
        return task
    }

    private class LocalFeedImageLoaderTask: ImageLoaderTask {
         
         public typealias Result = FeedImageLoader.Result
         
         private var completion: ((Result) -> Void)?
         
         init(_ completion: (@escaping (Result) -> Void)) {
             self.completion = completion
         }
         
         func complete(with result: Result) {
             completion?(result)
         }
         
        func cancel() {
            preventFurtherCompletions()
        }

        private func preventFurtherCompletions() {
            completion = nil
        }

     }
}
