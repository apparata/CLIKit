//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

public protocol CommandArgumentValue: CustomStringConvertible {
    
    init(argumentValue: String) throws
}

public protocol OptionalCommandArgumentValue: ExpressibleByNilLiteral {
    
    init(argumentValue: String) throws
}

/// Allow Optional to implement CommandArgumentValue for wrapped types that
/// themselves implement CommandArgumentValue
extension Optional: OptionalCommandArgumentValue where Wrapped: CommandArgumentValue {

    public init(argumentValue: String) throws {
        self = .some(try Wrapped(argumentValue: argumentValue))
    }
}

/// Allow Optional to implement CustomStringConvertbile for wrapped types that
/// implement CommandArgumentValue
extension Optional: CustomStringConvertible where Wrapped: CommandArgumentValue {
    public var description: String {
        switch self {
        case .some(let value):
            return value.description
        default:
            return "nil"
        }
    }
}
