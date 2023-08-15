//
//  CoreDataFeedStore.swift
//  Feed
//
//  Created by hamedpouramiri on 8/14/23.
//

import CoreData

public class CoreDataFeedStore: FeedStore {

    private static let modelName = "FeedStore"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataFeedStore.self))
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }

    public init(storeURL: URL) throws {
        guard let model = CoreDataFeedStore.model else {
            throw StoreError.modelNotFound
        }
        do {
            container = try NSPersistentContainer.load(name: CoreDataFeedStore.modelName, model: model, url: storeURL)
            context = container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error)
        }
    }
    
    public func deleteFeeds(completion: @escaping DeleteCompletion) {
        perform { context in
            completion(DeleteResult {
                try ManagedCache.deleteCache(in: context)
            })
        }
    }
    
    public func insert(feeds: [Feed.LocalFeedItem], timeStamp: Date, completion: @escaping InsertCompletion) {
        perform { context in
            completion(InsertResult {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timeStamp
                managedCache.feed = ManagedFeedItem.item(from: feeds, in: context)
                try context.save()
            })
        }
    }
    
    public func retrieve(completion: @escaping retrieveCompletion) {
        perform { context in
            completion(RetrieveResult(catching: {
                try ManagedCache.find(in: context).map { cache in
                     return (items: cache.localFeed, timeStamp: cache.timestamp)
                }
            }))
        }
    }
    

    private func perform(_ action: @escaping (NSManagedObjectContext)-> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}
