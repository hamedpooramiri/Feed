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

    public typealias SaveResult = Error?

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
        store.insert(feeds: items, timeStamp: currentDate()) { [weak self] insertionError in
            guard self != nil else { return }
            completion(insertionError)
        }
    }
}

public protocol FeedStore {
    typealias DeleteCompletion = (Error?) -> Void
    typealias InsertCompletion = (Error?) -> Void
    func deleteFeeds(compeletion: @escaping DeleteCompletion)
    func insert(feeds: [FeedItem], timeStamp: Date, completion: @escaping InsertCompletion)
}
