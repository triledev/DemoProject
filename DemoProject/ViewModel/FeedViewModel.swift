//
//  FeedViewModel.swift
//  DemoFeature
//
//  Created by Tri Le on 8/17/22.
//

import Foundation

class FeedViewModel: ObservableObject {
    @Published var stories: [FeedItem?] = Array(repeating: nil, count: 10)

    func fetchStory(withID id: Int, completion: @escaping (FeedItem?) -> Void) {
    }
}
