//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

public protocol CommandOptionSpecification: CommandArgumentSpecification {
    var shortName: String? { get }
    var valueName: String { get }
    var defaultValueString: String { get }
    var validationRegex: String? { get }
    
    func bindValue(_ argument: String) throws
}

/// An option argument represents a named option and is used to pass a value
/// to the command. It could have a default value, or could be omitted.
///
/// Example: `-p 8` or `--passes 8`
///
@propertyWrapper
public class CommandOption<Value: CommandArgumentValue>: CommandOptionSpecification {
    
    public let shortName: String?
    public let valueName: String
    public let defaultValue: Value
    public let validationRegex: String?
    public let description: String
    
    public var defaultValueString: String {
        return defaultValue.description
    }

    public private(set) var name: String?
    private var value: Value
    
    public var wrappedValue: Value {
        get {
            return value
        }
        set {
            value = newValue
        }
    }
    
    public init(short: String? = nil,
                valueName: String = "value",
                default: Value,
                regex: String? = nil,
                description: String) {
        shortName = short
        self.valueName = valueName
        defaultValue = `default`
        validationRegex = regex
        self.description = description
        value = `default`
    }
    
    public func bindValue(_ argument: String) throws {
        wrappedValue = try Value(argumentValue: argument)
    }
    
    public func assignName(_ name: String) {
        self.name = name
    }
}
