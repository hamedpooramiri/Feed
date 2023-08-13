//
//  XCTestCase+FeedStoreSpecs.swift
//  FeedTests
//
//  Created by hamedpouramiri on 8/13/23.
//

import XCTest
import Feed

extension FeedStoreSpecs where Self: XCTestCase {
    
    func assetThatRetrieveFromEmptyCacheDeliverEmpty(on sut: FeedStore) {
        expect(sut, toCompleteRetrieveWith: .empty)
    }
    
    func assetThatRetrieveFromEmptyCacheHasNoSideEffectRetrieveTwice(on sut: FeedStore) {
        expect(sut, toRetrieveTwice: .empty)
    }

    func assertThatRetrieveFromNonEmptyCacheDeliverData(on sut: FeedStore) {
        let timeStamp = Date()
        let items = uniqueFeeds()
        insert((items.localItems, timeStamp), to: sut)
        expect(sut, toCompleteRetrieveWith: .found(items: items.localItems, timeStamp: timeStamp))
    }

    func assertThatRetrieveFromNonEmptyCacheHasNoSideEffectOnRetrieveTwice(on sut: FeedStore) {
        let timeStamp = Date()
        let items = uniqueFeeds()
        insert((items.localItems, timeStamp), to: sut)
        expect(sut, toRetrieveTwice: .found(items: items.localItems, timeStamp: timeStamp))
    }

    func assertThatRetrieveFromNonEmptyCacheOnErrorDeliverError(on sut: FeedStore, storeURL: URL) {
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        expect(sut, toCompleteRetrieveWith: .failure(anyNSError()))
    }

    func assertThatRetrieveNonEmptyCacheHaseNoSideEffectOnRetrieveTwiceOnError(on sut: FeedStore, storeURL: URL) {
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }

    func assertThatInsertToEmptyCacheInsertData(on sut: FeedStore) {
        let items = uniqueFeeds()
        let timeStamp = Date()
        insert((items: items.localItems, timeStamp: timeStamp), to: sut)
        expect(sut, toCompleteRetrieveWith: .found(items: items.localItems, timeStamp: timeStamp))
    }
    
    func assertThatInsertToNonEmptyCacheOverridePreviousData(on sut: FeedStore) {
        insert((items: uniqueFeeds().localItems, timeStamp: Date()), to: sut)
        
        let items = uniqueFeeds()
        let timeStamp = Date()
        insert((items: items.localItems, timeStamp: timeStamp), to: sut)

        expect(sut, toCompleteRetrieveWith: .found(items: items.localItems, timeStamp: timeStamp))
    }

    func assertThatInsertOnInsertionErrorDeliverError(on sut: FeedStore) {
        let insertionError = insert((items: uniqueFeeds().localItems, timeStamp: Date()), to: sut)
        XCTAssertNotNil(insertionError, "expect to deliver Error")
    }

    func assertThatInsertHasNoSideEffectOnInsertionError(on sut: FeedStore) {
        insert((items: uniqueFeeds().localItems, timeStamp: Date()), to: sut)
        expect(sut, toCompleteRetrieveWith: .empty)
    }

    func assertThatDeleteEmptyCacheDoNoting(on sut: FeedStore) {
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "expect to have no Deletion error")
    }

    func assertThatDeleteEmptyCacheHasNoSideEffectOnCache(on sut: FeedStore) {
        deleteCache(from: sut)
        expect(sut, toCompleteRetrieveWith: .empty)
    }

    func assertThatDeleteNonEmptyCacheLeaveCacheEmpty(on sut: FeedStore) {
        insert((items: uniqueFeeds().localItems, timeStamp: Date()), to: sut)
        deleteCache(from: sut)
        expect(sut, toCompleteRetrieveWith: .empty)
    }

    func assertThatDeleteOnDeletionErrorDeliverError(on sut: FeedStore) {
        let deletionError = deleteCache(from: sut)
        XCTAssertNotNil(deletionError, "expect to have an error")
    }

    func assertThatDeleteHasNoSideEffectOnDeletionError(on sut: FeedStore) {
        deleteCache(from: sut)
        expect(sut, toCompleteRetrieveWith: .empty)
    }

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
