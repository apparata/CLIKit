//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

/// Array arguments can be constructed from strings on the form:
/// ```
/// value1,value2,...
/// ```
extension Array: CommandArgumentValue where Element: CommandArgumentValue {
    
    public init(argumentValue: String) throws {
        self = try argumentValue.split(separator: ",").map {
            try Element.init(argumentValue: String($0))
        }
    }
}
