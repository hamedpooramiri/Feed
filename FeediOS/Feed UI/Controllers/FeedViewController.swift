//
//  FeedViewController.swift
//  FeediOS
//
//  Created by hamedpouramiri on 8/16/23.
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

public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    
    private var refreshController: FeedRefreshViewController?
    private var imageLoader: FeedImageLoader?

    private var feed: [FeedItem] = []
    private var cellControllers: [IndexPath: FeedCellViewController] = [:]

    public convenience init(loader: FeedLoader, imageLoader: FeedImageLoader) {
        self.init()
        self.refreshController = FeedRefreshViewController(feedLoader: loader)
        self.imageLoader = imageLoader
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = refreshController?.view
        tableView.prefetchDataSource = self
        refreshController?.onRefresh = { [weak self] feed in
            self?.feed = feed
            self?.tableView.reloadData()
        }
        refreshController?.refresh()
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         controller(forRowAt: indexPath).view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        removeController(forRowAt: indexPath)
    }

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            controller(forRowAt: indexPath).preload()
        }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            removeController(forRowAt: indexPath)
        }
    }

    func controller(forRowAt indexPath: IndexPath) -> FeedCellViewController {
        let item = feed[indexPath.row]
        let controller = FeedCellViewController(imageLoader: imageLoader, model: item)
        cellControllers[indexPath] = controller
        return controller
    }
    
    private func removeController(forRowAt indexPath: IndexPath) {
        cellControllers[indexPath] = nil
    }
}
