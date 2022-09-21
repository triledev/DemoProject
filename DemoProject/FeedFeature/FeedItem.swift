//
//  FeedItem.swift
//  DemoFeature
//
//  Created by Tri Le on 8/15/22.
//

import Foundation

public struct Feed: Equatable {
    public let pagination: Pagination
    public let data: [FeedItem]

    public init(
        pagination: Pagination,
        data: [FeedItem]
    ) {
        self.pagination = pagination
        self.data = data
    }
}

public struct Pagination: Equatable {
    public let limit: Int
    public let offset: Int
    public let count: Int
    public let total: Int

    public init(
        limit: Int,
        offset: Int,
        count: Int,
        total: Int
    ) {
        self.limit = limit
        self.offset = offset
        self.count = count
        self.total = total
    }
}

public struct FeedItem: Equatable {
    public let author: String?
    public let title: String?
    public let description: String?
    public let url: URL?
    public let source: String?
    public let imageURL: URL?
    public let category: String?
    public let language: String?
    public let country: String?
    public let publishedAt: String?

    public init(
        author: String?,
        title: String?,
        description: String?,
        url: URL?,
        source: String?,
        imageURL: URL?,
        category: String?,
        language: String?,
        country: String?,
        publishedAt: String?
    ) {
        self.author = author
        self.title = title
        self.description = description
        self.url = url
        self.source = source
        self.imageURL = imageURL
        self.category = category
        self.language = language
        self.country = country
        self.publishedAt = publishedAt
    }
}

//extension Feed: Decodable {
//    private enum CodingKeys: String, CodingKey {
//        case pagination
//        case data
//    }
//}

extension Pagination: Decodable {
    private enum CodingKeys: String, CodingKey {
        case limit
        case offset
        case count
        case total
    }
}

//extension FeedItem: Decodable {
//    private enum CodingKeys: String, CodingKey {
//        case author
//        case title
//        case description
//        case url
//        case source
//        case imageURL = "image"
//        case category
//        case language
//        case country
//        case publishedAt = "published_at"
//    }
//}
