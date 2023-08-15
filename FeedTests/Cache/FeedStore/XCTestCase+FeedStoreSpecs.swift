//
//  XCTestCase+FeedStoreSpecs.swift
//  FeedTests
//
//  Created by hamedpouramiri on 8/13/23.
//

import XCTest
import Feed

extension FeedStoreSpecs where Self: XCTestCase {
    
    func assetThatRetrieveFromEmptyCacheDeliverEmpty(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toCompleteRetrieveWith: .success(nil), file: file, line: line)
    }
    
    func assetThatRetrieveFromEmptyCacheHasNoSideEffectRetrieveTwice(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .success(nil), file: file, line: line)
    }

    func assertThatRetrieveFromNonEmptyCacheDeliverData(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let timeStamp = Date()
        let items = uniqueFeeds()
        insert((items.localItems, timeStamp), to: sut, file: file, line: line)
        expect(sut, toCompleteRetrieveWith: .success((items: items.localItems, timeStamp: timeStamp)), file: file, line: line)
    }

    func assertThatRetrieveFromNonEmptyCacheHasNoSideEffectOnRetrieveTwice(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let timeStamp = Date()
        let items = uniqueFeeds()
        insert((items.localItems, timeStamp), to: sut, file: file, line: line)
        expect(sut, toRetrieveTwice: .success((items: items.localItems, timeStamp: timeStamp)), file: file, line: line)
    }

    func assertThatRetrieveFromNonEmptyCacheOnErrorDeliverError(on sut: FeedStore, storeURL: URL, file: StaticString = #filePath, line: UInt = #line) {
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        expect(sut, toCompleteRetrieveWith: .failure(anyNSError()), file: file, line: line)
    }

    func assertThatRetrieveNonEmptyCacheHaseNoSideEffectOnRetrieveTwiceOnError(on sut: FeedStore, storeURL: URL, file: StaticString = #filePath, line: UInt = #line) {
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        expect(sut, toRetrieveTwice: .failure(anyNSError()), file: file, line: line)
    }

    func assertThatInsertToEmptyCacheInsertData(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let items = uniqueFeeds()
        let timeStamp = Date()
        insert((items: items.localItems, timeStamp: timeStamp), to: sut, file: file, line: line)
        expect(sut, toCompleteRetrieveWith: .success((items: items.localItems, timeStamp: timeStamp)), file: file, line: line)
    }
    
    func assertThatInsertToNonEmptyCacheOverridePreviousData(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert((items: uniqueFeeds().localItems, timeStamp: Date()), to: sut, file: file, line: line)
        
        let items = uniqueFeeds()
        let timeStamp = Date()
        insert((items: items.localItems, timeStamp: timeStamp), to: sut, file: file, line: line)

        expect(sut, toCompleteRetrieveWith: .success((items: items.localItems, timeStamp: timeStamp)), file: file, line: line)
    }

    func assertThatInsertOnInsertionErrorDeliverError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let insertionError = insert((items: uniqueFeeds().localItems, timeStamp: Date()), to: sut, file: file, line: line)
        XCTAssertNotNil(insertionError, "expect to deliver Error", file: file, line: line)
    }

    func assertThatInsertHasNoSideEffectOnInsertionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert((items: uniqueFeeds().localItems, timeStamp: Date()), to: sut, file: file, line: line)
        expect(sut, toCompleteRetrieveWith: .success(nil), file: file, line: line)
    }

    func assertThatDeleteEmptyCacheDoNoting(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "expect to have no Deletion error", file: file, line: line)
    }

    func assertThatDeleteEmptyCacheHasNoSideEffectOnCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        deleteCache(from: sut)
        expect(sut, toCompleteRetrieveWith: .success(nil), file: file, line: line)
    }

    func assertThatDeleteNonEmptyCacheLeaveCacheEmpty(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert((items: uniqueFeeds().localItems, timeStamp: Date()), to: sut, file: file, line: line)
        deleteCache(from: sut)
        expect(sut, toCompleteRetrieveWith: .success(nil), file: file, line: line)
    }

    func assertThatDeleteOnDeletionErrorDeliverError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let deletionError = deleteCache(from: sut)
        XCTAssertNotNil(deletionError, "expect to have an error", file: file, line: line)
    }

    func assertThatDeleteHasNoSideEffectOnDeletionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        deleteCache(from: sut)
        expect(sut, toCompleteRetrieveWith: .success(nil), file: file, line: line)
    }

    func assertThatStoreHasNoSideEffectWhenRunSerially(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        var capturedOperationsInOrder = [XCTestExpectation]()

        let op1 = expectation(description: "op1")
        sut.insert(feeds: uniqueFeeds().localItems, timeStamp: Date()) { _ in
            capturedOperationsInOrder.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "op2")
        sut.insert(feeds: uniqueFeeds().localItems, timeStamp: Date()) { _ in
            capturedOperationsInOrder.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "op3")
        sut.insert(feeds: uniqueFeeds().localItems, timeStamp: Date()) { _ in
            capturedOperationsInOrder.append(op3)
            op3.fulfill()
        }
        waitForExpectations(timeout: 7)
        XCTAssertEqual(capturedOperationsInOrder, [op1, op2, op3], file: file, line: line)
    }

    func expect(_ sut: FeedStore, toCompleteRetrieveWith expectedResult: FeedStore.RetrieveResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for retrieve")
        sut.retrieve { receivedresult in
            switch (receivedresult, expectedResult) {
            case let (.success(.some((receivedItems, receivedTimeStamp))), .success(.some((expectedItems, expectedTimeStamp)))):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                XCTAssertEqual(receivedTimeStamp, expectedTimeStamp, file: file, line: line)
                //            case let (.failure(recievedError), .failure(expectedError)):
                //                XCTAssertEqual(recievedError as NSError, expectedError as NSError, file: file, line: line)
            case (.success, .success), (.failure, .failure):
                break
            default:
                XCTFail("expected to get \(expectedResult) but got \(receivedresult)", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: FeedStore.RetrieveResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toCompleteRetrieveWith: expectedResult, file: file, line: line)
        expect(sut, toCompleteRetrieveWith: expectedResult, file: file, line: line)
    }
    
    @discardableResult
    func insert(_ cache: (items: [LocalFeedItem], timeStamp: Date), to sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let exp = expectation(description: "wait to retrieve items")
        var capturedError: Error?
        sut.insert(feeds: cache.items, timeStamp: cache.timeStamp) { result in
            switch result {
            case .failure(let error):
                capturedError = error
            default:
                break
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        return capturedError
    }
    
    @discardableResult
    func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "wating for deletion")
        var deletionError: Error?
        sut.deleteFeeds { result in
            switch result {
            case .failure(let error):
                deletionError = error
            default:
                break
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        return deletionError
    }
    
}
