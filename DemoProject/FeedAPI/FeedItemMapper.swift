//
//  FeedItemMapper.swift
//  DemoFeature
//
//  Created by Tri Le on 8/26/22.
//

import Foundation

internal final class FeedItemsMapper {
    private struct Root: Decodable {
        let pagination: Pagination
        let items: [RemoteFeedItem]

        private enum CodingKeys: String, CodingKey {
            case pagination = "pagination"
            case items = "data"
        }
    }

    private static var OK_200: Int { return 200 }

    internal static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
                  throw RemoteFeedLoader.Error.invalidData
              }

        return root.items
    }
}
