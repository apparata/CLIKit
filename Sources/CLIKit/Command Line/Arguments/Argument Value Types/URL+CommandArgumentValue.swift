//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

extension URL: CommandArgumentValue {
    
    public init(argumentValue: String) throws {
        guard let value = Self(string: argumentValue) else {
            throw CommandLineError.invalidArgumentValueFormat(argumentValue)
        }
        self = value
    }
}
