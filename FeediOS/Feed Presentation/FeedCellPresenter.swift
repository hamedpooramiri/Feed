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

protocol FeedCellPresenterInput {
    func didStartLoadingImage(for model: FeedItem)
    func didFinishedLoadingImage(for model: FeedItem, with error: Error)
    func didFinishedLoadingImage(for model: FeedItem, with imageData: Data)
}

final class FeedCellPresenter<View: FeedCellView, Image> where View.Image == Image {

    private let imageTransformer: (Data) -> Image?
    var feedCellView: View?

    init(imageTransformer: @escaping (Data) -> Image?) {
        self.imageTransformer = imageTransformer
    }

}

extension FeedCellPresenter: FeedCellPresenterInput {
    func didStartLoadingImage(for model: Feed.FeedItem) {
        feedCellView?.display(
            FeedCellViewModel(isLoading: true, canRety: false, location: model.location, description: model.description, image: nil)
        )
    }
    
    func didFinishedLoadingImage(for model: Feed.FeedItem, with error: Error) {
        feedCellView?.display(
            FeedCellViewModel(isLoading: false, canRety: true, location: model.location, description: model.description, image: nil)
        )
    }
    
    func didFinishedLoadingImage(for model: Feed.FeedItem, with imageData: Data) {
        if let image = imageTransformer(imageData){
            feedCellView?.display(
                FeedCellViewModel(isLoading: false, canRety: false, location: model.location, description: model.description, image: image)
            )
        } else {
            feedCellView?.display(
                FeedCellViewModel(isLoading: false, canRety: true, location: model.location, description: model.description, image: nil)
            )
        }
    }
}
