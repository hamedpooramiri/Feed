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
    
    func test_retrieve_noCachesItems_returnEmpty() {
        let sut = makeSUT()
        expect(sut, toCompleteRetrieveWith: .empty)
    }
    
    func test_retrieve_returnItemsSuccessfuly() {
        let sut = makeSUT()
        let timeStamp = Date()
        let items = uniqueFeeds()
        let exp = expectation(description: "wait to retrieve items")
        sut.insert(feeds: items.localItems, timeStamp: timeStamp) { error in
            XCTAssertNil(error)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        expect(sut, toCompleteRetrieveWith: .found(items: items.localItems, timeStamp: timeStamp))
    }

    func test_retrieve_callTwice_hasNoSideEffect() {
        let sut = makeSUT()
        let timeStamp = Date()
        let items = uniqueFeeds()
        let exp = expectation(description: "wait to retrieve items")
        sut.insert(feeds: items.localItems, timeStamp: timeStamp) { error in
            XCTAssertNil(error)
            sut.retrieve { firstResult in
                sut.retrieve { secendResult in
                    switch (firstResult, secendResult) {
                    case let (.found(firstRetrivedItems, firstRetrievedTimeStamp), .found(secendRetrivedItems, secendRetrievedTimeStamp)):
                        XCTAssertEqual(firstRetrivedItems, secendRetrivedItems)
                        XCTAssertEqual(firstRetrievedTimeStamp, secendRetrievedTimeStamp)
                    default:
                        XCTFail("expected to get the same items but firstResult: \(firstResult) , and secendResult: \(secendResult)")
                    }
                    exp.fulfill()
                }
            }
        }
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: Helper
    
    func makeSUT() -> CodableFeedStore {
        CodableFeedStore(storeURL: storeURLForTest())
    }

    func expect(_ sut: CodableFeedStore, toCompleteRetrieveWith expectedResult: FeedStoreRetrieveResult, file: StaticString = #filePath, line: UInt = #line) {
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
    func setUpEmptyStoreState() {
        deleteStoreArtifacts()
    }

    func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }

    func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: storeURLForTest())
    }

    func storeURLForTest() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appending(path: "\(type(of: self)).store")
    }
}
