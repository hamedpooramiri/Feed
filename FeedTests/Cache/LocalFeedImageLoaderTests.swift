//
//  LocalFeedImageLoaderTests.swift
//  FeedTests
//
//  Created by hamedpouramiri on 8/23/23.
//

import XCTest
import Feed

protocol FeedImageStore {
    typealias Result = Swift.Result<Data, Error>
    func retrieveImage(for url: URL, completion: @escaping (Result) -> Void)
}

class LocalFeedImageLoader {
    
    typealias Result = FeedImageLoader.Result
    
    let store: FeedImageStore
    
    init(store: FeedImageStore) {
        self.store = store
    }
    
    func loadImage(with url: URL, completion: @escaping (Result) -> Void) {
        store.retrieveImage(for: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}

final class LocalFeedImageLoaderTests: XCTestCase {

    func test_init_notLoadFeedImageOnCreation() {
        let (store, _) = makeSUT()
        XCTAssertEqual(store.requestedURLs, [])
    }

    func test_loadImage_cacheRetrieveError() {
        let (store, sut) = makeSUT()
        let expectedError = anyNSError()
        expect(sut, loadImageWith: anyURL(), toCompleteWithResult: .failure(expectedError)) {
            store.completeRetrieve(with: expectedError)
        }
    }

    func test_loadImage_performRetrieveOnce() {
        let (store, sut) = makeSUT()
        sut.loadImage(with: anyURL()) {_ in}
        XCTAssertEqual(store.requestedURLs.count, 1)
    }

    func test_loadImage_performRetrieveTwiceHasNoSideEffect() {
        let (store, sut) = makeSUT()
        sut.loadImage(with: anyURL()) {_ in}
        sut.loadImage(with: anyURL()) {_ in}
        XCTAssertEqual(store.requestedURLs.count, 2)
    }

    func test_loadImage_afterDeallocationOfSUT_notDeliverResult() {
        let store = LocalFeedImageLoaderStoreSpy()
        var sut: LocalFeedImageLoader? = LocalFeedImageLoader(store: store)
        var capturedResults: [FeedImageLoader.Result] = []
        sut?.loadImage(with: anyURL()) { capturedResults.append($0) }
        sut = nil
        store.completeRetrieve()
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (store: LocalFeedImageLoaderStoreSpy, sut: LocalFeedImageLoader) {
        let store = LocalFeedImageLoaderStoreSpy()
        let sut = LocalFeedImageLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (store, sut)
    }
    
    func expect(_ sut: LocalFeedImageLoader, loadImageWith url: URL, toCompleteWithResult expectedResult: LocalFeedImageLoader.Result, when action: @escaping ()-> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for save")
        sut.loadImage(with: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("expect to get result \(expectedResult) but got \(receivedResult)", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp])
    }

    private class LocalFeedImageLoaderStoreSpy: FeedImageStore {
        
        private(set) var capturedResults: [(url: URL, completion: (FeedImageStore.Result) -> Void)] = []
        var requestedURLs: [URL] {
            capturedResults.map(\.url)
        }
        
        func retrieveImage(for url: URL, completion: @escaping (FeedImageStore.Result) -> Void) {
            capturedResults.append((url, completion))
        }

        func completeRetrieve(with error: Error, at index: Int = 0) {
            capturedResults[index].completion(.failure(error))
        }
        
        func completeRetrieve(with imageData: Data = Data(), at index: Int = 0) {
            capturedResults[index].completion(.success(imageData))
        }
    }
}
