//
//  SaveFeedToCacheUseCaseTests.swift
//  FeedTests
//
//  Created by hamedpouramiri on 8/10/23.
//

import XCTest
import Feed

final class SaveFeedToCacheUseCaseTests: XCTestCase {

    func test_notDeleteTheCacheOnCreation() {
        let (store, _) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_save_deletePreviousCachesItems() {
        let (store, sut) = makeSUT()
        sut.save(items: [uniqueFeedItem(), uniqueFeedItem()]) { _ in }
        XCTAssertEqual(store.receivedMessages, [.deleteFeeds])
    }

    func test_save_doesNotRequestCacheInsertionOnDeleteError() {
        let (store, sut) = makeSUT()
        let expectedError = anyNSError()
        expect(sut, withItems: [uniqueFeedItem()], toCompleteWithError: expectedError) {
            store.completeDelete(with: expectedError)
        }
        XCTAssertEqual(store.receivedMessages, [.deleteFeeds])
    }
    
    func test_save_cacheInsertionError() {
        let (store, sut) = makeSUT()
        let expectedError = anyNSError()
        expect(sut, withItems: [uniqueFeedItem()], toCompleteWithError: expectedError) {
            store.completeDeleteSuccessfully()
            store.completeInsertion(with: expectedError)
        }
    }

    func test_save_requestInsertionWithTimestampOnDeletionSuccessfully() {
        let currentData = Date()
        let items = uniqueFeeds()
        let (store, sut) = makeSUT() { currentData }

        expect(sut, withItems: items.models, toCompleteWithError: nil) {
            store.completeDeleteSuccessfully()
            store.completeInsertionSuccessfully()
        }
        XCTAssertEqual(store.receivedMessages, [.deleteFeeds, .insertFeeds(items: items.localItems, timeStamp: currentData)])
    }

    func test_save_afterDeallocatingSUTNotDeliverDeletionError() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var capturedResults = [LocalFeedLoader.SaveResult]()
        sut?.save(items: [uniqueFeedItem()]) { capturedResults.append($0) }
        sut = nil
        store.completeDelete(with: anyNSError())
        XCTAssertTrue(capturedResults.isEmpty)
    }

    func test_save_afterDeallocatingSUTNotDeliverInsertionError() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var capturedResults = [LocalFeedLoader.SaveResult]()
        sut?.save(items: [uniqueFeedItem()]) { capturedResults.append($0) }
        store.completeDeleteSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        XCTAssertTrue(capturedResults.isEmpty)
    }

    //MARK: - Helpers

    func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (store: FeedStoreSpy, sut: LocalFeedLoader){
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (store, sut)
    }

    func expect(_ sut: LocalFeedLoader, withItems items: [FeedItem], toCompleteWithError expectedError: NSError?, when action: @escaping ()-> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for save")
        var capturedError: Error?
        sut.save(items: items) { result in
            switch result {
            case .failure(let error):
                capturedError = error
            default:
                break
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp])
        XCTAssertEqual(capturedError as? NSError, expectedError, file: file, line: line)
    }

}
