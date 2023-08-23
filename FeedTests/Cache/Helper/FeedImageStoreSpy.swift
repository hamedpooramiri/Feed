//
//  FeedImageStoreSpy.swift
//  FeedTests
//
//  Created by hamedpouramiri on 8/23/23.
//

import Foundation
import Feed

class FeedImageStoreSpy: FeedImageStore {
    
    private(set) var capturedResults: [(url: URL, completion: (FeedImageStore.RetrieveResult) -> Void)] = []
    var requestedURLs: [URL] {
        capturedResults.map(\.url)
    }

    func retrieve(dataForURL url: URL, completion: @escaping (RetrieveResult) -> Void) {
        capturedResults.append((url, completion))
    }

    func insert(_ data: Data, for url: URL, completion: @escaping (InsertResult) -> Void) {

    }

    func completeRetrieve(with error: Error, at index: Int = 0) {
        capturedResults[index].completion(.failure(error))
    }
    
    func completeRetrieve(with imageData: Data = Data(), at index: Int = 0) {
        capturedResults[index].completion(.success(imageData))
    }
}
