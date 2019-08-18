//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

public enum CommandInputType {
    case required
    case optional
    case variadic
}

public protocol CommandInputSpecification: CommandArgumentSpecification {
    var validationRegex: String? { get }
    var type: CommandInputType { get }
    
    func bindValue(_ argument: String) throws
}

/// An input argument is an argument that represents a file or similar.
/// If it's the last argument, it could optionally be variadic.
///
/// Example: `aFile.txt` or `file1.txt file2.txt file3.txt`
///
@propertyWrapper
public class CommandOptionalInput<Value: OptionalCommandArgumentValue>: CommandInputSpecification {
    
    public let validationRegex: String?
    public let description: String
    public let type: CommandInputType = .optional
    
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
    
    public init(regex: String? = nil,
                description: String) {
        validationRegex = regex
        self.description = description
        value = nil
    }
    
    public func bindValue(_ argument: String) throws {
        wrappedValue = try Value(argumentValue: argument)
    }
    
    public func assignName(_ name: String) {
        self.name = name
    }
}

@propertyWrapper
public class CommandRequiredInput<Value: CommandArgumentValue>: CommandInputSpecification {
    
    public let validationRegex: String?
    public let description: String
    public let type: CommandInputType = .required

    public private(set) var name: String?
    private var value: Value?
    
    public var wrappedValue: Value {
        get {
            return value!
        }
        set {
            value = newValue
        }
    }
    
    public init(regex: String? = nil,
                description: String) {
        validationRegex = regex
        self.description = description
        value = nil
    }
    
    public func bindValue(_ argument: String) throws {
        wrappedValue = try Value(argumentValue: argument)
    }
    
    public func assignName(_ name: String) {
        self.name = name
    }
}

@propertyWrapper
public class CommandVariadicInput<Value: CommandArgumentValue>: CommandInputSpecification {
    
    public let validationRegex: String?
    public let description: String
    public let type: CommandInputType = .variadic

    public private(set) var name: String?
    private var value: [Value]
    
    public var wrappedValue: [Value] {
        get {
            return value
        }
        set {
            value = newValue
        }
    }
    
    public init(regex: String? = nil,
                description: String) {
        validationRegex = regex
        self.description = description
        value = []
    }
    
    public func bindValue(_ argument: String) throws {
        value.append(try Value(argumentValue: argument))
    }
    
    public func assignName(_ name: String) {
        self.name = name
    }
}
