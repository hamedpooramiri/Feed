//
//  FeedUIComposer.swift
//  FeediOS
//
//  Created by hamedpouramiri on 8/18/23.
//

import UIKit
import Feed

public final class FeedUIComposer {
    private init() {}
    public static func makeFeed(loader: FeedLoader, imageLoader: FeedImageLoader) -> FeedViewController {
        let refreshController = FeedRefreshViewController(feedLoader: loader)
        let feedViewController = FeedViewController(refreshController: refreshController)
        refreshController.onRefresh = adaptFeedToCellControllers(forwardingTo: feedViewController, imageLoader: imageLoader)
        return feedViewController
    }
    // adapter pattern that convert => [feedItem] -To- [FeedCellViewController]
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, imageLoader: FeedImageLoader) -> (([FeedItem]) -> Void){
        return { [weak controller] feed in
            controller?.feed = feed.map { FeedCellViewController(imageLoader: imageLoader, model: $0) }
        }
    }
}
