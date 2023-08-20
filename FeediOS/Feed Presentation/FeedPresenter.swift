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

protocol FeedPresenterProtocol {
    func didStartLoadingFeed()
    func didFinishedLoadingFeed(with error: Error)
    func didFinishedLoadingFeed(with feed: [FeedItem])
}

class FeedPresenter: FeedPresenterProtocol {

    let refreshView: FeedLoadingView
    let feedView: FeedView
    
    init(refreshView: FeedLoadingView, feedView: FeedView) {
        self.refreshView = refreshView
        self.feedView = feedView
    }
    
    func didStartLoadingFeed() {
        refreshView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishedLoadingFeed(with error: Error) {
        refreshView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishedLoadingFeed(with feed: [FeedItem]) {
        feedView.display(FeedViewModel(feed: feed))
        refreshView.display(FeedLoadingViewModel(isLoading: false))
    }

}
