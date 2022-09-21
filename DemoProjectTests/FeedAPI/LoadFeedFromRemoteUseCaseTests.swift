//
//  LoadFeedFromRemoteUseCaseTests.swift
//  DemoFeatureTests
//
//  Created by Tri Le on 8/15/22.
//

import XCTest
import DemoProject

class LoadFeedFromRemoteUseCaseTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }
        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }
        sut.load { _ in }
        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: failure(.connetivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }

    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 404, 416, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }

    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let invalidJSON = Data(_: "invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }

    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .success([]), when: {
            let emptyListJSON = makeItemsJSON([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        })
    }

    // MARK: - Happy Path

    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()

        let item1 = makeItem(
                author: "Kerry Crowley",
                title: "Baseball comes full circle as SF Giants honor Buster Posey, the newest Little League coach",
                description: "The Giants are holding Buster Posey Day at Oracle Park on Saturday ahead of a game against the St. Louis Cardinals.",
                url: URL(string: "https://www.marinij.com/2022/05/05/baseball-comes-full-circle-as-sf-giants-honor-buster-posey-the-newest-little-league-coach/"),
                source: "marinij",
                imageURL: URL(string: "https://www.marinij.com/wp-content/uploads/2022/05/BNG-L-POSEY-1105-2.jpg?w=1400px&strip=all"),
                category: "general",
                language: "en",
                country: "us",
                publishedAt: "2022-05-05T18:45:32+00:00"
            )

        let item2 = makeItem(
                author: "Sammy Approved",
                title: "Happy Cinco De Mayo: Five Fast Facts About The Holiday Linked To African American History",
                description:"There is one part they don't teach you in the history books: How Cinco De Mayo is linked to African American history. Take a look at five fast facts about the holiday and how Africans are tied into it all.",
                url: URL(string: "https://globalgrind.com/5050249/happy-cinco-de-mayo-five-fast-facts-about-the-holiday-linked-to-african-american-history/"),
                source: "globalgrind",
                imageURL: URL(string: "https://globalgrind.com/wp-content/uploads/sites/16/2021/05/1620247208824.jpg?quality=80&strip=all&w=560&crop=0,0,100,320px"),
                category: "general",
                language: "en",
                country: "us",
                publishedAt: "2022-05-05T18:43:36+00:00"
            )

        let items = [item1.model, item2.model]

        expect(sut, toCompleteWith: .success(items), when: {
            // Another way of creating test json data
            // let json = feedJSON.data(using: .utf8)!

            let json = makeItemsJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        })
    }

    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "http://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)

        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load { capturedResults.append($0) }

        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        XCTAssertTrue(capturedResults.isEmpty)
    }

    // MARK: - Helpers

    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(client)
        return (sut, client)
    }

    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
    }

    private func makeItem(
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
    ) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(author: author, title: title, description: description, url: url, source: source, imageURL: imageURL, category: category, language: language, country: country, publishedAt: publishedAt)
        let json = [
            "author": author,
            "title": title,
            "description": description,
            "url": url?.absoluteString,
            "source": source,
            "image": imageURL?.absoluteString,
            "category": category,
            "language": language,
            "country": country,
            "published_at": publishedAt
        ].reduce(into: [String: Any]()) { (acc, e) in
            if let value = e.value { acc[e.key] = value }
        }
        return (item, json)
    }

    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let pagination = Pagination(limit: 25, offset: 0, count: 25, total: 10000)
        let paginationJSON = [
            "limit": pagination.limit,
            "offset": pagination.offset,
            "count": pagination.count,
            "total": pagination.total
        ]
        let json: [String: Any] = [
            "pagination": paginationJSON,
            "data": items
        ]
        return try! JSONSerialization.data(withJSONObject: json)
    }

    private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")

        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)

            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }

    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()

        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }

        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }

        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }

        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success(data, response))
        }
    }

    let feedJSON = """
    {
        "pagination":{
            "limit":25,
            "offset":0,
            "count":25,
            "total":10000
        },
        "data":[
            {
                "author":"Kerry Crowley",
                "title":"Baseball comes full circle as SF Giants honor Buster Posey, the newest Little League coach",
                "description":"The Giants are holding Buster Posey Day at Oracle Park on Saturday ahead of a game against the St. Louis Cardinals.",
                "url":"https://www.marinij.com/2022/05/05/baseball-comes-full-circle-as-sf-giants-honor-buster-posey-the-newest-little-league-coach/",
                "source":"marinij",
                "image":"https://www.marinij.com/wp-content/uploads/2022/05/BNG-L-POSEY-1105-2.jpg?w=1400px&strip=all",
                "category":"general",
                "language":"en",
                "country":"us",
                "published_at":"2022-05-05T18:45:32+00:00"
            },
            {
                "author":"Sammy Approved",
                "title":"Happy Cinco De Mayo: Five Fast Facts About The Holiday Linked To African American History",
                "description":"There is one part they don't teach you in the history books: How Cinco De Mayo is linked to African American history. Take a look at five fast facts about the holiday and how Africans are tied into it all.",
                "url":"https://globalgrind.com/5050249/happy-cinco-de-mayo-five-fast-facts-about-the-holiday-linked-to-african-american-history/",
                "source":"globalgrind",
                "image":"https://globalgrind.com/wp-content/uploads/sites/16/2021/05/1620247208824.jpg?quality=80&strip=all&w=560&crop=0,0,100,320px",
                "category":"general",
                "language":"en",
                "country":"us",
                "published_at":"2022-05-05T18:43:36+00:00"
            }
        ]
    }
    """
}
