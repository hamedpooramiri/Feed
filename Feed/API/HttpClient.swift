//
//  HttpClient.swift
//  Feed
//
//  Created by hamedpouramiri on 8/7/23.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HttpClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
