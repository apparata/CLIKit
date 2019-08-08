//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

extension Double: CommandArgumentValue {
    
    public init(argumentValue: String) throws {
        guard let value = Self(argumentValue) else {
            throw CommandLineError.invalidArgumentValueFormat(argumentValue)
        }
        self = value
    }
}
