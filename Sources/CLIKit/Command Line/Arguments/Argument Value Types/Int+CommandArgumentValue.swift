//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

extension Int: CommandArgumentValue {
    
    public init(argumentValue: String) throws {
        guard let value = Self(argumentValue) else {
            throw CommandLineError.invalidArgumentValueFormat(argumentValue)
        }
        self = value
    }
}

extension Int8: CommandArgumentValue {
    
    public init(argumentValue: String) throws {
        guard let value = Self(argumentValue) else {
            throw CommandLineError.invalidArgumentValueFormat(argumentValue)
        }
        self = value
    }
}

extension Int16: CommandArgumentValue {
    
    public init(argumentValue: String) throws {
        guard let value = Self(argumentValue) else {
            throw CommandLineError.invalidArgumentValueFormat(argumentValue)
        }
        self = value
    }
}

extension Int32: CommandArgumentValue {
    
    public init(argumentValue: String) throws {
        guard let value = Self(argumentValue) else {
            throw CommandLineError.invalidArgumentValueFormat(argumentValue)
        }
        self = value
    }
}

extension Int64: CommandArgumentValue {
    
    public init(argumentValue: String) throws {
        guard let value = Self(argumentValue) else {
            throw CommandLineError.invalidArgumentValueFormat(argumentValue)
        }
        self = value
    }
}
