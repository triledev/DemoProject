//
//  RemoteFeedItem.swift
//  DemoFeature
//
//  Created by Tri Le on 8/26/22.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    internal let author: String?
    internal let title: String?
    internal let description: String?
    internal let url: URL?
    internal let source: String?
    internal let imageURL: URL?
    internal let category: String?
    internal let language: String?
    internal let country: String?
    internal let publishedAt: String?

    private enum CodingKeys: String, CodingKey {
        case author = "author"
        case title = "title"
        case description = "description"
        case url = "url"
        case source = "source"
        case imageURL = "image"
        case category = "category"
        case language = "language"
        case country = "country"
        case publishedAt = "published_at"
    }
}
