//
//  RemoteFeedImageLoader.swift
//  Feed
//
//  Created by hamedpouramiri on 8/23/23.
//

import Foundation

public final class RemoteFeedImageLoader: FeedImageLoader {
   
    private let client: HttpClient
    
    public enum Error: Swift.Error {
        case invalidData
        case connectivity
    }

    public typealias Result = FeedImageLoader.Result

    public init(client: HttpClient) {
        self.client = client
    }

    public func loadImage(with url: URL, completion: @escaping (Result) -> Void) -> Feed.ImageLoaderTask {
        let task = RemoteFeedImageLoaderTask(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            task.complete(
                with: result
                    .mapError { _ in Error.connectivity }
                    .flatMap { data, response in
                        let isValidResponse = response.isOK && !data.isEmpty
                        return isValidResponse ? .success(data) : .failure(Error.invalidData)
                    }
            )
        }
        return task
    }
    
   private class RemoteFeedImageLoaderTask: ImageLoaderTask {
        
        public typealias Result = FeedImageLoader.Result
        
        private var completion: ((Result) -> Void)?
        var wrapped: HTTPClientTask?
        
        init(_ completion: (@escaping (Result) -> Void)) {
            self.completion = completion
        }
        
        func complete(with result: Result) {
            completion?(result)
        }
        
        func cancel() {
            wrapped?.cancel()
        }
    }

}
