//
//  XCTestCase+FeedStoreSpecs.swift
//  FeedTests
//
//  Created by hamedpouramiri on 8/13/23.
//

import XCTest
import Feed

extension FeedStoreSpecs where Self: XCTestCase {
    
    func expect(_ sut: FeedStore, toCompleteRetrieveWith expectedResult: FeedStoreRetrieveResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for retrieve")
        sut.retrieve { receivedresult in
            switch (receivedresult, expectedResult) {
            case let (.found(receivedItems, receivedTimeStamp), .found(expectedItems, expectedTimeStamp)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                XCTAssertEqual(receivedTimeStamp, expectedTimeStamp, file: file, line: line)
                //            case let (.failure(recievedError), .failure(expectedError)):
                //                XCTAssertEqual(recievedError as NSError, expectedError as NSError, file: file, line: line)
            case (.empty, .empty), (.failure, .failure):
                break
            default:
                XCTFail("expected to get \(expectedResult) but got \(receivedresult)", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: FeedStoreRetrieveResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toCompleteRetrieveWith: expectedResult, file: file, line: line)
        expect(sut, toCompleteRetrieveWith: expectedResult, file: file, line: line)
    }
    
    @discardableResult
    func insert(_ cache: (items: [LocalFeedItem], timeStamp: Date), to sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let exp = expectation(description: "wait to retrieve items")
        var capturedError: Error?
        sut.insert(feeds: cache.items, timeStamp: cache.timeStamp) { error in
            capturedError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        return capturedError
    }
    
    @discardableResult
    func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "wating for deletion")
        var deletionError: Error?
        sut.deleteFeeds { error in
            deletionError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        return deletionError
    }
    
}
