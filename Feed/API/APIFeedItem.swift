//
//  APIFeedItem.swift
//  Feed
//
//  Created by hamedpouramiri on 8/11/23.
//

import Foundation

struct APIFeedItemResponse: Decodable {
    let items: [APIFeedItem]
}

struct APIFeedItem: Decodable {

     let id: UUID
     let description: String?
     let location: String?
     let image: URL
    
    var feedItem: FeedItem {
        FeedItem(id: id, description: description, location: location, imageUrl: image)
    }

}
