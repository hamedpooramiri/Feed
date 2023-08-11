//
//  FeedCachePolicy.swift
//  Feed
//
//  Created by hamedpouramiri on 8/12/23.
//

import Foundation

final public class FeedCachePolicy {

    private static let calender = Calendar(identifier: .gregorian)
    private static var maxCacheAgeInDays: Int { 7 }

    private init() {}

    static func validate(_ timeStamp: Date, against date: Date) -> Bool {
        guard let maxAgeCache = calender.date(byAdding: .day, value: maxCacheAgeInDays, to: timeStamp) else { return false }
        return date < maxAgeCache
    }
}
