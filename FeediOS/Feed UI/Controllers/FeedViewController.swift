//
//  FeedViewController.swift
//  FeediOS
//
//  Created by hamedpouramiri on 8/16/23.
//

import UIKit
import Feed

public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    
    private var refreshController: FeedRefreshViewController?
    var feed: [FeedCellViewController] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    convenience init(refreshController: FeedRefreshViewController) {
        self.init()
        self.refreshController = refreshController
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = refreshController?.view
        tableView.prefetchDataSource = self
        refreshController?.refresh()
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         controller(forRowAt: indexPath).view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelController(forRowAt: indexPath)
    }

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            controller(forRowAt: indexPath).preload()
        }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cancelController(forRowAt: indexPath)
        }
    }

    func controller(forRowAt indexPath: IndexPath) -> FeedCellViewController {
        feed[indexPath.row]
    }
    
    private func cancelController(forRowAt indexPath: IndexPath) {
        feed[indexPath.row].cancelLoad()
        
    }
}
