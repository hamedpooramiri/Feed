//
//  FeedViewModel.swift
//  FeediOS
//
//  Created by hamedpouramiri on 8/19/23.
//

import Foundation
import Feed

class FeedViewModel {

    typealias Observer<T> = (T) -> Void
    
    let feedLoader: FeedLoader

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    var onLoadingStateChange: Observer<Bool>?
    var onFeedLoad: Observer<[FeedItem]>?
    
    func loadFeed() {
        onLoadingStateChange?(true)
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.onLoadingStateChange?(false)
        }
    }

}
