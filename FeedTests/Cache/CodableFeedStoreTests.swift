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

    private func expect(_ sut: FeedStore, toCompleteRetrieveWith expectedResult: FeedStoreRetrieveResult, file: StaticString = #filePath, line: UInt = #line) {
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

    private func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: FeedStoreRetrieveResult, file: StaticString = #filePath, line: UInt = #line) {
       expect(sut, toCompleteRetrieveWith: expectedResult, file: file, line: line)
       expect(sut, toCompleteRetrieveWith: expectedResult, file: file, line: line)
    }

    @discardableResult
    private func insert(_ cache: (items: [LocalFeedItem], timeStamp: Date), to sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
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
    private func deleteCache(from sut: FeedStore) -> Error? {
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
