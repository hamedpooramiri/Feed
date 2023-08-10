//
//  LocalFeedLoaderTests.swift
//  FeedTests
//
//  Created by hamedpouramiri on 8/10/23.
//

import XCTest
import Feed


protocol FeedStoreProtocol {
    typealias DeleteCompletion = (Error?) -> Void
    typealias InsertCompletion = (Error?) -> Void
    func deleteFeeds(compeletion: @escaping DeleteCompletion)
    func insert(feeds: [FeedItem], timeStamp: Date, completion: @escaping InsertCompletion)
}

class LocalFeedLoader {

    private var store: FeedStoreProtocol
    private var currentDate: () -> Date

    init(store: FeedStoreProtocol, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(items: [FeedItem], compeletion: @escaping (Error?) -> Void){
        store.deleteFeeds { [unowned self] error in
            if error == nil {
                self.store.insert(feeds: items, timeStamp: self.currentDate(), completion: compeletion)
            } else {
                compeletion(error)
            }
        }
    }
}


final class LocalFeedLoaderTests: XCTestCase {

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
        expect(sut, completeWithError: expectedError) {
            store.completeDelete(with: expectedError)
        }
        XCTAssertEqual(store.receivedMessages, [.deleteFeeds])
    }
    
    func test_save_cacheInsertionError() {
        let (store, sut) = makeSUT()
        let expectedError = anyNSError()
        expect(sut, completeWithError: expectedError) {
            store.completeDeleteSuccessfully()
            store.completeInsertion(with: expectedError)
        }
    }

    func test_save_requestInsertionWithTimestampOnDeletionSuccessfully() {

        let currentData = Date()
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        let (store, sut) = makeSUT() { currentData }

        let exp = expectation(description: "wait for save")
        var capturedError: Error?
        sut.save(items: items) { error in
           capturedError = error
            exp.fulfill()
        }
        store.completeDeleteSuccessfully()
        store.completeInsertionSuccessfully()
        wait(for: [exp])
        
        XCTAssertEqual(store.receivedMessages, [.deleteFeeds, .insertFeeds(items: items, timeStamp: currentData)])
        XCTAssertNil(capturedError)
    }

    //MARK: - Helpers

    func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (store: FeedStoreSpy, sut: LocalFeedLoader){
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (store, sut)
    }

    func expect(_ sut: LocalFeedLoader, completeWithError expectedError: NSError?, when action: @escaping ()-> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for save")
        var capturedError: Error?
        sut.save(items: [uniqueFeedItem(), uniqueFeedItem()]) { error in
           capturedError = error
            exp.fulfill()
        }
        action()
        wait(for: [exp])
        XCTAssertEqual(capturedError as? NSError, expectedError, file: file, line: line)
    }

    func uniqueFeedItem() -> FeedItem {
        FeedItem(id: UUID(), description: "any description", location: "any location", imageUrl: anyURL())
    }
    
    func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }

    class FeedStoreSpy: FeedStoreProtocol {
        
        enum ReceivedMessage: Equatable {
            case deleteFeeds
            case insertFeeds(items: [FeedItem], timeStamp: Date)
        }
        
        var receivedMessages: [ReceivedMessage] = []
        
        private var capturedDeleteCompletions: [DeleteCompletion] = []
        private var capturedInsertionCompletions: [InsertCompletion] = []
        
        
        func deleteFeeds(compeletion: @escaping DeleteCompletion) {
            receivedMessages.append(.deleteFeeds)
            capturedDeleteCompletions.append(compeletion)
        }
        
        func insert(feeds: [FeedItem], timeStamp: Date, completion: @escaping InsertCompletion) {
            capturedInsertionCompletions.append(completion)
            receivedMessages.append(.insertFeeds(items: feeds, timeStamp: timeStamp))
        }
        
        func completeDelete(with error: Error, at index: Int = 0) {
            capturedDeleteCompletions[index](error)
        }
        
        func completeDeleteSuccessfully(at index: Int = 0) {
            capturedDeleteCompletions[index](nil)
        }
        
        func completeInsertion(with error: Error, at index: Int = 0) {
            capturedInsertionCompletions[index](error)
        }
        
        func completeInsertionSuccessfully(at index: Int = 0) {
            capturedInsertionCompletions[index](nil)
        }
    }
}
