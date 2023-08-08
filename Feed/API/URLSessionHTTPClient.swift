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
    
    public func get(from url: URL, completion: @escaping (HTTPClientResult)-> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(HTTPClientResult.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(unexpectedValueRepresentation()))
            }
        }.resume()
    }

}

