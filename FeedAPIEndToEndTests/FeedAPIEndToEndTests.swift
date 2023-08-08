//
//  FeedAPIEndToEndTests.swift
//  FeedAPIEndToEndTests
//
//  Created by hamedpouramiri on 8/9/23.
//

import XCTest
import Feed

final class FeedAPIEndToEndTests: XCTestCase {

    func test_endToEndTest_ServerGetFeedResult_matchesFixedTestAccountData() throws {
        let url = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let session = URLSession.shared
        let client = URLSessionHTTPClient(session: session)
        let loader = RemoteFeedLoader(url: url, client: client)
        let exp = expectation(description: "waiting for load data")

        var expectedResult: LoadFeedResult?
        loader.load { result in
            expectedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10.0)
        
        switch expectedResult {
        case .success(let items)?:
            XCTAssertEqual(items.count, 8, "expected 8 items to receive from test account")
        case .failure(let error)?:
            XCTFail("expected to get successful result but got error \(error)")
        default:
            XCTFail("expected to get successful result but got no result")
        }
    }

}
