//
//  FeedImageCacher.swift
//  Feed
//
//  Created by hamedpouramiri on 8/24/23.
//

import Foundation

public protocol FeedImageCacher {
    typealias Result = Swift.Result<Void, Error>
    func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
