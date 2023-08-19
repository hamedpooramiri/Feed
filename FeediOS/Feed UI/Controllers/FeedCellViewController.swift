//
//  FeedCellViewController.swift
//  FeediOS
//
//  Created by hamedpouramiri on 8/18/23.
//

import UIKit
import Feed

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
