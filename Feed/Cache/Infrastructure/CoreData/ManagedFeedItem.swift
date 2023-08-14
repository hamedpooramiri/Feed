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
    var local: LocalFeedItem {
        return LocalFeedItem(id: id, description: itemDescription, location: location, imageUrl: url)
        }
}
