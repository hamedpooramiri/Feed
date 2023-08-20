//
//  FeedCellViewController.swift
//  FeediOS
//
//  Created by hamedpouramiri on 8/18/23.
//

import UIKit

final class FeedCellViewController: FeedCellView {

    private let presenter: FeedCellPresenter<WeakRefVirtualProxy<FeedCellViewController>, UIImage>
    private var cell: FeedItemCell?
    
    init(presenter: FeedCellPresenter<WeakRefVirtualProxy<FeedCellViewController>, UIImage>) {
        self.presenter = presenter
    }

    func view() -> UITableViewCell {
        let cell = FeedItemCell()
        cell.onRetry = presenter.loadImage
        cell.imageContainer.isShimmering = true
        cell.retryButton.isHidden = true
        cell.feedImageView.image = nil
        self.cell = cell
        presenter.loadImage()
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
        presenter.preload()
    }

    public func cancelLoad() {
        presenter.cancelLoad()
    }

}
