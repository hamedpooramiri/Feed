//
//  LocalFeedLoader.swift
//  Feed
//
//  Created by hamedpouramiri on 8/10/23.
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

public final class LocalFeedLoader {
    
    private var store: FeedStore
    private var currentDate: () -> Date
    
    public typealias SaveResult = Error?
    public typealias RetrieveResult = LoadFeedResult
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(items: [FeedItem], completion: @escaping (SaveResult) -> Void){
        store.deleteFeeds { [weak self] error in
            guard let self = self else { return }
            if let deletionError = error {
                completion(deletionError)
            } else {
                self.cache(items, with: completion)
            }
        }
    }
    
    private func cache(_ items: [FeedItem], with completion: @escaping (SaveResult) -> Void ) {
        store.insert(feeds: items.toLocal(), timeStamp: currentDate()) { [weak self] insertionError in
            guard self != nil else { return }
            completion(insertionError)
        }
    }
}

extension LocalFeedLoader: FeedLoader {
    public func load(completion: @escaping (RetrieveResult)-> Void) {
        store.retrieve { [weak self ] result in
            guard let self = self else { return }
            switch result {
            case let .found(items, timeStamp) where FeedCachePolicy.validate(timeStamp, against: self.currentDate()):
                completion(.success(items.toModel()))
            case let .failure(error):
                completion(.failure(error))
            case .found:
                completion(.success([]))
            case .empty:
                completion(.success([]))
            }
        }
    }
}
extension LocalFeedLoader {
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.store.deleteFeeds { _ in }
            case let .found(_, timeStamp) where !FeedCachePolicy.validate(timeStamp, against: self.currentDate()):
                self.store.deleteFeeds { _ in }
            case .empty, .found:
                break
            }
        }
    }
}
