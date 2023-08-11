//
//  APIFeedItem.swift
//  Feed
//
//  Created by hamedpouramiri on 8/11/23.
//

import Foundation

public struct APIFeedItemResponse: Decodable {
    let items: [APIFeedItem]
}

public struct APIFeedItem: Decodable {
     let id: UUID
     let description: String?
     let location: String?
     let image: URL

}
