//
//  FeedPresenter.swift
//  FeediOS
//
//  Created by hamedpouramiri on 8/20/23.
//

import Foundation
import Feed

struct LoadingViewModel {
    let isLoading: Bool
}

protocol RefreshView {
    func display(_ viewModel: LoadingViewModel)
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

class FeedPresenter {
    
    private let feedLoader: FeedLoader

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var refreshView: RefreshView?
    var feedView: FeedView?
    
    func loadFeed() {
        refreshView?.display(LoadingViewModel(isLoading: true))
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(FeedViewModel(feed: feed))
            }
            self?.refreshView?.display(LoadingViewModel(isLoading: false))
        }
    }

}
