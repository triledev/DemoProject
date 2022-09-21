//
//  SharedTestHelpers.swift
//  DemoFeatureTests
//
//  Created by Tri Le on 8/31/22.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}
