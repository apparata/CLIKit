//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

/// Dictionary arguments can be constructed from strings on the form:
/// ```
/// key1=value1,key2=value2,...
/// ```
extension Dictionary: CommandArgumentValue where Key: CommandArgumentValue, Value: CommandArgumentValue {
    
    public init(argumentValue: String) throws {
        var dictionary: [Key: Value] = [:]
        let parts = argumentValue.split(separator: ",")
        for part in parts {
            let keyAndValue = part.split(separator: "=")
            guard keyAndValue.count == 2 else {
                throw CommandLineError.invalidArgumentValueFormat(argumentValue)
            }
            let key = try Key(argumentValue: String(keyAndValue[0]))
            let value = try Value(argumentValue: String(keyAndValue[1]))
            dictionary[key] = value
        }
        self = dictionary
    }
}
