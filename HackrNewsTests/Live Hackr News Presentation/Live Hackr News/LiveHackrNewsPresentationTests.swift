//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

final class LiveHackrNewsPresentationTests: XCTestCase {
    func test_title_isLocalized() {
        XCTAssertEqual(LiveHackrNewsPresenter.title, localized("top_stories_title"))
    }

    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()

        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages upon creation")
    }

    func test_didStartLoadingStories_displaysLoaderWithNoErrorMessage() {
        let (sut, view) = makeSUT()

        sut.didStartLoadingNews()

        XCTAssertEqual(view.messages, [.display(isLoading: true), .display(errorMessage: .none)])
    }

    func test_didFinishLoadingStories_displayStoriesAndStopsLoading() {
        let (sut, view) = makeSUT()
        let new1 = LiveHackrNew(id: 1)
        let new2 = LiveHackrNew(id: 2)

        sut.didFinishLoadingNews(news: [new1, new2])

        XCTAssertEqual(view.messages, [.display(isLoading: false), .display(stories: [new1, new2])])
    }

    func test_didFinishLoadingStoriesWithError_displaysErrorAndStopsLoading() {
        let (sut, view) = makeSUT()

        sut.didFinishLoadingNews(with: anyNSError())

        XCTAssertEqual(view.messages, [.display(isLoading: false), .display(errorMessage: localized("new_stories_error_message"))])
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (LiveHackrNewsPresenter, NewStoriesViewSpy) {
        let view = NewStoriesViewSpy()
        let sut = LiveHackrNewsPresenter(view: view, loadingView: view, errorView: view)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(view, file: file, line: line)
        return (sut, view)
    }

    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "NewStories"
        let bundle = Bundle(for: LiveHackrNewsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if key == value {
            XCTFail("Missing localized string for key \(key) in table \(table)", file: file, line: line)
        }
        return value
    }

    private class NewStoriesViewSpy: LiveHackrNewsView, LiveHackrNewsLoadingView, LiveHackrNewsErrorView {
        var messages = [Message]()

        enum Message: Equatable {
            case display(isLoading: Bool)
            case display(errorMessage: String?)
            case display(stories: [LiveHackrNew])
        }

        func display(_ viewModel: LiveHackrNewsErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
        }

        func display(_ viewModel: LiveHackrNewsLoadingViewModel) {
            messages.append(.display(isLoading: viewModel.isLoading))
        }

        func display(_ viewModel: LiveHackrNewsViewModel) {
            messages.append(.display(stories: viewModel.stories))
        }
    }
}
