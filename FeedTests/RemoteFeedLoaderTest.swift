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
    
    
    func test_load_deliverErrorOnClientError() {
        let client = HTTPClientSpy()
        let sut = makeSUT(url: url, client: client)

        var capturedError: Error?
        sut.load { result in
            if case .failure(let error) = result {
                capturedError = error
            }
        }
        client.complete(with: .connectivity, at: 0)
        XCTAssertNotNil(capturedError)
    }
    
    func test_load_deliverConactivityErrorOnClientError() {
        let client = HTTPClientSpy()
        let sut = makeSUT(url: url, client: client)
        let error = RemoteFeedLoader.Error.connectivity
        var capturedError: RemoteFeedLoader.Error?
        sut.load { result in
            if case .failure(let error) = result {
                capturedError = error
            }
        }
        client.complete(with: error, at: 0)
        XCTAssertNotNil(capturedError)
        XCTAssertEqual(capturedError, error)
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let client = HTTPClientSpy()
        let sut = makeSUT(url: url, client: client)

        let statusCodes = [199, 201, 300, 400, 500].enumerated()

        statusCodes.forEach { index, code in

            var capturedErrors: [RemoteFeedLoader.Error] = []
            
            sut.load { result in
                if case .failure(let error) = result {
                    capturedErrors.append(error)
                }
            }
            
            client.complete(withStatusCode: code, index: index)
            XCTAssertEqual(capturedErrors, [.invalidData])
            
        }
        
    }
    
    //MARK: - Helper
    
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
        
        func complete(withStatusCode code: Int, index: Int) {
            let response = HTTPURLResponse(url: requestedURLs[index].url,
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            requestedURLs[index].completion(.success(response))
        }
        
    }
    
    
}
