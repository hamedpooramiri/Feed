//
//  FeedImageStore.swift
//  Feed
//
//  Created by hamedpouramiri on 8/23/23.
//

import Foundation

public protocol FeedImageStore {
    typealias RetrieveResult = Swift.Result<Data?, Error>
    typealias InsertResult = Swift.Result<Void, Error>

    func insert(_ data: Data, for url: URL, completion: @escaping (InsertResult) -> Void)
    func retrieve(dataForURL url: URL, completion: @escaping (RetrieveResult) -> Void)
}
