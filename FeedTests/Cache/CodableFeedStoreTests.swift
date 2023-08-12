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

    func test_retrieve_nonEmptyCache_returnData() {
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
   
    func test_retrieve_nonEmptyCache_returnError() {
        let sut = makeSUT()
        let timeStamp = Date()
        let items = uniqueFeeds()
        insert((items.localItems, timeStamp), to: sut)
            // TODO
        expect(sut, toCompleteRetrieveWith: .found(items: items.localItems, timeStamp: timeStamp))
    }

    func test_retrieve_nonEmptyCache_error_haseNoSideEffect() {
        let sut = makeSUT()
        let timeStamp = Date()
        let items = uniqueFeeds()
        // TODO
        insert((items.localItems, timeStamp), to: sut)
        expect(sut, toRetrieveTwice: .found(items: items.localItems, timeStamp: timeStamp))
    }

    // MARK: Helper
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: storeURLForTest())
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
            case let (.failure(recievedError), .failure(expectedError)):
                XCTAssertEqual(recievedError as NSError, expectedError as NSError)
            case (.empty, .empty):
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

    private func insert(_ cache: (items: [LocalFeedItem], timeStamp: Date), to sut: CodableFeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait to retrieve items")
        sut.insert(feeds: cache.items, timeStamp: cache.timeStamp) { error in
            XCTAssertNil(error, file: file, line: line)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
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
