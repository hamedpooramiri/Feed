//
//  RemoteFeedLoader.swift
//  FeedTests
//
//  Created by hamedpouramiri on 8/7/23.
//

import XCTest
import Feed

final class RemoteFeedLoaderTest: XCTestCase {

    let url = URL(string: "www.a-url.com")!

    func test_init_notNilURL() {
        let client = HTTPClientSpy()
        let sut = makeSUT(url: url, client: client)
        sut.load { _ in }
        XCTAssertTrue(!client.requestedURLs.isEmpty)
    }
    
    func test_load_callOnce() {
        let client = HTTPClientSpy()
        let sut = makeSUT(url: url, client: client)
        sut.load { _ in }
        XCTAssertTrue(client.requestedURLs.count == 1)
    }
    
    func test_load_callTwice() {
        let client = HTTPClientSpy()
        let sut = makeSUT(url: url, client: client)
        sut.load { _ in }
        sut.load { _ in }
        XCTAssertTrue(client.requestedURLs.count == 2)
    }
    
    func test_load_deliverConactivityErrorOnClientError() {
        let client = HTTPClientSpy()
        let sut = makeSUT(url: url, client: client)
        
        exp(sut, toCompleteWith: .failure(.connectivity)) {
            client.complete(with: .connectivity, at: 0)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let client = HTTPClientSpy()
        let sut = makeSUT(url: url, client: client)

        let statusCodes = [199, 201, 300, 400, 500].enumerated()

        statusCodes.forEach { index, code in
            exp(sut, toCompleteWith: .failure(.invalidData)) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let client = HTTPClientSpy()
        let sut = makeSUT(url: url, client: client)
        exp(sut, toCompleteWith: .failure(.invalidData)) {
            let invalidJson = Data("invalidJson".utf8)
            client.complete(withStatusCode: 200, with: invalidJson)
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSON() {
        let client = HTTPClientSpy()
        let sut = makeSUT(url: url, client: client)
        exp(sut, toCompleteWith: .success([])) {
            let emptyJSON = Data("{\"items\": []}".utf8)
            client.complete(withStatusCode: 200, with: emptyJSON)
        }
    }

    //MARK: - Helper
    
    func exp(_ sut: RemoteFeedLoader, toCompleteWith result: RemoteFeedLoader.Result, when action: ()-> Void, file: StaticString = #filePath, line: UInt = #line ) {
        var capturedResult: [RemoteFeedLoader.Result] = []
        sut.load { capturedResult.append($0) }
        action()
        XCTAssertEqual(capturedResult, [result])
    }

    
    func makeSUT(url: URL, client: HttpClient) -> RemoteFeedLoader {
         RemoteFeedLoader(url: url, client: client)
    }
    
    
    private class HTTPClientSpy: HttpClient {

        var requestedURLs = [(url: URL, completion: (HTTPClientResult) -> Void)]()

        func get(from url: URL, completion:  @escaping (HTTPClientResult) -> Void) {
            requestedURLs.append((url, completion))
        }

        func complete(with error: RemoteFeedLoader.Error, at index: Int) {
            requestedURLs[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, at index: Int = 0, with data: Data = Data()) {
            let response = HTTPURLResponse(url: requestedURLs[index].url,
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            requestedURLs[index].completion(.success(data, response))
        }
        
    }
    
    
}
