//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

public protocol CommandArgumentSpecification: CustomStringConvertible, AnyObject {
    var description: String { get }
    var name: String? { get }
    func assignName(_ name: String)
}
