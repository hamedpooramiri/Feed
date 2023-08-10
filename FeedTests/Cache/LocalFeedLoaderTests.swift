//
//  LocalFeedLoaderTests.swift
//  FeedTests
//
//  Created by hamedpouramiri on 8/10/23.
//

import XCTest
import Feed

class FeedStore {
    var deleteCacheCount: Int = 0
    var savedSuccessCount: Int = 0
   
    func deleteCachedFeeds() {
        deleteCacheCount += 1
    }
}

class LocalFeedLoader {

    private var store: FeedStore
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(items: [FeedItem]){
        store.deleteCachedFeeds()
    }
}


final class LocalFeedLoaderTests: XCTestCase {

    func test_notDeleteTheCacheOnCreation() {
        let (store, _) = makeSUT()
        XCTAssertEqual(store.deleteCacheCount, 0)
    }

    func test_saveFeeds_deletePreviousCachesItems() {
        let (store, sut) = makeSUT()
        sut.save(items: [uniqueFeedItem(), uniqueFeedItem()])
        XCTAssertEqual(store.deleteCacheCount, 1)
    }

    func makeSUT() -> (store: FeedStore, sut: LocalFeedLoader){
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(store)
        return (store, sut)
    }
    
    //MARK: - Helpers
    func uniqueFeedItem() -> FeedItem {
        FeedItem(id: UUID(), description: "any description", location: "any location", imageUrl: anyURL())
    }
    
    func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
}
