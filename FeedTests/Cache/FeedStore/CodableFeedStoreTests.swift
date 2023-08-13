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
        let storeURL = storeURLForTest()
        let sut = makeSUT(storeURL: storeURL)
        assertThatRetrieveFromNonEmptyCacheOnErrorDeliverError(on: sut, storeURL: storeURL)
    }

    func test_retrieve_nonEmptyCache_haseNoSideEffectOnRetrieveTwiceOnError() {
        let storeURL = storeURLForTest()
        let sut = makeSUT(storeURL: storeURL)
       assertThatRetrieveNonEmptyCacheHaseNoSideEffectOnRetrieveTwiceOnError(on: sut, storeURL: storeURL)
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
        let noDeletePermissionURL = cacheDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        assertThatDeleteOnDeletionErrorDeliverError(on: sut)
    }

    func test_delete_hasNoSideEffectOnDeletionError() {
        let noDeletePermissionURL = cacheDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)

        assertThatDeleteHasNoSideEffectOnDeletionError(on: sut)
    }

    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        assertThatStoreHasNoSideEffectWhenRunSerially(on: sut)
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
