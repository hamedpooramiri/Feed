//
//  FeedViewControllerAdapter.swift
//  FeediOS
//
//  Created by hamedpouramiri on 8/22/23.
//

import UIKit
import Feed

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
