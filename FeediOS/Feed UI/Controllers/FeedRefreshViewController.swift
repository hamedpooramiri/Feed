//
//  FeedRefreshViewController.swift
//  FeediOS
//
//  Created by hamedpouramiri on 8/18/23.
//

import UIKit
import Feed

class FeedViewModel {

    let feedLoader: FeedLoader

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    var onChange: ((FeedViewModel) -> Void)?
    var onLoad: (([FeedItem]) -> Void)?
    
    var isLoading: Bool = false {
        didSet {
            onChange?(self)
        }
    }
    
    func load() {
        isLoading = true
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onLoad?(feed)
            }
            self?.isLoading = false
        }
    }

}


final class FeedRefreshViewController: NSObject {

    private(set) lazy var view: UIRefreshControl = {
        setUpBinding(for: UIRefreshControl())
    }()
    
    private let viewModel: FeedViewModel
    
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }
   
    @objc func refresh() {
        viewModel.load()
    }

    func setUpBinding(for view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onChange = { [weak view] viewModel in
            if viewModel.isLoading {
                view?.beginRefreshing()
            } else {
                view?.endRefreshing()
            }
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
