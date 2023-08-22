//
//  FeedImageLoader.swift
//  FeediOS
//
//  Created by hamedpouramiri on 8/18/23.
//

import Foundation

public protocol ImageLoaderTask {
    func cancel()
}

public protocol FeedImageLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImage(with url: URL, completion:  @escaping (Result) -> Void) -> ImageLoaderTask
}
