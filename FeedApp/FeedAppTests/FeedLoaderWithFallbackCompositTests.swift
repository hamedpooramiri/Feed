//
//  FeedLoaderWithFallbackCompositTests.swift
//  FeedAppTests
//
//  Created by hamedpouramiri on 8/24/23.
//

import XCTest
import Feed

final class FeedLoaderWithFallbackComposit: FeedLoader {
    
    private let primary: FeedLoader
    private let fallback: FeedLoader

    init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }

    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                completion(result)
            case .failure:
                self.fallback.load(completion: completion)
            }
        }
    }
}

final class FeedLoaderWithFallbackCompositTests: XCTestCase {

    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess(){
        let expectedFeed = [uniqueFeedItem()]
        let sut = makeSUT(primaryResult: .success(expectedFeed), fallbackResult: .failure(anyNSError()))
        expect(sut, toCompleteWith: .success(expectedFeed))
    }

    func test_load_deliversFallbackFeedOnPrimaryLoaderError(){
        let expectedFeed = [uniqueFeedItem()]
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(expectedFeed))
        expect(sut, toCompleteWith: .success(expectedFeed))
    }

    func test_load_deliversFallbackErrorOnPrimaryAndFallbackLoaderError(){
        let primaryError = anyNSError(code: 0)
        let fallbackError = anyNSError(code: 1)
        let sut = makeSUT(primaryResult: .failure(primaryError), fallbackResult: .failure(fallbackError))
        expect(sut, toCompleteWith: .failure(fallbackError))
    }

    func test_load_afterSUTHasBeenDeallocatedDeliversNoResult() {
        let loaderSpy = FeedLoaderSpy()
        var sut: FeedLoaderWithFallbackComposit? = FeedLoaderWithFallbackComposit(primary: loaderSpy, fallback: loaderSpy)
        var capturedResult: [FeedLoader.Result] = []
        sut?.load { capturedResult.append($0) }
        sut = nil
        loaderSpy.completeLoad()
        XCTAssertTrue(capturedResult.isEmpty, "expect to not return values after sut has been deallocated")
    }

    // MARK: Helper
    func makeSUT(primaryResult: FeedLoader.Result, fallbackResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedLoaderWithFallbackComposit {
        let primary = FeedLoaderStub(result: primaryResult)
        let fallback = FeedLoaderStub(result: fallbackResult)
        let sut = FeedLoaderWithFallbackComposit(primary: primary, fallback: fallback)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    func expect(_ sut: FeedLoader, toCompleteWith expectedResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for load result")
        sut.load { recievedResult in
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
    
    func uniqueFeedItem() -> FeedItem {
        FeedItem(id: UUID(), description: "any description", location: "any location", imageUrl: anyURL())
    }
    
    func anyNSError(code: Int = 0) -> NSError {
        NSError(domain: "any error", code: code)
    }

    func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }

    private class FeedLoaderStub: FeedLoader {
        
        private let result: FeedLoader.Result
        
        init(result: FeedLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }

    private class FeedLoaderSpy: FeedLoader {
        
        private var capturedResult: [(FeedLoader.Result) -> Void] = []
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            capturedResult.append(completion)
        }

        func completeLoad(at index: Int = 0) {
            capturedResult[index](.success([]))
        }
    }
}
