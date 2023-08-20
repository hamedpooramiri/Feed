//
//  FeedPresenter.swift
//  FeediOS
//
//  Created by hamedpouramiri on 8/20/23.
//

import Foundation
import Feed

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

protocol FeedPresenterInput {
    func loadFeed()
}

class FeedPresenter: FeedPresenterInput {
    
    private let feedLoader: FeedLoader

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var refreshView: FeedLoadingView?
    var feedView: FeedView?
    
    func loadFeed() {
        refreshView?.display(FeedLoadingViewModel(isLoading: true))
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(FeedViewModel(feed: feed))
            }
            self?.refreshView?.display(FeedLoadingViewModel(isLoading: false))
        }
    }

}
