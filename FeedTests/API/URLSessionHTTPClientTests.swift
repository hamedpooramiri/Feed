//
//  URLSessionHTTPClientTests.swift
//  FeedTests
//
//  Created by hamedpouramiri on 8/8/23.
//

import XCTest
import Feed


class URLSessionHTTPClient {
    
   private let session: URLSession

    init(session: URLSession) {
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
    
    func test_getFromURL_failsOnRequestError() {

        URLProtocolStub.startInterceptingRequests()

        let url = URL(string: "http://a-url.com")!
        let domainError = NSError(domain: "a error", code: 1)

        URLProtocolStub.stub(url: url, error: domainError)

        let config = URLSessionConfiguration.default
        config.protocolClasses?.insert(URLProtocolStub.self, at: 0)

        let session = URLSession(configuration: config)
        let sut = makeSUT(session: session)

        let exp = expectation(description: "a wait")
        sut.get(from: url) { result in
            if case .failure(let error as NSError) = result {
                XCTAssertEqual(error.code, domainError.code)
                XCTAssertEqual(error.localizedDescription, domainError.localizedDescription)
            } else {
                XCTFail("expected failure with error \(domainError) but got \(result)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        URLProtocolStub.stopInterceptingRequests()
    }
    
    //MARK: - Helper
    
    func makeSUT(session: URLSession) -> URLSessionHTTPClient {
        URLSessionHTTPClient(session: session)
    }
    
    private class URLProtocolStub: URLProtocol {

        static var stubs: [URL : Stub] = [:]
        
        public struct Stub {
            let error: Error?
        }
        
        static func stub(url: URL, error: Error? = nil) {
            URLProtocolStub.stubs[url] = Stub(error: error)
        }

        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests(){
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs = [:]
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            return URLProtocolStub.stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {}
    }

}
