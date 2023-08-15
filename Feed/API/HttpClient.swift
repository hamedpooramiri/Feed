//
//  HttpClient.swift
//  Feed
//
//  Created by hamedpouramiri on 8/7/23.
//

import Foundation

public protocol HttpClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    func get(from url: URL, completion: @escaping (Result) -> Void)
}
