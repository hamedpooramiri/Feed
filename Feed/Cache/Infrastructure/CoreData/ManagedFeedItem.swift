//
//  ManagedFeedItem.swift
//  Feed
//
//  Created by hamedpouramiri on 8/14/23.
//

import CoreData

@objc(ManagedFeedItem)
class ManagedFeedItem: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var itemDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
}

extension ManagedFeedItem {

    static func item(from localFeed: [LocalFeedItem], in context: NSManagedObjectContext) -> NSOrderedSet {
        let images = NSOrderedSet(array: localFeed.map { local in
            let managed = ManagedFeedItem(context: context)
            managed.id = local.id
            managed.itemDescription = local.description
            managed.location = local.location
            managed.url = local.imageUrl
            return managed
        })
        context.userInfo.removeAllObjects()
        return images
    }

    var local: LocalFeedItem {
        return LocalFeedItem(id: id, description: itemDescription, location: location, imageUrl: url)
    }
}
