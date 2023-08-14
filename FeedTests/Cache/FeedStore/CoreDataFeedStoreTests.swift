//
//  CoreDataFeedStoreTests.swift
//  FeedTests
//
//  Created by hamedpouramiri on 8/14/23.
//

import XCTest
import Feed

final class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    
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
    
    func test_insert_toEmptyCache_insertData() {
        let sut = makeSUT()
        assertThatInsertToEmptyCacheInsertData(on: sut)
    }
    
    func test_insert_toNonEmptyCache_overridePreviousData() {
        let sut = makeSUT()
        assertThatInsertToNonEmptyCacheOverridePreviousData(on: sut)
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
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        assertThatStoreHasNoSideEffectWhenRunSerially(on: sut)
    }
    
    // MARK: Helper
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let storeURL = URL(filePath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
}
