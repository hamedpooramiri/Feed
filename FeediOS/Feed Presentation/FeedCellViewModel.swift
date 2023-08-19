//
//  FeedCellViewModel.swift
//  FeediOS
//
//  Created by hamedpouramiri on 8/19/23.
//

import Foundation
import Feed

final class FeedCellViewModel<Image> {

    typealias Observer<T> = (T) -> Void
    
    private let imageLoader: FeedImageLoader
    private let model: FeedItem
    private var task: ImageLoaderTask?
    private let imageTransformer: (Data) -> Image?

    init(imageLoader: FeedImageLoader, model: FeedItem, imageTransformer: @escaping (Data) -> Image?) {
        self.imageLoader = imageLoader
        self.model = model
        self.imageTransformer = imageTransformer
    }

    var onFeedImageLoad: Observer<Image>?
    var onRetryStateChange: Observer<Bool>?
    var onIsLoadingStateChange: Observer<Bool>?
    
    var hasLocation: Bool {
        model.location != nil
    }
    
    var location: String? {
        model.location
    }
    var description: String? {
        model.description
    }

    func loadImage() {
        onIsLoadingStateChange?(true)
        task = imageLoader.loadImage(with: model.imageUrl) { [weak self] result in
            switch result {
            case .failure:
                self?.onRetryStateChange?(true)
            case .success(let imageData):
                if let image = self?.imageTransformer(imageData){
                    self?.onFeedImageLoad?(image)
                } else {
                    self?.onRetryStateChange?(true)
                }
            }
            self?.onIsLoadingStateChange?(false)
        }
    }

    func preload() {
        task = imageLoader.loadImage(with: model.imageUrl, completion: { _ in })
    }

    public func cancelLoad() {
        task?.cancel()
    }
    
}
