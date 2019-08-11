//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

public protocol TextCompletion {
    func complete(input: String, index: Int) -> (String, Int)
}
