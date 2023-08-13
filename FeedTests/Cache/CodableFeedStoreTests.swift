//
//  CodableFeedStoreTests.swift
//  FeedTests
//
//  Created by hamedpouramiri on 8/12/23.
//

import XCTest
import Feed

final class CodableFeedStoreTests: XCTestCase, FailableFeedStoreSpec {

    override func setUp() {
        super.setUp()
        setUpEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    func test_retrieve_emptyCache_deliverEmpty() {
        let sut = makeSUT()
        expect(sut, toCompleteRetrieveWith: .empty)
    }
    
    func test_retrieve_emptyCache_hasNoSideEffectRetrieveTwice() {
        let sut = makeSUT()
        expect(sut, toRetrieveTwice: .empty)
    }

    func test_retrieve_nonEmptyCache_deliverData() {
        let sut = makeSUT()
        let timeStamp = Date()
        let items = uniqueFeeds()
        insert((items.localItems, timeStamp), to: sut)
        expect(sut, toCompleteRetrieveWith: .found(items: items.localItems, timeStamp: timeStamp))
    }

    func test_retrieve_nonEmptyCache_hasNoSideEffectOnRetrieveTwice() {
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

    func test_retrieve_nonEmptyCache_haseNoSideEffectOnRetrieveTwiceOnError() {
        let storeURL = storeURLForTest()
        let sut = makeSUT(storeURL: storeURL)
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }

    func test_insert_toEmptyCache_insertData() {
        let sut = makeSUT()
        let items = uniqueFeeds()
        let timeStamp = Date()
        insert((items: items.localItems, timeStamp: timeStamp), to: sut)
        expect(sut, toCompleteRetrieveWith: .found(items: items.localItems, timeStamp: timeStamp))
    }

    func test_insert_toNonEmptyCache_overridePreviousData() {
        let sut = makeSUT()
        insert((items: uniqueFeeds().localItems, timeStamp: Date()), to: sut)
        
        let items = uniqueFeeds()
        let timeStamp = Date()
        insert((items: items.localItems, timeStamp: timeStamp), to: sut)

        expect(sut, toCompleteRetrieveWith: .found(items: items.localItems, timeStamp: timeStamp))
    }
    
    func test_insert_onInsertionErrorDeliverError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        let insertionError = insert((items: uniqueFeeds().localItems, timeStamp: Date()), to: sut)
        XCTAssertNotNil(insertionError, "expect to deliver Error")
    }

    func test_insert_hasNoSideEffectOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        insert((items: uniqueFeeds().localItems, timeStamp: Date()), to: sut)
        expect(sut, toCompleteRetrieveWith: .empty)
    }

    func test_delete_emptyCache_doNoting() {
        let sut = makeSUT()
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "expect to have no Deletion error")
    }

    func test_delete_emptyCache_hasNoSideEffectOnCache() {
        let sut = makeSUT()
        deleteCache(from: sut)
        expect(sut, toCompleteRetrieveWith: .empty)
    }

    func test_delete_nonEmptyCache_leaveCacheEmpty() {
        let sut = makeSUT()
        insert((items: uniqueFeeds().localItems, timeStamp: Date()), to: sut)
        deleteCache(from: sut)
        expect(sut, toCompleteRetrieveWith: .empty)
    }

    func test_delete_onDeletionErrorDeliverError() {
        let noDeletePermissionURL = cacheDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)

        let deletionError = deleteCache(from: sut)
        XCTAssertNotNil(deletionError, "expect to have an error")
    }

    func test_delete_hasNoSideEffectOnDeletionError() {
        let noDeletePermissionURL = cacheDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)

        deleteCache(from: sut)
        expect(sut, toCompleteRetrieveWith: .empty)
    }

    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
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
        XCTAssertEqual(capturedOperationsInOrder, [op1, op2, op3])
    }

    // MARK: Helper
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? storeURLForTest())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
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
