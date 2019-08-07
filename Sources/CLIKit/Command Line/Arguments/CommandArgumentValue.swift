//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

public protocol CommandArgumentValue: CustomStringConvertible {
    
    init(argumentValue: String) throws
}

extension String: CommandArgumentValue {
    
    public init(argumentValue: String) throws {
        self = argumentValue
    }
}

extension Int: CommandArgumentValue {
    
    public init(argumentValue: String) throws {
        guard let value = Int(argumentValue) else {
            throw CommandLineError.invalidArgumentValueFormat(argumentValue)
        }
        self = value
    }
}

extension Optional: CustomStringConvertible where Wrapped == Int {
    public var description: String {
        switch self {
        case .some(let value):
            return value.description
        default:
            return "nil"
        }
    }
}

extension Optional: CommandArgumentValue where Wrapped == Int {

    public init(argumentValue: String) throws {
        guard let value = Int(argumentValue) else {
            throw CommandLineError.invalidArgumentValueFormat(argumentValue)
        }
        self = .some(value)
    }
}

extension Int64: CommandArgumentValue {
    
    public init(argumentValue: String) throws {
        guard let value = Int64(argumentValue) else {
            throw CommandLineError.invalidArgumentValueFormat(argumentValue)
        }
        self = value
    }
}

extension Float: CommandArgumentValue {
    
    public init(argumentValue: String) throws {
        guard let value = Float(argumentValue) else {
            throw CommandLineError.invalidArgumentValueFormat(argumentValue)
        }
        self = value
    }
}

extension Double: CommandArgumentValue {
    
    public init(argumentValue: String) throws {
        guard let value = Double(argumentValue) else {
            throw CommandLineError.invalidArgumentValueFormat(argumentValue)
        }
        self = value
    }
}
