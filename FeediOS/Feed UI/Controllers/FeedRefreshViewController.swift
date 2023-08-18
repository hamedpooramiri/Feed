//
//  FeedRefreshViewController.swift
//  FeediOS
//
//  Created by hamedpouramiri on 8/18/23.
//

import UIKit

final class FeedRefreshViewController: NSObject {

    private(set) lazy var view: UIRefreshControl = {
        setUpBinding(for: UIRefreshControl())
    }()
    
    private let viewModel: FeedViewModel
    
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }
   
    @objc func refresh() {
        viewModel.loadFeed()
    }

    func setUpBinding(for view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onLoadingStateChange = { [weak view] isLoading in
            if isLoading {
                view?.beginRefreshing()
            } else {
                view?.endRefreshing()
            }
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
