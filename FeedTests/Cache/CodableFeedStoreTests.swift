//
//  CodableFeedStoreTests.swift
//  FeedTests
//
//  Created by hamedpouramiri on 8/12/23.
//

import XCTest
import Feed

final class CodableFeedStoreTests: XCTestCase {

    override func setUp() {
        super.setUp()
        setUpEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    func test_retrieve_emptyCache_returnEmpty() {
        let sut = makeSUT()
        expect(sut, toCompleteRetrieveWith: .empty)
    }
    
    func test_retrieve_emptyCache_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieveTwice: .empty)
    }

    func test_retrieve_afterInsertingToNonEmptyCache_returnData() {
        let sut = makeSUT()
        let timeStamp = Date()
        let items = uniqueFeeds()
        insert((items.localItems, timeStamp), to: sut)
        expect(sut, toCompleteRetrieveWith: .found(items: items.localItems, timeStamp: timeStamp))
    }

    func test_retrieve_nonEmptyCache_hasNoSideEffectOnCache() {
        let sut = makeSUT()
        let timeStamp = Date()
        let items = uniqueFeeds()
        insert((items.localItems, timeStamp), to: sut)
        expect(sut, toRetrieveTwice: .found(items: items.localItems, timeStamp: timeStamp))
    }
   
    func test_retrieve_nonEmptyCache_onErrorDeliverError() {
        let storeURL = storeURLForTest()
        let sut = makeSUT(storeURL: storeURL)
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        expect(sut, toCompleteRetrieveWith: .failure(anyNSError()))
    }

    func test_retrieve_nonEmptyCache_error_haseNoSideEffect() {
        let storeURL = storeURLForTest()
        let sut = makeSUT(storeURL: storeURL)
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }

    func test_insert_toEmptyCache_insertData() {
        let sut = makeSUT()
        let items = uniqueFeeds()
        let timeStamp = Date()
        let insertionError = insert((items: items.localItems, timeStamp: timeStamp), to: sut)
        XCTAssertNil(insertionError, "expect to insert data Succesfully")
        
        expect(sut, toCompleteRetrieveWith: .found(items: items.localItems, timeStamp: timeStamp))
    }

    func test_insert_toNonEmptyCache_overridePreviousData() {
        let sut = makeSUT()
        let firstInsertionError = insert((items: uniqueFeeds().localItems, timeStamp: Date()), to: sut)
        XCTAssertNil(firstInsertionError, "expect to insert data Succesfully")
        
        let items = uniqueFeeds()
        let timeStamp = Date()
        let lastInsertionError = insert((items: items.localItems, timeStamp: timeStamp), to: sut)
        XCTAssertNil(lastInsertionError, "expect to override data Succesfully")
        
        expect(sut, toCompleteRetrieveWith: .found(items: items.localItems, timeStamp: timeStamp))
    }
    
    func test_insert_onInsertionErrorDeliverError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        let insertionError = insert((items: uniqueFeeds().localItems, timeStamp: Date()), to: sut)
        XCTAssertNotNil(insertionError, "expect to deliver Error")
    }

    func test_delete_emptyCache_doNoting() {
        let sut = makeSUT()
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "expect to have no Deletion error")
        expect(sut, toCompleteRetrieveWith: .empty)
    }

    func test_delete_nonEmptyCache_leaveCacheEmpty() {
        let sut = makeSUT()
        
        let insertionError = insert((items: uniqueFeeds().localItems, timeStamp: Date()), to: sut)
        XCTAssertNil(insertionError, "expect to insert data Succesfully")

        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "expect to have no Deletion error")
        
        expect(sut, toCompleteRetrieveWith: .empty)
    }

    func test_delete_nonEmptyCache_onDeletionErrorDeliverError() {
        let noDeletePermissionURL = cacheDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)

        let deletionError = deleteCache(from: sut)
        XCTAssertNotNil(deletionError, "expect to have an error")
    }

    // MARK: Helper
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? storeURLForTest())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func expect(_ sut: CodableFeedStore, toCompleteRetrieveWith expectedResult: FeedStoreRetrieveResult, file: StaticString = #filePath, line: UInt = #line) {
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

    private func expect(_ sut: CodableFeedStore, toRetrieveTwice expectedResult: FeedStoreRetrieveResult, file: StaticString = #filePath, line: UInt = #line) {
       expect(sut, toCompleteRetrieveWith: expectedResult, file: file, line: line)
       expect(sut, toCompleteRetrieveWith: expectedResult, file: file, line: line)
    }

    @discardableResult
    private func insert(_ cache: (items: [LocalFeedItem], timeStamp: Date), to sut: CodableFeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let exp = expectation(description: "wait to retrieve items")
        var capturedError: Error?
        sut.insert(feeds: cache.items, timeStamp: cache.timeStamp) { error in
            capturedError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        return capturedError
    }

    private func deleteCache(from sut:CodableFeedStore) -> Error? {
        let exp = expectation(description: "wating for deletion")
        var deletionError: Error?
        sut.deleteFeeds { error in
            deletionError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        return deletionError
    }

    private func cacheDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!
    }

    private func setUpEmptyStoreState() {
        deleteStoreArtifacts()
    }

    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }

    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: storeURLForTest())
    }

    private func storeURLForTest() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appending(path: "\(type(of: self)).store")
    }

}
