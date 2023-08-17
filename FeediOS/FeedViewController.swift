//
//  FeedViewController.swift
//  FeediOS
//
//  Created by hamedpouramiri on 8/16/23.
//

import UIKit
import Feed

public protocol ImageLoaderTask {
    func cancel()
}

public protocol ImageLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImage(with url: URL, completion:  @escaping (Result) -> Void) -> ImageLoaderTask
}

public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    
    private var feedLoader: FeedLoader?
    private var imageLoader: ImageLoader?

    private var feed: [FeedItem] = []
    private var tasks: [IndexPath: ImageLoaderTask] = [:]

    public convenience init(loader: FeedLoader, imageLoader: ImageLoader) {
        self.init()
        self.feedLoader = loader
        self.imageLoader = imageLoader
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        tableView.prefetchDataSource = self
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        feedLoader?.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feed = feed
            }
            self?.tableView.reloadData()
            self?.refreshControl?.endRefreshing()
        }
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = feed[indexPath.row]
        let cell = FeedItemCell()
        cell.locationContainer.isHidden = (item.location == nil)
        cell.locationLabel.text = item.location
        cell.descriptionLabel.text = item.description
        cell.imageContainer.isShimmering = true
        cell.retryButton.isHidden = true
        cell.feedImageView.image = nil
        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }
            self.tasks[indexPath] = self.imageLoader?.loadImage(with: item.imageUrl) { [weak cell] result in
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
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelTask(forRowAt: indexPath)
        
    }

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let model = feed[indexPath.row]
            tasks[indexPath] = imageLoader?.loadImage(with: model.imageUrl) { _ in }
        }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cancelTask(forRowAt: indexPath)
        }
    }

    private func cancelTask(forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
}
