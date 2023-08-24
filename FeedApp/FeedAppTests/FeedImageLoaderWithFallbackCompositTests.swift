//
//  FeedImageLoaderWithFallbackCompositTests.swift
//  FeedAppTests
//
//  Created by hamedpouramiri on 8/24/23.
//

import XCTest
import Feed
import FeedApp

final class FeedImageLoaderWithFallbackCompositTests: XCTestCase {

    func test_load_deliversPrimaryFeedImageOnPrimaryLoaderSuccess(){
        let data = "a data".data(using: .utf8)!
        let sut = makeSUT(primaryResult: .success(data), fallbackResult: .failure(anyNSError()))
        expect(sut, withURL: anyURL(), toCompleteWith: .success(data))
    }

    func test_load_deliversFallbackFeedImageOnPrimaryLoaderError(){
        let data = "a data".data(using: .utf8)!
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(data))
        expect(sut, withURL: anyURL(), toCompleteWith: .success(data))
    }

    func test_load_deliversFallbackErrorOnPrimaryAndFallbackImageLoaderError(){
        let primaryError = anyNSError(code: 0)
        let fallbackError = anyNSError(code: 1)
        let sut = makeSUT(primaryResult: .failure(primaryError), fallbackResult: .failure(fallbackError))
        expect(sut, withURL: anyURL(), toCompleteWith: .failure(fallbackError))
    }

    func test_load_OnCancelTaskDeliversNoting(){
        let loaderSpy = FeedImageLoaderSpy()
        let sut = FeedImageLoaderWithFallbackComposit(primary: loaderSpy, fallback: loaderSpy)

        var capturedResult: [FeedImageLoader.Result] = []
        let task = sut.loadImage(with: anyURL()) { capturedResult.append($0)}

        task.cancel()
        loaderSpy.completeLoad()
        XCTAssertTrue(capturedResult.isEmpty)
    }

    func test_load_afterSUTHasBeenDeallocatedDeliversNoResult() {
        let loaderSpy = FeedImageLoaderSpy()
        var sut: FeedImageLoaderWithFallbackComposit? = FeedImageLoaderWithFallbackComposit(primary: loaderSpy, fallback: loaderSpy)
        var capturedResult: [FeedImageLoader.Result] = []
        _ = sut?.loadImage(with: anyURL()) { capturedResult.append($0) }
        sut = nil
        loaderSpy.completeLoad()
        XCTAssertTrue(capturedResult.isEmpty, "expect to not return values after sut has been deallocated")
    }

    // MARK: Helper
    func makeSUT(primaryResult: FeedImageLoader.Result, fallbackResult: FeedImageLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedImageLoaderWithFallbackComposit {
        let primary = FeedImageLoaderStub(result: primaryResult)
        let fallback = FeedImageLoaderStub(result: fallbackResult)
        let sut = FeedImageLoaderWithFallbackComposit(primary: primary, fallback: fallback)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    func expect(_ sut: FeedImageLoader, withURL url: URL, toCompleteWith expectedResult: FeedImageLoader.Result, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for load result")
        _ = sut.loadImage(with: url) { recievedResult in
            switch (recievedResult, expectedResult) {
            case let (.success(recievedFeed), .success(expectedFeed)):
                XCTAssertEqual(recievedFeed, expectedFeed,"expect to get \(expectedFeed) but got \(recievedFeed)", file: file, line: line)
            case let (.failure(recievedError), .failure(expectedError)):
                XCTAssertEqual(recievedError as NSError, expectedError as NSError,"expect to get \(expectedError) but got \(recievedError)", file: file, line: line)
            default:
                XCTFail("expect to get \(expectedResult), but got \(recievedResult) instade", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    func anyNSError(code: Int = 0) -> NSError {
        NSError(domain: "any error", code: code)
    }

    func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }

    private class FeedImageLoaderStub: FeedImageLoader {
        
        private let result: FeedImageLoader.Result
        
        init(result: FeedImageLoader.Result) {
            self.result = result
        }
        func loadImage(with url: URL, completion: @escaping (FeedImageLoader.Result) -> Void) -> Feed.ImageLoaderTask {
            completion(result)
            return FeedImageLoaderTaskSpy {}
        }
    }

    private class FeedImageLoaderSpy: FeedImageLoader {

        private var capturedResult: [(url: URL, completion: (FeedImageLoader.Result) -> Void)] = []
        
        func loadImage(with url: URL, completion: @escaping (FeedImageLoader.Result) -> Void) -> Feed.ImageLoaderTask {
            capturedResult.append((url, completion))
            return FeedImageLoaderTaskSpy { [weak self, url] in
                self?.capturedResult.removeAll { $0.url == url }
            }
        }

        func completeLoad(at index: Int = 0) {
            if capturedResult.count  > index {
                capturedResult[index].completion(.success(Data()))
            }
        }
    }

    private class FeedImageLoaderTaskSpy: ImageLoaderTask {
        
        private let onCancel: ()-> Void

        init(onCancel: @escaping () -> Void) {
            self.onCancel = onCancel
        }
        
        func cancel() {
            onCancel()
        }
    }
}
