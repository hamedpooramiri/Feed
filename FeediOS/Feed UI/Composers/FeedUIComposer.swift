//
//  FeedUIComposer.swift
//  FeediOS
//
//  Created by hamedpouramiri on 8/18/23.
//

import UIKit
import Feed

// finish implementing UI Module on MVVM designPattern
public final class FeedUIComposer {
    private init() {}
    public static func makeFeed(loader: FeedLoader, imageLoader: FeedImageLoader) -> FeedViewController {
        let presenter = FeedPresenter(feedLoader: loader)
        let refreshController = FeedRefreshViewController(presenter: presenter)
        let feedViewController = FeedViewController(refreshController: refreshController)
        presenter.refreshView = WeakRefVirtualProxy(refreshController)
        presenter.feedView = FeedViewAdapter(controller: feedViewController, imageLoader: imageLoader)
        return feedViewController
    }
}
// Proxy Design pattern for hide the real object and break the retain cycle
final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?

    init(_ object: T? = nil) {
        self.object = object
    }
}
// Forward the action to the real object
extension WeakRefVirtualProxy: RefreshView where T: RefreshView {
    func display(_ viewModel: LoadingViewModel) {
        object?.display(viewModel)
    }
}

// adapter pattern that convert => [feedItem] -To- [FeedCellViewController]
final class FeedViewAdapter: FeedView {
    // make refrence to Controller Weak  to prevent the memory leak
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageLoader
    
    init(controller: FeedViewController?, imageLoader: FeedImageLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModell) {
        controller?.feed = viewModel.feed.map {
            let feedCellViewModel = FeedCellViewModel(imageLoader: imageLoader, model: $0, imageTransformer: UIImage.init)
            return FeedCellViewController(viewModel: feedCellViewModel)
        }
    }
}
