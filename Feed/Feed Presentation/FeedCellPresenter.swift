//
//  FeedCellPresenter.swift
//  FeediOS
//
//  Created by hamedpouramiri on 8/20/23.
//

import Foundation

public protocol FeedCellView {
    associatedtype Image
    func display(_ viewModel: FeedCellViewModel<Image>)
}

public protocol FeedCellPresenterInput {
    func didStartLoadingImage(for model: FeedItem)
    func didFinishedLoadingImage(for model: FeedItem, with error: Error)
    func didFinishedLoadingImage(for model: FeedItem, with imageData: Data)
}

public final class FeedCellPresenter<View: FeedCellView, Image> where View.Image == Image {

    private let imageTransformer: (Data) -> Image?
    private let feedCellView: View

    public init(feedCellView: View, imageTransformer: @escaping (Data) -> Image?) {
        self.feedCellView = feedCellView
        self.imageTransformer = imageTransformer
    }

}

extension FeedCellPresenter: FeedCellPresenterInput {
    public func didStartLoadingImage(for model: Feed.FeedItem) {
        feedCellView.display(
            FeedCellViewModel(isLoading: true, canRety: false, location: model.location, description: model.description, image: nil)
        )
    }
    
    public func didFinishedLoadingImage(for model: Feed.FeedItem, with error: Error) {
        feedCellView.display(
            FeedCellViewModel(isLoading: false, canRety: true, location: model.location, description: model.description, image: nil)
        )
    }
    
    public func didFinishedLoadingImage(for model: Feed.FeedItem, with imageData: Data) {
        if let image = imageTransformer(imageData){
            feedCellView.display(
                FeedCellViewModel(isLoading: false, canRety: false, location: model.location, description: model.description, image: image)
            )
        } else {
            feedCellView.display(
                FeedCellViewModel(isLoading: false, canRety: true, location: model.location, description: model.description, image: nil)
            )
        }
    }
}
