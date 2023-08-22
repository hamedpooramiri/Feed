//
//  WeakRefVirtualProxy.swift
//  FeediOS
//
//  Created by hamedpouramiri on 8/22/23.
//

import Foundation
import Feed
// Proxy Design pattern for hide the real object and break the retain cycle
final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?

    init(_ object: T? = nil) {
        self.object = object
    }
}
// Forward the action to the real object
extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

// Forward the action to the real object
extension WeakRefVirtualProxy: FeedCellView where T: FeedCellView {
    func display(_ viewModel: FeedCellViewModel<T.Image>) {
        object?.display(viewModel)
    }
}
