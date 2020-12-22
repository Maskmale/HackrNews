//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import HackrNews

final class MainQueueDispatchDecorator<T> {
    private let decoratee: T

    init(_ decoratee: T) {
        self.decoratee = decoratee
    }

    func dispatch(completion: @escaping () -> Void) {
        if Thread.isMainThread {
            completion()
        } else {
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}

extension MainQueueDispatchDecorator: LiveHackrNewsLoader where T == LiveHackrNewsLoader {
    func load(completion: @escaping (LiveHackrNewsLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: HackrStoryLoader where T == HackrStoryLoader {
    func load(from url: URL, completion: @escaping (HackrStoryLoader.Result) -> Void) -> HackrStoryLoaderTask {
        decoratee.load(from: url) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
