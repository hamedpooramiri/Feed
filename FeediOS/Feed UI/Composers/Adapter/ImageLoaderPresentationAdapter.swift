//
//  ImageLoaderPresentationAdapter.swift
//  FeediOS
//
//  Created by hamedpouramiri on 8/22/23.
//

import Foundation
import Feed

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
