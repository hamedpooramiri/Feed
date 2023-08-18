//
//  FeedCellViewController.swift
//  FeediOS
//
//  Created by hamedpouramiri on 8/18/23.
//

import UIKit
import Feed

final class FeedCellViewController {

    let imageLoader: FeedImageLoader?
    let model: FeedItem
    var task: ImageLoaderTask?
    
    init(imageLoader: FeedImageLoader?, model: FeedItem) {
        self.imageLoader = imageLoader
        self.model = model
    }

    func view() -> UITableViewCell {
        let cell = FeedItemCell()
        cell.locationContainer.isHidden = (model.location == nil)
        cell.locationLabel.text = model.location
        cell.descriptionLabel.text = model.description
        cell.imageContainer.isShimmering = true
        cell.retryButton.isHidden = true
        cell.feedImageView.image = nil
        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }
            self.task = self.imageLoader?.loadImage(with: model.imageUrl) { [weak cell] result in
                switch result {
                case .failure:
                    cell?.retryButton.isHidden = false
                case .success(let imageData):
                    if let image = UIImage(data: imageData) {
                        cell?.feedImageView.image = image
                    } else {
                        cell?.retryButton.isHidden = false
                    }
                }
                cell?.imageContainer.isShimmering = false
            }
        }
        cell.onRetry = loadImage
        loadImage()
        return cell
    }

    func preload() {
        task = imageLoader?.loadImage(with: model.imageUrl, completion: { _ in })
    }

    deinit {
        task?.cancel()
    }
}
