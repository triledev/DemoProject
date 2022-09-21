//
//  ManagedFeedImage.swift
//  DemoFeature
//
//  Created by Tri Le on 9/20/22.
//

import CoreData

@objc(ManagedFeedItem)
internal class ManagedFeedItem: NSManagedObject {
    @NSManaged var author: String?
    @NSManaged var title: String?
    @NSManaged var itemDescription: String?
    @NSManaged var url: URL?
    @NSManaged var source: String?
    @NSManaged var imageURL: URL?
    @NSManaged var category: String?
    @NSManaged var language: String?
    @NSManaged var country: String?
    @NSManaged var publishedAt: String?
    @NSManaged var cache: ManagedCache

    var local: LocalFeedItem {
        return LocalFeedItem(author: author, title: title, description: itemDescription, url: url, source: source, imageURL: imageURL, category: category, language: language, country: country, publishedAt: publishedAt)
    }
}

extension ManagedFeedItem {
    internal static func items(from localFeed: [LocalFeedItem], in context: NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(array: localFeed.map { local in
            let managed = ManagedFeedItem(context: context)
            managed.author = local.author
            managed.title = local.title
            managed.itemDescription = local.description
            managed.url = local.url
            managed.source = local.source
            managed.imageURL = local.imageURL
            managed.category = local.category
            managed.language = local.language
            managed.country = local.country
            managed.publishedAt = local.publishedAt
            return managed
        })
    }
}
