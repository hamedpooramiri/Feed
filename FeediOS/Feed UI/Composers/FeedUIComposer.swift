//
//  FeedUIComposer.swift
//  FeediOS
//
//  Created by hamedpouramiri on 8/18/23.
//

import UIKit
import Feed

// finish implementing UI Module on MVP designPattern biDirectunal communication between Presenter and View
// and to prevent memory leak we use WeakRefVirtualProxy wapper on View
public final class FeedUIComposer {
    private init() {}
    public static func makeFeed(loader: FeedLoader, imageLoader: FeedImageLoader) -> FeedViewController {
        
        let feedLoaderPresentationAdapter = FeedLoaderPresentationAdapter(feedLoader: loader)
        let refreshController = FeedRefreshViewController(delegate: feedLoaderPresentationAdapter)
        let feedViewController = FeedViewController(refreshController: refreshController)
        let feedViewAdapter = FeedViewControllerAdapter(controller: feedViewController, imageLoader: imageLoader)
        let presenter = FeedPresenter(refreshView: WeakRefVirtualProxy(refreshController), feedView: feedViewAdapter)
        feedLoaderPresentationAdapter.presenter = presenter
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
extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

// adapter pattern that convert => [feedItem] -To- [FeedCellViewController]
final class FeedViewControllerAdapter: FeedView {
    // make refrence to Controller Weak  to prevent the memory leak
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageLoader
    
    init(controller: FeedViewController?, imageLoader: FeedImageLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.feed = viewModel.feed.map {
            let presenter = FeedCellPresenter<WeakRefVirtualProxy<FeedCellViewController>, UIImage>(imageLoader: imageLoader, model: $0, imageTransformer: UIImage.init)
            let controller = FeedCellViewController(presenter: presenter)
            presenter.feedCellView = WeakRefVirtualProxy(controller)
            return controller
        }
    }
}

// Forward the action to the real object
extension WeakRefVirtualProxy: FeedCellView where T: FeedCellView {
    func display(_ viewModel: FeedCellViewModel<T.Image>) {
        object?.display(viewModel)
    }
}

final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    
    private let feedLoader: FeedLoader
    var presenter: FeedPresenterProtocol?

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        feedLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishedLoadingFeed(with: feed)
            case let .failure(error):
                self?.presenter?.didFinishedLoadingFeed(with: error)
            }
        }
    }

}
