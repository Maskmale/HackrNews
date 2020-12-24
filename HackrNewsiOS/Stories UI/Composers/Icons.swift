//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import UIKit

public enum IconState {
    case normal
    case selected
}

public enum Icons {
    case news

    public func image(state: IconState) -> UIImage {
        switch (self, state) {
        case (.news, .normal):
            return UIImage(systemName: "newspaper")!
        case (.news, .selected):
            return UIImage(systemName: "newspaper.fill")!
        }
    }
}