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
    
    override class func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override class func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_performGetRequest() {
        let url = URL(string: "http://a-url.com")!
        let exp = expectation(description: "wait for request")
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        makeSUT().get(from: url) { _ in}
        wait(for: [exp])
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "http://a-url.com")!
        let domainError = NSError(domain: "a error", code: 1)
        URLProtocolStub.stub(data: nil, response: nil, error: domainError)

        let exp = expectation(description: "a wait")
        makeSUT().get(from: url) { result in
            if case .failure(let error as NSError) = result {
                XCTAssertEqual(error.code, domainError.code)
                XCTAssertEqual(error.localizedDescription, domainError.localizedDescription)
            } else {
                XCTFail("expected failure with error \(domainError) but got \(result)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    //MARK: - Helper
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let config = URLSessionConfiguration.default
        config.protocolClasses?.insert(URLProtocolStub.self, at: 0)
        let session = URLSession(configuration: config)
        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut)
        return sut
    }

    private class URLProtocolStub: URLProtocol {

        private static var stub: Stub?
        private static var observeRequest: ((URLRequest)-> Void)?

        public struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            URLProtocolStub.stub = Stub(data: data, response: response, error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests(){
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            observeRequest = nil
        }
        
        static func observeRequests(_ observer: @escaping (URLRequest)-> Void) {
            observeRequest = observer
        }

        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            observeRequest?(request)
            return request
        }
        
        override func startLoading() {

            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {}
    }

}
