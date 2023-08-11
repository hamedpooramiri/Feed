//
//  FeedCacheHelper.swift
//  FeedTests
//
//  Created by hamedpouramiri on 8/11/23.
//

import Foundation
import Feed

func uniqueFeedItem() -> FeedItem {
    FeedItem(id: UUID(), description: "any description", location: "any location", imageUrl: anyURL())
}

func uniqueFeeds() -> (models: [FeedItem], localItems: [LocalFeedItem]) {
    let items = [uniqueFeedItem(), uniqueFeedItem()]
    return (items, items.map {
        LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageUrl: $0.imageUrl)
    })
}

 extension Date {
    func add(by days: Int) -> Date {
        Calendar(identifier: .gregorian ).date(byAdding: .day, value: days, to: self)!
    }
    func add(by secends: TimeInterval) -> Date {
        self + secends
    }
}
