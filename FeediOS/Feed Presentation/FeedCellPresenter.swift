//
//  FeedCellPresenter.swift
//  FeediOS
//
//  Created by hamedpouramiri on 8/20/23.
//

import Foundation
import Feed

protocol FeedCellView {
    associatedtype Image
    func display(_ viewModel: FeedCellViewModel<Image>)
}

final class FeedCellPresenter<View: FeedCellView, Image> where View.Image == Image {

    private let imageLoader: FeedImageLoader
    private let model: FeedItem
    private var task: ImageLoaderTask?
    private let imageTransformer: (Data) -> Image?

    init(imageLoader: FeedImageLoader, model: FeedItem, imageTransformer: @escaping (Data) -> Image?) {
        self.imageLoader = imageLoader
        self.model = model
        self.imageTransformer = imageTransformer
    }

    var feedCellView: View?

    func loadImage() {
        feedCellView?.display(
            FeedCellViewModel(isLoading: true, canRety: false, location: model.location, description: model.description, image: nil)
        )
        let model = self.model
        task = imageLoader.loadImage(with: model.imageUrl) { [weak self, model] result in
            switch result {
            case .failure:
                self?.feedCellView?.display(
                    FeedCellViewModel(isLoading: false, canRety: true, location: model.location, description: model.description, image: nil)
                )
            case .success(let imageData):
                if let image = self?.imageTransformer(imageData){
                    self?.feedCellView?.display(
                        FeedCellViewModel(isLoading: false, canRety: false, location: model.location, description: model.description, image: image)
                    )
                } else {
                    self?.feedCellView?.display(
                        FeedCellViewModel(isLoading: false, canRety: true, location: model.location, description: model.description, image: nil)
                    )
                }
            }
        }
    }

    func preload() {
        task = imageLoader.loadImage(with: model.imageUrl, completion: { _ in })
    }

    public func cancelLoad() {
        task?.cancel()
    }
}
