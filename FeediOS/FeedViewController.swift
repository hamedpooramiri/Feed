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

public class FeedViewController: UITableViewController {

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
        tasks[indexPath] = imageLoader?.loadImage(with: item.imageUrl) { [weak cell] result in
            cell?.imageContainer.isShimmering = false
        }
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
    }
}
