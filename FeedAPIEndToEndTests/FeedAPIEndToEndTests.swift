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
        switch getFeedResult() {
        case .success(let items)?:
            XCTAssertEqual(items.count, 8, "expected 8 items to receive from test account")
            XCTAssertEqual(items[0].id.uuidString, "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6")
            XCTAssertEqual(items[0].location, "Location 1")
        case .failure(let error)?:
            XCTFail("expected to get successful result but got error \(error)")
        default:
            XCTFail("expected to get successful result but got no result")
        }
    }

    func getFeedResult(file: StaticString = #filePath, line: UInt = #line) -> LoadFeedResult? {
        let url = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        let loader = RemoteFeedLoader(url: url, client: client)
        let exp = expectation(description: "waiting for load data")
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(client,file: file, line: line)
        var expectedResult: LoadFeedResult?
        loader.load { result in
            expectedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10.0)
        return expectedResult
    }
    
    // MARK: The fixed Data Expected From the server
    /*
     {
         "items": [
             {
                 "id": "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
                 "description": "Description 1",
                 "location": "Location 1",
                 "image": "https://url-1.com",
             },
             {
                 "id": "BA298A85-6275-48D3-8315-9C8F7C1CD109",
                 "location": "Location 2",
                 "image": "https://url-2.com",
             },
             {
                 "id": "5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
                 "description": "Description 3",
                 "image": "https://url-3.com",
             },
             {
                 "id": "FF0ECFE2-2879-403F-8DBE-A83B4010B340",
                 "image": "https://url-4.com",
             },
             {
                 "id": "DC97EF5E-2CC9-4905-A8AD-3C351C311001",
                 "description": "Description 5",
                 "location": "Location 5",
                 "image": "https://url-5.com",
             },
             {
                 "id": "557D87F1-25D3-4D77-82E9-364B2ED9CB30",
                 "description": "Description 6",
                 "location": "Location 6",
                 "image": "https://url-6.com",
             },
             {
                 "id": "A83284EF-C2DF-415D-AB73-2A9B8B04950B",
                 "description": "Description 7",
                 "location": "Location 7",
                 "image": "https://url-7.com",
             },
             {
                 "id": "F79BD7F8-063F-46E2-8147-A67635C3BB01",
                 "description": "Description 8",
                 "location": "Location 8",
                 "image": "https://url-8.com",
             }
         ]
     }
     */
}
