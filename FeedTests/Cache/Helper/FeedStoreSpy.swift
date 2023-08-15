//
//  FeedStoreSpy.swift
//  FeedTests
//
//  Created by hamedpouramiri on 8/11/23.
//

import Foundation
import Feed

class FeedStoreSpy: FeedStore {
    
    enum ReceivedMessage: Equatable {
        case deleteFeeds
        case insertFeeds(items: [LocalFeedItem], timeStamp: Date)
        case retrieve
    }
    
    var receivedMessages: [ReceivedMessage] = []
    
    private var capturedDeleteCompletions: [DeleteCompletion] = []
    private var capturedInsertionCompletions: [InsertCompletion] = []
    private var capturedRetrieveCompletions: [retrieveCompletion] = []
    
    
    func deleteFeeds(completion: @escaping DeleteCompletion) {
        receivedMessages.append(.deleteFeeds)
        capturedDeleteCompletions.append(completion)
    }
    
    func insert(feeds: [LocalFeedItem], timeStamp: Date, completion: @escaping InsertCompletion) {
        capturedInsertionCompletions.append(completion)
        receivedMessages.append(.insertFeeds(items: feeds, timeStamp: timeStamp))
    }
    
    func retrieve(completion: @escaping retrieveCompletion) {
        capturedRetrieveCompletions.append(completion)
        receivedMessages.append(.retrieve)
    }
    
    func completeDelete(with error: Error, at index: Int = 0) {
        capturedDeleteCompletions[index](.failure(error))
    }
    
    func completeDeleteSuccessfully(at index: Int = 0) {
        capturedDeleteCompletions[index](.success(()))
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        capturedInsertionCompletions[index](.failure(error))
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        capturedInsertionCompletions[index](.success(()))
    }

    func completeRetrieve(with error: Error, at index: Int = 0) {
        capturedRetrieveCompletions[index](.failure(error))
    }
    
    func completeRetrieveWithEmptyCache(at index: Int = 0) {
        capturedRetrieveCompletions[index](.success(nil))
    }
    
    func completeRetrieve(with items: [LocalFeedItem], timeStamp: Date, at index: Int = 0) {
        capturedRetrieveCompletions[index](.success((items: items, timeStamp: timeStamp)))
    }
}
