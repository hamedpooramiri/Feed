//
//  LoadFeedFromCacheUseCase.swift
//  FeedTests
//
//  Created by hamedpouramiri on 8/11/23.
//

import XCTest
import Feed

final class LoadFeedFromCacheUseCase: XCTestCase {

    func test_init_notLoadFeedOnCreation() {
        let store = FeedStoreSpy()
        let currentDate = Date()
        let _ = LocalFeedLoader(store: store) { currentDate }
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_cacheRetrieveError() {
        let (store, sut) = makeSUT()
        let expectedError = anyNSError()
        expect(sut, toCompleteWithResult: .failure(expectedError)) {
            store.completeRetrieve(with: expectedError)
        }
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_emptyCache_DeliversNoFeedItem() {
        let (store, sut) = makeSUT()
        expect(sut, toCompleteWithResult: .success([])) {
            store.completeRetrieveWithEmptyCache()
        }
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_lessThanSevenDaysOldCache_DeliversFeedItem() {
        let currentDate = Date()
        let lessThanSevenDaysTimeStamp = currentDate.add(by: -7).add(by: 1)
        let items = uniqueFeeds()
        let (store, sut) = makeSUT { currentDate }
        expect(sut, toCompleteWithResult: .success(items.models)) {
            store.completeRetrieve(with: items.localItems, timeStamp: lessThanSevenDaysTimeStamp )
        }
    }

    func test_load_sevenDaysOldCache_DeliversNoItem() {
        let currentDate = Date()
        let sevenDaysTimeStamp = currentDate.add(by: -7)
        let items = uniqueFeeds()
        let (store, sut) = makeSUT { currentDate }
        expect(sut, toCompleteWithResult: .success([])) {
            store.completeRetrieve(with: items.localItems, timeStamp: sevenDaysTimeStamp )
        }
    }
    
    func test_load_eightDaysOldCache_DeliversNoItem() {
        let currentDate = Date()
        let sevenDaysTimeStamp = currentDate.add(by: -8)
        let items = uniqueFeeds()
        let (store, sut) = makeSUT { currentDate }
        expect(sut, toCompleteWithResult: .success([])) {
            store.completeRetrieve(with: items.localItems, timeStamp: sevenDaysTimeStamp )
        }
    }

    // MARK: Helper
    
    func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (store: FeedStoreSpy, sut: LocalFeedLoader){
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (store, sut)
    }

    func expect(_ sut: LocalFeedLoader, toCompleteWithResult expectedResult: LoadFeedResult, when action: @escaping ()-> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for save")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("expect to get result \(expectedResult) but got \(receivedResult)", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp])
    }

    func uniqueFeedItem() -> FeedItem {
        FeedItem(id: UUID(), description: "any description", location: "any location", imageUrl: anyURL())
    }
    
    func uniqueFeeds() -> (models: [FeedItem], localItems: [LocalFeedItem]) {
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        return (items, items.map {
            LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageUrl: $0.imageUrl)
        })
    }

    func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }

    func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
}

private extension Date {
    func add(by days: Int) -> Date {
        Calendar(identifier: .gregorian ).date(byAdding: .day, value: days, to: self)!
    }
    func add(by secends: TimeInterval) -> Date {
        self + secends
    }
}
