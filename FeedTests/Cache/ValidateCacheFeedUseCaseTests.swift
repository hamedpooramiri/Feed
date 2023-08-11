//
//  ValidateCacheFeedUseCaseTests.swift
//  FeedTests
//
//  Created by hamedpouramiri on 8/11/23.
//

import XCTest
import Feed

final class ValidateCacheFeedUseCaseTests: XCTestCase {

    func test_init_notMessageStoreOnCreation() {
        let store = FeedStoreSpy()
        let currentDate = Date()
        let _ = LocalFeedLoader(store: store) { currentDate }
        XCTAssertEqual(store.receivedMessages, [])
    }
 
    func test_validateCache_cacheRetrieveError_deleteCache() {
        let (store, sut) = makeSUT()
        sut.validateCache()
        store.completeRetrieve(with: anyNSError())
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteFeeds])
    }
    
    func test_validateCache_emptyCache_NotdeleteCache() {
        let (store, sut) = makeSUT()
        sut.validateCache()
        store.completeRetrieveWithEmptyCache()
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_validateCache_sevenDaysOldCache_deleteCache() {
        let currentDate = Date()
        let sevenDaysTimeStamp = currentDate.add(by: -7)
        let items = uniqueFeeds()
        let (store, sut) = makeSUT { currentDate }
        sut.validateCache()
        store.completeRetrieve(with: items.localItems, timeStamp: sevenDaysTimeStamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteFeeds])
    }

    func test_validateCache_moreThanSevenDaysOldCache_deleteCache() {
        let currentDate = Date()
        let moreThanSevenDaysTimeStamp = currentDate.add(by: -7).add(by: -1)
        let items = uniqueFeeds()
        let (store, sut) = makeSUT { currentDate }
        sut.validateCache()
        store.completeRetrieve(with: items.localItems, timeStamp: moreThanSevenDaysTimeStamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteFeeds])
    }

    func test_validateCache_afterSUTHasBeenDeallocated_notDeleteCache() {
        let items = uniqueFeeds()
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        sut?.validateCache()
        sut = nil
        store.completeRetrieve(with: anyNSError())
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }


    // MARK: - Helper
    
    func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (store: FeedStoreSpy, sut: LocalFeedLoader){
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (store, sut)
    }
}
