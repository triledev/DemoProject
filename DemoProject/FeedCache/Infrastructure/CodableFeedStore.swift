//
//  CodableFeedStore.swift
//  DemoFeature
//
//  Created by Tri Le on 9/8/22.
//

import Foundation

public final class CodableFeedStore: FeedStore {
    private struct Cache: Codable {
        let feed: [CodableFeedItem]
        let timestamp: Date

        var localFeed: [LocalFeedItem] {
            return feed.map { $0.local }
        }
    }

    private struct CodableFeedItem: Codable {
        private let author: String?
        private let title: String?
        private let description: String?
        private let url: URL?
        private let source: String?
        private let imageURL: URL?
        private let category: String?
        private let language: String?
        private let country: String?
        private let publishedAt: String?

        init(_ item: LocalFeedItem) {
            author = item.author
            title = item.title
            description = item.description
            url = item.url
            source = item.source
            imageURL = item.imageURL
            category = item.category
            language = item.language
            country = item.country
            publishedAt = item.publishedAt
        }

        var local: LocalFeedItem {
            return LocalFeedItem(author: author, title: title, description: description, url: url, source: source, imageURL: imageURL, category: category, language: language, country: country, publishedAt: publishedAt)
        }
    }

    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
    private let storeURL: URL

    public init(storeURL: URL) {
        self.storeURL = storeURL
    }

    public func retrieve(completion: @escaping RetrievalCompletion) {
        let storeURL = self.storeURL
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.empty)
            }

            do {
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func insert(_ feed: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            do {
                let encoder = JSONEncoder()
                let cache = Cache(feed: feed.map(CodableFeedItem.init), timestamp: timestamp)
                let encoded = try! encoder.encode(cache)
                try encoded.write(to: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return completion(nil)
            }

            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}
