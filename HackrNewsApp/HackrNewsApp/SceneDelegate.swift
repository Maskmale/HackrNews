//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import HackrNewsiOS
import SafariServices
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private let baseUrl = LHNEndpoint.baseUrl

    private lazy var navigationController: UINavigationController = {
        UINavigationController(rootViewController: makeLiveHackrNewsController())
    }()

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        configureWindow()
    }

    func configureWindow() {
        let tabBarController = makeTabBarViewController(with: [navigationController])
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }

    func makeRemoteClient() -> HTTPClient {
        URLSessionHTTPClient(session: URLSession(configuration: .default))
    }

    private func makeTabBarViewController(with controllers: [UIViewController]) -> UITabBarController {
        let tabBarController = UITabBarController()
        tabBarController.tabBar.tintColor = UIColor.systemRed
        tabBarController.viewControllers = controllers
        return tabBarController
    }

    private func makeLiveHackrNewsController() -> LiveHackrNewsViewController {
        let httpClient = makeRemoteClient()
        let liveHackrNewsloader = RemoteLiveHackrNewsLoader(url: LHNEndpoint.topStories.url(baseUrl), client: httpClient)
        let hackrStoryLoader = RemoteHackrStoryLoader(client: httpClient)
        return LiveHackrNewsUIComposer.composeWith(
            liveHackrNewsloader: liveHackrNewsloader,
            hackrStoryLoader: hackrStoryLoader,
            didSelectStory: openOnSafari
        )
    }

    private func openOnSafari(with url: URL) {
        let controller = SFSafariViewController(url: url)
        controller.preferredControlTintColor = .systemRed
        navigationController.present(controller, animated: true)
    }
}
