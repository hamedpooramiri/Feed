//
//  FeedCellViewController.swift
//  FeediOS
//
//  Created by hamedpouramiri on 8/18/23.
//

import UIKit

protocol FeedCellViewControllerDelegate {
    func didRequestLoadImage()
    func didRequestPreLoad()
    func didRequestCancelLoad()
}

final class FeedCellViewController: FeedCellView {

    private let delegate: FeedCellViewControllerDelegate
    private var cell: FeedItemCell?
    
    init(delegate: FeedCellViewControllerDelegate) {
        self.delegate = delegate
    }

    func view() -> UITableViewCell {
        let cell = FeedItemCell()
        cell.onRetry = delegate.didRequestLoadImage
        cell.imageContainer.isShimmering = true
        cell.retryButton.isHidden = true
        cell.feedImageView.image = nil
        self.cell = cell
        delegate.didRequestLoadImage()
        return cell
    }

    func display(_ viewModel: FeedCellViewModel<UIImage>) {
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        cell?.imageContainer.isShimmering = viewModel.isLoading
        cell?.retryButton.isHidden = !viewModel.canRety
        cell?.feedImageView.image = viewModel.image
    }

    func preload() {
        delegate.didRequestPreLoad()
    }

    public func cancelLoad() {
        delegate.didRequestCancelLoad()
    }

}
