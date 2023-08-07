//
//  URLSessionHTTPClientTests.swift
//  FeedTests
//
//  Created by hamedpouramiri on 8/8/23.
//

import XCTest
import Feed


protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask {
    func resume()
}

class URLSessionHTTPClient {
    
   private let session: HTTPSession

    init(session: HTTPSession) {
        self.session = session
    }

    func get(from url: URL, completion: @escaping (HTTPClientResult)-> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(HTTPClientResult.failure(error))
            }
        }.resume()
    }

}


final class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_resumeOnce() {
        let url = URL(string: "www.a-url.com")!
        let task = URLSessionDataTaskSpy()
        let session = URLSessionSpy()
        session.stub(url: url, with: task)
        let sut = makeSUT(session: session)
        sut.get(from: url) {_ in }
        XCTAssertEqual(task.resumeCount, 1)
    }

    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "www.a-url.com")!
        let task = URLSessionDataTaskSpy()
        let session = URLSessionSpy()
        let domainError = NSError(domain: "a error", code: 0)
        session.stub(url: url, with: task, error: domainError)
        let sut = makeSUT(session: session)
        let exp = expectation(description: "a wait")
        sut.get(from: url) { result in
            if case .failure(let error as NSError) = result {
             XCTAssertEqual(error, domainError)
            }
            exp.fulfill()
        }
        wait(for: [exp])
    }
    
    //MARK: - Helper
    
    func makeSUT(session: HTTPSession) -> URLSessionHTTPClient {
        URLSessionHTTPClient(session: session)
    }
    
    private class URLSessionSpy: HTTPSession {

        var stubs: [URL : Stub] = [:]
        
        public struct Stub {
            let task: HTTPSessionTask
            let error: Error?
        }
        
        func stub(url: URL, with task: HTTPSessionTask, error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }

        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
            guard let stub = stubs[url] else  {
                fatalError("could not find stub for \(url)")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }

    }
    
    private class FakeURLSessionDataTask: HTTPSessionTask {
         func resume() {}
    }

    private class URLSessionDataTaskSpy: HTTPSessionTask {
        
        var resumeCount: Int = 0
        
        func resume() {
            resumeCount += 1
        }
        
    }

}
