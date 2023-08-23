//
//  SaveImageToCacheUseCaseTests.swift
//  FeedTests
//
//  Created by hamedpouramiri on 8/23/23.
//

import XCTest
import Feed

final class SaveImageToCacheUseCaseTests: XCTestCase {

    func test() {

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

}
