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
        
        let feedLoaderPresentationAdapter = FeedLoaderPresentationAdapter(feedLoader: MainQueueDispatchDecorator(decoratee: loader))
        let refreshController = FeedRefreshViewController(delegate: feedLoaderPresentationAdapter)
        let feedViewController = FeedViewController(refreshController: refreshController)
        let feedViewAdapter = FeedViewControllerAdapter(controller: feedViewController, imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader))
        let presenter = FeedPresenter(refreshView: WeakRefVirtualProxy(refreshController), feedView: feedViewAdapter)
        feedLoaderPresentationAdapter.presenter = presenter
        return feedViewController
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
            let imageLoaderPresentationAdapter = ImageLoaderPresentationAdapter(imageLoader: imageLoader, model: $0)
            let controller = FeedCellViewController(delegate: imageLoaderPresentationAdapter)
            let presenter = FeedCellPresenter<WeakRefVirtualProxy<FeedCellViewController>, UIImage>(feedCellView: WeakRefVirtualProxy(controller), imageTransformer: UIImage.init)
            imageLoaderPresentationAdapter.presenter = presenter
            return controller
        }
    }
}

final class ImageLoaderPresentationAdapter: FeedCellViewControllerDelegate {

    private let imageLoader: FeedImageLoader
    var presenter: FeedCellPresenterInput?
    private let model: FeedItem
    private var task: ImageLoaderTask?

    init(imageLoader: FeedImageLoader, model: FeedItem) {
        self.imageLoader = imageLoader
        self.model = model
    }

    func didRequestLoadImage() {
        presenter?.didStartLoadingImage(for: model)
        let model = self.model
        task = imageLoader.loadImage(with: model.imageUrl) { [weak self, model] result in
            switch result {
            case let .failure(error):
                self?.presenter?.didFinishedLoadingImage(for: model, with: error)
            case .success(let imageData):
                self?.presenter?.didFinishedLoadingImage(for: model, with: imageData)
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
