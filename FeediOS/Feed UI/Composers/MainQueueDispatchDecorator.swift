//
//  MainQueueDispatchDecorator.swift
//  FeediOS
//
//  Created by hamedpouramiri on 8/22/23.
//

import Foundation
import Feed

final class MainQueueDispatchDecorator<T> {
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    private func dispatch(completion: @escaping ()-> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }
        completion()
    }
}

extension MainQueueDispatchDecorator: FeedLoader where T == FeedLoader {
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: FeedImageLoader where T == FeedImageLoader {
    func loadImage(with url: URL, completion: @escaping (FeedImageLoader.Result) -> Void) -> ImageLoaderTask {
        decoratee.loadImage(with: url) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
