//
//  FeedItem.swift
//  Feed
//
//  Created by hamedpouramiri on 8/7/23.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let url: URL
}
