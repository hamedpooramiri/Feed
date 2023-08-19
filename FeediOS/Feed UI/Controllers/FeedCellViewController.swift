//
//  FeedCellViewController.swift
//  FeediOS
//
//  Created by hamedpouramiri on 8/18/23.
//

import UIKit
import Feed


final class FeedCellViewModel<Image> {

    typealias Observer<T> = (T) -> Void
    
    private let imageLoader: FeedImageLoader
    private let model: FeedItem
    private var task: ImageLoaderTask?
    private let imageTransformer: (Data) -> Image?

    init(imageLoader: FeedImageLoader, model: FeedItem, imageTransformer: @escaping (Data) -> Image?) {
        self.imageLoader = imageLoader
        self.model = model
        self.imageTransformer = imageTransformer
    }

    var onFeedImageLoad: Observer<Image>?
    var onRetryStateChange: Observer<Bool>?
    var onIsLoadingStateChange: Observer<Bool>?
    
    var hasLocation: Bool {
        model.location != nil
    }
    
    var location: String? {
        model.location
    }
    var description: String? {
        model.description
    }

    func loadImage() {
        onIsLoadingStateChange?(true)
        task = imageLoader.loadImage(with: model.imageUrl) { [weak self] result in
            switch result {
            case .failure:
                self?.onRetryStateChange?(true)
            case .success(let imageData):
                if let image = self?.imageTransformer(imageData){
                    self?.onFeedImageLoad?(image)
                } else {
                    self?.onRetryStateChange?(true)
                }
            }
            self?.onIsLoadingStateChange?(false)
        }
    }

    func preload() {
        task = imageLoader.loadImage(with: model.imageUrl, completion: { _ in })
    }

    public func cancelLoad() {
        task?.cancel()
    }
    
}

final class FeedCellViewController {

    let viewModel: FeedCellViewModel<UIImage>
    
    init(viewModel: FeedCellViewModel<UIImage>) {
        self.viewModel = viewModel
    }

    func view() -> UITableViewCell {
        let cell = binded(FeedItemCell())
        viewModel.loadImage()
        return cell
    }

    private func binded(_ cell: FeedItemCell) -> FeedItemCell {
        cell.locationContainer.isHidden = !viewModel.hasLocation
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        cell.imageContainer.isShimmering = true
        cell.retryButton.isHidden = true
        cell.feedImageView.image = nil
        
        viewModel.onFeedImageLoad = { [weak cell] image in
            cell?.feedImageView.image = image
        }
        
        viewModel.onRetryStateChange = { [weak cell] canRetry in
            cell?.retryButton.isHidden = !canRetry
        }

        viewModel.onIsLoadingStateChange = { [weak cell] isLoading in
            cell?.imageContainer.isShimmering = isLoading
        }

        cell.onRetry = viewModel.loadImage
        return cell
    }

    func preload() {
        viewModel.preload()
    }

    public func cancelLoad() {
        viewModel.cancelLoad()
    }

}
