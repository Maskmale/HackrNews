//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
@testable import HackrNewsApp
import HackrNewsiOS
import SafariServices
import XCTest

final class HackrNewsAppAcceptanceTests: XCTestCase {
    func test_onLaunch_displaysRemoteStoriesWhenCustomerHasConnectivity() {
        let stories = launch(httpClient: .online(response))

        XCTAssertEqual(stories.numberOfRenderedLiveHackrNewsViews(), 5)
        XCTAssertNotNil(stories.simulateStoryViewVisible(at: 0))
        XCTAssertNotNil(stories.simulateStoryViewVisible(at: 1))
    }

    func test_onLaunch_doesNotDisplayRemoteStoriesWhenCustomerHasNotConnectivity() {
        let stories = launch(httpClient: .offline)

        XCTAssertEqual(stories.numberOfRenderedLiveHackrNewsViews(), 0)
    }

    func test_onSelectStory_displaysStoryUrlInSafari() {
        let stories = launch(httpClient: .online(response))
        stories.simulateStoryViewVisible(at: 0)

        stories.simulateTapOnStory(at: 0)
        RunLoop.current.run(until: Date())

        let safariViewController = stories.navigationController?.presentedViewController
        XCTAssertTrue(safariViewController is SFSafariViewController)
    }

    // MARK: - Helpers

    private func launch(httpClient: HTTPClientStub = .offline) -> LiveHackrNewsViewController {
        let sut = SceneDelegate(httpClient: httpClient)
        sut.window = UIWindow()

        sut.configureWindow()

        let tabBarController = sut.window?.rootViewController as! UITabBarController
        let navigationController = tabBarController.viewControllers?.first as! UINavigationController
        let storiesViewController = navigationController.topViewController as! LiveHackrNewsViewController
        return storiesViewController
    }
}