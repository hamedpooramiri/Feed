//
//  FeedImageStore.swift
//  Feed
//
//  Created by hamedpouramiri on 8/23/23.
//

import Foundation

public protocol FeedImageStore {
    typealias Result = Swift.Result<Data, Error>
    func retrieveImage(for url: URL, completion: @escaping (Result) -> Void)
}
