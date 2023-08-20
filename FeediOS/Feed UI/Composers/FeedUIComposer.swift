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
            let presenter = FeedCellPresenter<WeakRefVirtualProxy<FeedCellViewController>, UIImage>(imageTransformer: UIImage.init)
            let imageLoaderPresentationAdapter = ImageLoaderPresentationAdapter(imageLoader: imageLoader, presenter: presenter, model: $0)
            let controller = FeedCellViewController(delegate: imageLoaderPresentationAdapter)
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

final class ImageLoaderPresentationAdapter: FeedCellViewControllerDelegate {

    private let imageLoader: FeedImageLoader
    private let presenter: FeedCellPresenterInput
    private let model: FeedItem
    private var task: ImageLoaderTask?

    init(imageLoader: FeedImageLoader,presenter: FeedCellPresenterInput, model: FeedItem) {
        self.imageLoader = imageLoader
        self.presenter = presenter
        self.model = model
    }

    func didRequestLoadImage() {
        presenter.didStartLoadingImage(for: model)
        let model = self.model
        task = imageLoader.loadImage(with: model.imageUrl) { [weak self, model] result in
            switch result {
            case let .failure(error):
                self?.presenter.didFinishedLoadingImage(for: model, with: error)
            case .success(let imageData):
                self?.presenter.didFinishedLoadingImage(for: model, with: imageData)
            }
        }
    }
    
    func didRequestPreLoad() {
        task = imageLoader.loadImage(with: model.imageUrl, completion: { _ in })
    }
    
    func didRequestCancelLoad() {
        task?.cancel()
    }

}
