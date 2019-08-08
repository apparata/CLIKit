//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

extension UInt: CommandArgumentValue {
    
    public init(argumentValue: String) throws {
        guard let value = Self(argumentValue) else {
            throw CommandLineError.invalidArgumentValueFormat(argumentValue)
        }
        self = value
    }
}

extension UInt8: CommandArgumentValue {
    
    public init(argumentValue: String) throws {
        guard let value = Self(argumentValue) else {
            throw CommandLineError.invalidArgumentValueFormat(argumentValue)
        }
        self = value
    }
}

extension UInt16: CommandArgumentValue {
    
    public init(argumentValue: String) throws {
        guard let value = Self(argumentValue) else {
            throw CommandLineError.invalidArgumentValueFormat(argumentValue)
        }
        self = value
    }
}

extension UInt32: CommandArgumentValue {
    
    public init(argumentValue: String) throws {
        guard let value = Self(argumentValue) else {
            throw CommandLineError.invalidArgumentValueFormat(argumentValue)
        }
        self = value
    }
}

extension UInt64: CommandArgumentValue {
    
    public init(argumentValue: String) throws {
        guard let value = Self(argumentValue) else {
            throw CommandLineError.invalidArgumentValueFormat(argumentValue)
        }
        self = value
    }
}
