//
//  FeedStoreSpecs.swift
//  FeedTests
//
//  Created by hamedpouramiri on 8/13/23.
//

import Foundation

/// any FeedStore concrete implementation Tests must implement this Protocol,
/// provide structure for TestCases
protocol FeedStoreSpecs {

     func test_retrieve_emptyCache_deliverEmpty()

     func test_retrieve_emptyCache_hasNoSideEffectRetrieveTwice()

     func test_retrieve_nonEmptyCache_deliverData()

     func test_retrieve_nonEmptyCache_hasNoSideEffectOnRetrieveTwice()


     func test_insert_toEmptyCache_insertData()

     func test_insert_toNonEmptyCache_overridePreviousData()


     func test_delete_emptyCache_doNoting()

     func test_delete_emptyCache_hasNoSideEffectOnCache()

     func test_delete_nonEmptyCache_leaveCacheEmpty()

    
     func test_storeSideEffects_runSerially()
}

protocol FailableRetrieveFeedStoreSpecs: FeedStoreSpecs {
    func test_retrieve_nonEmptyCache_onErrorDeliverError()
    func test_retrieve_nonEmptyCache_haseNoSideEffectOnRetrieveTwiceOnError()
}

protocol FailableInsertionFeedStoreSpecs: FeedStoreSpecs {
    func test_insert_onInsertionErrorDeliverError()
    func test_insert_hasNoSideEffectOnInsertionError()
}

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
    func test_delete_onDeletionErrorDeliverError()
    func test_delete_hasNoSideEffectOnDeletionError()
}

/// any FeedStore concrete implementation Tests can implement this typealias,
/// provide structure for TestCases
typealias FailableFeedStoreSpecs = FailableRetrieveFeedStoreSpecs & FailableInsertionFeedStoreSpecs & FailableDeleteFeedStoreSpecs
