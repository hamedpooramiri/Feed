//
//  CoreDataFeedStoreTests.swift
//  FeedTests
//
//  Created by hamedpouramiri on 8/14/23.
//

import XCTest
import Feed

class CoreDataFeedStore: FeedStore {
    
    let context: NSManagedObjectContext
    let container: NSPersistentContainer
    
    init(storeURL: URL, bundle: Bundle = .main) {

    }
    
    func deleteFeeds(completion: @escaping DeleteCompletion) {
    }
    
    func insert(feeds: [Feed.LocalFeedItem], timeStamp: Date, completion: @escaping InsertCompletion) {
        
    }
    
    func retrieve(completion: @escaping retrieveCompletion) {
        completion(.empty)
    }
}


final class CoreDataFeedStoreTests: XCTestCase, FailableFeedStoreSpec {
    
    func test_retrieve_emptyCache_deliverEmpty() {
        let sut = makeSUT()
        assetThatRetrieveFromEmptyCacheDeliverEmpty(on: sut)
    }
    
    func test_retrieve_emptyCache_hasNoSideEffectRetrieveTwice() {
        let sut = makeSUT()
        assetThatRetrieveFromEmptyCacheHasNoSideEffectRetrieveTwice(on: sut)
    }
    
    func test_retrieve_nonEmptyCache_deliverData() {
        let sut = makeSUT()
        assertThatRetrieveFromNonEmptyCacheDeliverData(on: sut)
    }
    
    func test_retrieve_nonEmptyCache_hasNoSideEffectOnRetrieveTwice() {
        let sut = makeSUT()
        assertThatRetrieveFromNonEmptyCacheHasNoSideEffectOnRetrieveTwice(on: sut)
    }
    
    func test_retrieve_nonEmptyCache_onErrorDeliverError() {
        //        let storeURL = storeURLForTest()
        //        let sut = makeSUT(storeURL: storeURL)
        //        assertThatRetrieveFromNonEmptyCacheOnErrorDeliverError(on: sut, storeURL: storeURL)
    }
    
    func test_retrieve_nonEmptyCache_haseNoSideEffectOnRetrieveTwiceOnError() {
        //        let storeURL = storeURLForTest()
        //        let sut = makeSUT(storeURL: storeURL)
        //       assertThatRetrieveNonEmptyCacheHaseNoSideEffectOnRetrieveTwiceOnError(on: sut, storeURL: storeURL)
    }
    
    func test_insert_toEmptyCache_insertData() {
        let sut = makeSUT()
        assertThatInsertToEmptyCacheInsertData(on: sut)
    }
    
    func test_insert_toNonEmptyCache_overridePreviousData() {
        let sut = makeSUT()
        assertThatInsertToNonEmptyCacheOverridePreviousData(on: sut)
    }
    
    func test_insert_onInsertionErrorDeliverError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        assertThatInsertOnInsertionErrorDeliverError(on: sut)
    }
    
    func test_insert_hasNoSideEffectOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        assertThatInsertHasNoSideEffectOnInsertionError(on: sut)
    }
    
    func test_delete_emptyCache_doNoting() {
        let sut = makeSUT()
        assertThatDeleteEmptyCacheDoNoting(on: sut)
    }
    
    func test_delete_emptyCache_hasNoSideEffectOnCache() {
        let sut = makeSUT()
        assertThatDeleteEmptyCacheHasNoSideEffectOnCache(on: sut)
    }
    
    func test_delete_nonEmptyCache_leaveCacheEmpty() {
        let sut = makeSUT()
        assertThatDeleteNonEmptyCacheLeaveCacheEmpty(on: sut)
    }
    
    func test_delete_onDeletionErrorDeliverError() {
        //        let noDeletePermissionURL = cacheDirectory()
        //        let sut = makeSUT(storeURL: noDeletePermissionURL)
        //        assertThatDeleteOnDeletionErrorDeliverError(on: sut)
    }
    
    func test_delete_hasNoSideEffectOnDeletionError() {
        //        let noDeletePermissionURL = cacheDirectory()
        //        let sut = makeSUT(storeURL: noDeletePermissionURL)
        //
        //        assertThatDeleteHasNoSideEffectOnDeletionError(on: sut)
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        assertThatStoreHasNoSideEffectWhenRunSerially(on: sut)
    }
    
    // MARK: Helper
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let storeURL = URL(filePath: "/dev/null")
        let bundle = Bundle(for: CoreDataFeedStore.self)
        let sut = CoreDataFeedStore(storeURL: storeURL, bundle: bundle)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
}
