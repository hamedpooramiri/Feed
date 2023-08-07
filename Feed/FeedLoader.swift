//
//  FeedLoader.swift
//  Feed
//
//  Created by hamedpouramiri on 8/7/23.
//

import Foundation

protocol FeedLoader {
    func load(completion: @escaping (Result)-> Void)
}
