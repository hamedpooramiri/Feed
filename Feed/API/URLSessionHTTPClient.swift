//
//  URLSessionHTTPClient.swift
//  Feed
//
//  Created by hamedpouramiri on 8/8/23.
//

import Foundation

public class URLSessionHTTPClient: HttpClient {
    
   private let session: URLSession

    public init(session: URLSession) {
        self.session = session
    }

    struct unexpectedValueRepresentation: Error {}
    
    public func get(from url: URL, completion: @escaping (HttpClient.Result)-> Void) -> HTTPClientTask? {
        let task = URLSessionHTTPClientTask(completion)
        task.wrapped = session.dataTask(with: url) { data, response, error in
            if let error = error {
                task.complete(with: .failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                task.complete(with: .success((data, response)))
            } else {
                task.complete(with: .failure(unexpectedValueRepresentation()))
            }
        }
        task.wrapped?.resume()
        return task
    }

}
private final class URLSessionHTTPClientTask: HTTPClientTask {

    private var completion: ((HttpClient.Result)-> Void)?
    var wrapped: URLSessionDataTask?
    
    init(_ completion: @escaping (HttpClient.Result)-> Void) {
        self.completion = completion
    }
    
    func complete(with result: HttpClient.Result) {
        completion?(result)
    }
    
    func cancel() {
        preventFurtherCompletions()
        wrapped?.cancel()
    }
    
    private func preventFurtherCompletions() {
        completion = nil
    }
}
