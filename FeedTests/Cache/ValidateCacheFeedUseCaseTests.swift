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
 
}
