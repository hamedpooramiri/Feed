//
//  RemoteFeedImageLoaderTests.swift
//  FeedTests
//
//  Created by hamedpouramiri on 8/22/23.
//

import XCTest
import Feed

final class RemoteFeedImageLoaderTests: XCTestCase {

    func test_init_notPerformAnyRequest() {
        let client = HTTPClientSpy()
        let _ = makeSUT(client: client)
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_callOnce() {
        let client = HTTPClientSpy()
        let sut = makeSUT(client: client)
        let url = anyURL()
        _ = sut.loadImage(with: url) {_ in }
        XCTAssertTrue(client.requestedURLs.count == 1)
    }
    
    func test_load_callTwice() {
        let client = HTTPClientSpy()
        let sut = makeSUT(client: client)
        let url = anyURL()
        _ = sut.loadImage(with: url) {_ in }
        _ = sut.loadImage(with: url) {_ in }
        XCTAssertTrue(client.requestedURLs.count == 2)
    }

    func test_load_deliverConactivityErrorOnClientError() {
        let client = HTTPClientSpy()
        let sut = makeSUT(client: client)
        exp(sut, withLoadURL: anyURL(), toCompleteWith: .failure(RemoteFeedImageLoader.Error.connectivity)) {
            client.complete(with: .connectivity, at: 0)
        }
    }

    func test_load_deliversErrorOnNon200HTTPResponse() {
        let client = HTTPClientSpy()
        let sut = makeSUT(client: client)

        let statusCodes = [199, 201, 300, 400, 500].enumerated()

        statusCodes.forEach { index, code in
            exp(sut, withLoadURL: anyURL(), toCompleteWith: .failure(RemoteFeedImageLoader.Error.invalidData)) {
                client.complete(withStatusCode: code, at: index, with: Data())
            }
        }
    }

    func test_load_NotDeliverResultAfterSUTDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteFeedImageLoader? = makeSUT(client: client)

        var capturedResults = [RemoteFeedImageLoader.Result]()
        _ = sut?.loadImage(with: anyURL()) { capturedResults.append($0) }

        sut = nil
        client.complete(withStatusCode: 200, with: Data())
        
        XCTAssertTrue(capturedResults.isEmpty)
    }

    func test_LoadImage_cancelImageLoadingWhenCanceled() {
        let client = HTTPClientSpy()
        let sut = makeSUT(client: client)
        var capturedResults = [RemoteFeedImageLoader.Result]()
        let task = sut.loadImage(with: anyURL()) { capturedResults.append($0) }
        task.cancel()
        client.complete(withStatusCode: 0, with: Data())
        
        XCTAssertTrue(capturedResults.isEmpty)
    }

    //MARK: Helper
    
    func exp(_ sut: RemoteFeedImageLoader, withLoadURL url: URL, toCompleteWith expectedResult: RemoteFeedImageLoader.Result, when action: ()-> Void, file: StaticString = #filePath, line: UInt = #line) {

        let exp = expectation(description: "wait for load completion")
        _ = sut.loadImage(with: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteFeedImageLoader.Error), .failure(expectedError as RemoteFeedImageLoader.Error)):
                XCTAssertEqual(receivedError , expectedError , file: file, line: line)
            default:
                XCTFail("expected to get result \(expectedResult) but got \(receivedResult)", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp])
    }

    private func makeSUT(client: HTTPClientSpy = HTTPClientSpy(), file: StaticString = #filePath, line: UInt = #line) -> RemoteFeedImageLoader {
        let sut = RemoteFeedImageLoader(client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private class HTTPClientSpy: HttpClient {

        var requestedURLs = [(url: URL, task: HTTPClientTask)]()

        func get(from url: URL, completion:  @escaping (HttpClient.Result) -> Void) -> Feed.HTTPClientTask? {
            let task = HTTPClientTaskSpy(completion)
            requestedURLs.append((url, task))
            return task
        }

        func complete(with error: RemoteFeedImageLoader.Error, at index: Int) {
            requestedURLs[index].task.complete(with: .failure(error))
        }
        
        func complete(withStatusCode code: Int, at index: Int = 0, with data: Data) {
            let response = HTTPURLResponse(url: requestedURLs[index].url,
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            requestedURLs[index].task.complete(with: .success((data, response)))
        }
    }

    private class HTTPClientTaskSpy: HTTPClientTask {

        private var completion: ((HTTPClientTask.Result) -> Void)?

        required init(_ completion: @escaping (HTTPClientTask.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: HTTPClientTask.Result) {
            completion?(result)
        }
        
        func cancel() {
            completion = nil
        }
    }
}
