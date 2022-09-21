//
//  FeedView.swift
//  DemoFeature
//
//  Created by Tri Le on 8/15/22.
//

import SwiftUI

struct FeedView: View {
    @StateObject private var model = FeedViewModel()

    var body: some View {
        List(model.stories.indices) { index in
            if let story = model.stories[index] {
                Story(position: index + 1, item: story)
            }
        }
        .navigationTitle("Feed")
    }
}

// MARK: - Story
struct Story: View {
    let position: Int

    var body: some View {
        HStack(alignment: .top, spacing: 16.0) {
            Position(position: position)
        }
    }
}

extension Story {
    init(position: Int, item: FeedItem) {
        self.position = position
    }
}

struct Position: View {
    let position: Int

    var body: some View {
        ZStack {
            Circle()
                .frame(width: 32.0, height: 32.0)
                .foregroundColor(.teal)
            Text("\(position)")
                .font(.callout)
                .bold()
                .foregroundColor(.white)
        }
    }
}

struct Badge: View {
    let text: String
    let imageName: String

    var body: some View {
        HStack {
            Image(systemName: imageName)
            Text(text)
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
//            Story(position: 1, item: TestData.story)
            Position(position: 1)
            Badge(text: "1.234", imageName: "paperplane")
        }
        .previewLayout(.sizeThatFits)
    }
}
