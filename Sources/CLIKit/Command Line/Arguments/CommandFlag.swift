//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

public protocol CommandFlagSpecification: CommandArgumentSpecification {
    var shortName: String? { get }
    
    func bindValue(_ value: Bool)
}

/// A flag is an argument, which when present, represents `true`.
/// A flag that is not present, represents `false`.
///
/// Example: `-v` or `--verbose`
///
@propertyWrapper
public class CommandFlag: CommandFlagSpecification {
    
    public let alternateName: String?
    public let shortName: String?
    public let description: String

    public private(set) var name: String?
    private var value: Bool = false
    
    public var wrappedValue: Bool {
        get {
            return value
        }
        set {
            value = newValue
        }
    }
    
    public init(name: String? = nil,
                short: String? = nil,
                description: String) {
        alternateName = name
        self.shortName = short
        self.description = description
    }
    
    public func bindValue(_ value: Bool) {
        wrappedValue = value
    }
    
    public func assignName(_ name: String) {
        self.name = name
    }
}
