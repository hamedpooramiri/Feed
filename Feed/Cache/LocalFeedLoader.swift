//
//  LocalFeedLoader.swift
//  Feed
//
//  Created by hamedpouramiri on 8/10/23.
//

import Foundation

public final class LocalFeedLoader {

    private var store: FeedStore
    private var currentDate: () -> Date
    private let calender = Calendar(identifier: .gregorian)

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

    public func load(completion: @escaping (RetrieveResult)-> Void) {
        store.retrieve { [unowned self ] result in
            switch result {
            case let .found(items, timeStamp) where self.validate(timeStamp):
                completion(.success(items.toModel()))
            case let .failure(error):
                completion(.failure(error))
            case .empty, .found:
                completion(.success([]))
            }
        }
    }

    private var maxCacheAgeInDays: Int {
        return 7
    }

    private func validate(_ timeStamp: Date) -> Bool {
        guard let maxAgeCache = calender.date(byAdding: .day, value: maxCacheAgeInDays, to: timeStamp) else { return false }
        return currentDate() < maxAgeCache
    }

    private func cache(_ items: [FeedItem], with completion: @escaping (SaveResult) -> Void ) {
        store.insert(feeds: items.toLocal(), timeStamp: currentDate()) { [weak self] insertionError in
            guard self != nil else { return }
            completion(insertionError)
        }
    }
}
