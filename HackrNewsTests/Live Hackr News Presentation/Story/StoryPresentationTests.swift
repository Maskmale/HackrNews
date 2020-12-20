//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

final class StoryPresentationTests: XCTestCase {
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()

        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages upon creation")
    }

    func test_didStartLoadingStory_displaysLoaderAndHidesError() {
        let (sut, view) = makeSUT()
        let new = LiveHackrNew(id: anyID(), url: anyURL())

        sut.didStartLoadingStory(from: new)

        XCTAssertEqual(view.messages, [.display(isLoading: true), .display(
            id: new.id,
            title: nil,
            author: nil,
            comments: nil,
            date: nil
        ), .display(errorMessage: .none)])
    }

    func test_didFinishLoadingStory_displaysStoryAndStopsLoading() {
        let locale = Locale(identifier: "en_US_POSIX")
        let calendar = Calendar(identifier: .gregorian)
        let (sut, view) = makeSUT()
        sut.locale = locale
        sut.calendar = calendar
        let date = Date(timeIntervalSince1970: 754877453)
        let story = Story(
            id: 1,
            title: "a title",
            author: "an author",
            score: 1,
            createdAt: date,
            totalComments: 1,
            comments: [1],
            type: "story",
            url: anyURL()
        )

        sut.didStopLoadingStory(story: story)

        XCTAssertEqual(
            view.messages,
            [
                .display(isLoading: false),
                .display(id: story.id, title: story.title, author: story.author, comments: story.comments.count, date: "Dec 02, 1993"),
                .display(errorMessage: .none),
            ]
        )
    }

    // MARK: - Helpers

    private func makeSUT() -> (StoryPresenter, StoryViewSpy) {
        let view = StoryViewSpy()
        let sut = StoryPresenter(view: view, loadingView: view, errorView: view)
        return (sut, view)
    }

    private class StoryViewSpy: StoryView, StoryLoadingView, StoryErrorView {
        enum Message: Equatable {
            case display(isLoading: Bool)
            case display(id: Int, title: String?, author: String?, comments: Int?, date: String?)
            case display(errorMessage: String?)
        }

        private(set) var messages = [Message]()

        func display(_ viewModel: StoryViewModel) {
            messages
                .append(.display(
                    id: viewModel.newId,
                    title: viewModel.title,
                    author: viewModel.author,
                    comments: viewModel.comments,
                    date: viewModel.date
                ))
        }

        func display(_ viewModel: StoryLoadingViewModel) {
            messages.append(.display(isLoading: viewModel.isLoading))
        }

        func display(_ viewModel: StoryErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
        }
    }
}
