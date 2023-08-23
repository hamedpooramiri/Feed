//
//  FeedPresenter.swift
//  Feed
//
//  Created by hamedpouramiri on 8/22/23.
//

import Foundation

public protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}
public protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

public protocol FeedPresenterProtocol {
    func didStartLoadingFeed()
    func didFinishedLoadingFeed(with error: Error)
    func didFinishedLoadingFeed(with feed: [FeedItem])
}

public final class FeedPresenter: FeedPresenterProtocol {

    private let refreshView: FeedLoadingView
    private let feedView: FeedView

    public init(refreshView: FeedLoadingView, feedView: FeedView) {
        self.refreshView = refreshView
        self.feedView = feedView
    }

    public func didStartLoadingFeed() {
        refreshView.display(FeedLoadingViewModel(isLoading: true))
    }

    public func didFinishedLoadingFeed(with error: Error)  {
        refreshView.display(FeedLoadingViewModel(isLoading: false))
    }

    public func didFinishedLoadingFeed(with feed: [FeedItem]) {
        feedView.display(FeedViewModel(feed: feed))
        refreshView.display(FeedLoadingViewModel(isLoading: false))
    }
}
