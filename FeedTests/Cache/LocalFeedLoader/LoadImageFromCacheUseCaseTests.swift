//
//  LoadImageFromCacheUseCaseTests.swift
//  FeedTests
//
//  Created by hamedpouramiri on 8/23/23.
//

import XCTest
import Feed

final class LoadImageFromCacheUseCaseTests: XCTestCase {

    func test_init_notLoadFeedImageOnCreation() {
        let (store, _) = makeSUT()
        XCTAssertEqual(store.requestedURLs, [])
    }

    func test_loadImage_cacheRetrieveError() {
        let (store, sut) = makeSUT()
        let error = anyNSError()
        expect(sut, loadImageWith: anyURL(), toCompleteWithResult: .failure(LocalFeedImageLoader.LoadError.failed)) {
            store.completeRetrieve(with: error)
        }
    }

    func test_loadImage_performRetrieveOnce() {
        let (store, sut) = makeSUT()
        _ = sut.loadImage(with: anyURL()) {_ in}
        XCTAssertEqual(store.requestedURLs.count, 1)
    }

    func test_loadImage_performRetrieveTwiceHasNoSideEffect() {
        let (store, sut) = makeSUT()
        _ = sut.loadImage(with: anyURL()) {_ in}
        _ = sut.loadImage(with: anyURL()) {_ in}
        XCTAssertEqual(store.requestedURLs.count, 2)
    }

    func test_loadImage_afterDeallocationOfSUT_notDeliverResult() {
        let store = FeedImageStoreSpy()
        var sut: LocalFeedImageLoader? = LocalFeedImageLoader(store: store)
        var capturedResults: [FeedImageLoader.Result] = []
        _ = sut?.loadImage(with: anyURL()) { capturedResults.append($0) }
        sut = nil
        store.completeRetrieve()
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    func test_loadImage_cancelLoadNotDeliverResult() {
        let (store, sut) = makeSUT()
        
        var capturedResults: [FeedImageLoader.Result] = []
        let task = sut.loadImage(with: anyURL()) { capturedResults.append($0) }
        task.cancel()
        store.completeRetrieve()
        XCTAssertTrue(capturedResults.isEmpty)
        
    }
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (store: FeedImageStoreSpy, sut: LocalFeedImageLoader) {
        let store = FeedImageStoreSpy()
        let sut = LocalFeedImageLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (store, sut)
    }
    
    func expect(_ sut: LocalFeedImageLoader, loadImageWith url: URL, toCompleteWithResult expectedResult: LocalFeedImageLoader.LoadResult, when action: @escaping ()-> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for loadImage")
        _ = sut.loadImage(with: url) { receivedResult in
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
}
