//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

public protocol Command: AnyObject, CustomStringConvertible {
        
    var inputs: [CommandInputSpecification] { get }
    
    func run() throws
}

public protocol Commands: Command {
    
    subscript(name: String) -> Command? { get }
}

public extension Command {
    
    var flags: [CommandFlagSpecification] {
        commandProperties()
    }
    
    var namedFlags: [(name: String, flag: CommandFlagSpecification)] {
        namedCommandProperties()
    }
    
    var options: [CommandInputSpecification] {
        commandProperties()
    }
    
    var namedOptions: [(name: String, option: CommandOptionSpecification)] {
        namedCommandProperties()
    }
    
    var inputs: [CommandInputSpecification] {
        commandProperties()
    }
    
    var namedInputs: [(name: String, input: CommandInputSpecification)] {
        namedCommandProperties()
    }
    
    internal func namedCommandProperty<T>(name: String) -> T? {
        for child in Mirror(reflecting: self).children {
            if let subcommand = child.value as? T {
                if child.label?.trimmedPropertyName == name {
                    return subcommand
                }
            }
        }
        
        return nil
    }
    
    internal func commandProperties<T>() -> [T] {
        return Mirror(reflecting: self).children.compactMap {
            $0.value as? T
        }
    }
    
    internal func namedCommandProperties<T>() -> [(name: String, T)] {
        return Mirror(reflecting: self).children.compactMap {
            guard let name = $0.label?.trimmedPropertyName,
                let property = $0.value as? T else {
                return nil
            }
            return (name, property)
        }.sorted(by: \.name)
    }
    
    internal func assignArgumentsNames() {
        for child in Mirror(reflecting: self).children {
            guard let name = child.label?.trimmedPropertyName,
                let property = child.value as? CommandArgumentSpecification else {
                continue
            }
            property.assignName(name)
        }
    }
}

public extension Commands {
    
    subscript(name: String) -> Command? {
        namedCommandProperty(name: name)
    }
    
    var commands: [Command] {
        commandProperties()
    }
    
    var namedCommands: [(name: String, command: Command)] {
        namedCommandProperties()
    }
    
    var flags: [CommandFlagSpecification] {
        []
    }

    var namedFlags: [(name: String, flag: CommandFlagSpecification)] {
        []
    }
    
    var options: [CommandFlagSpecification] {
        []
    }
    
    var namedOptions: [(name: String, option: CommandOptionSpecification)] {
        []
    }

    var inputs: [CommandInputSpecification] {
        []
    }
    
    var namedInputs: [(name: String, input: CommandInputSpecification)] {
        []
    }
        
    func run() throws {
    }
}

internal protocol InternalCommand: Command {
    var name: String { get }
    var originalCommand: Command { get }
    var parentCommands: [String] { get }
}

internal class InternalNamedCommand: InternalCommand, Command {
    let name: String
    let originalCommand: Command
    var parentCommands: [String]
    
    init(name: String, command: Command, parents: [String] = []) {
        self.name = name
        originalCommand = command
        parentCommands = parents
    }

    var description: String {
        originalCommand.description
    }
        
    func run() throws {
        try originalCommand.run()
    }
    
    var flags: [CommandFlagSpecification] {
        originalCommand.flags
    }
    
    var namedFlags: [(name: String, flag: CommandFlagSpecification)] {
        originalCommand.namedFlags
    }
    
    var options: [CommandInputSpecification] {
        originalCommand.options
    }
    
    var namedOptions: [(name: String, option: CommandOptionSpecification)] {
        originalCommand.namedOptions
    }
    
    var inputs: [CommandInputSpecification] {
        originalCommand.inputs
    }
    
    var namedInputs: [(name: String, input: CommandInputSpecification)] {
        originalCommand.namedInputs
    }
    
    internal func namedCommandProperty<T>(name: String) -> T? {
        originalCommand.namedCommandProperty(name: name)
    }
    
    internal func commandProperties<T>() -> [T] {
        originalCommand.commandProperties()
    }
    
    internal func namedCommandProperties<T>() -> [(name: String, T)] {
        originalCommand.namedCommandProperties()
    }
    
    internal func assignArgumentsNames() {
        originalCommand.assignArgumentsNames()
    }
}

internal protocol InternalCommands: InternalCommand, Commands {
    var originalCommands: Commands { get }
}

internal class InternalNamedCommands: InternalCommands, Commands {
    
    let name: String
    let originalCommand: Command
    let originalCommands: Commands
    private(set) var internalCommands: [InternalCommand]
    var parentCommands: [String]
    
    init(name: String, commands: Commands, parents: [String] = []) {
        self.name = name
        originalCommand = commands
        originalCommands = commands
        parentCommands = parents
        internalCommands = []
        internalCommands = originalCommands.namedCommands.map {
            if let subcommands = $0.command as? Commands {
                return InternalNamedCommands(name: $0.name, commands: subcommands, parents: parents + [name])
            } else {
                return InternalNamedCommand(name: $0.name, command: $0.command, parents: parents + [name])
            }
        }
    }
    
    var description: String {
        originalCommands.description
    }
        
    func run() throws {
        try originalCommands.run()
    }
    
    subscript(name: String) -> Command? {
        internalCommands.first { $0.name == name }
    }
    
    var commands: [Command] {
        internalCommands
    }
    
    var namedCommands: [(name: String, command: Command)] {
        internalCommands.map {
            (name: $0.name, command: $0)
        }
    }
    
    var flags: [CommandFlagSpecification] {
        originalCommands.flags
    }

    var namedFlags: [(name: String, flag: CommandFlagSpecification)] {
        originalCommands.namedFlags
    }
    
    var options: [CommandFlagSpecification] {
        originalCommands.options
    }
    
    var namedOptions: [(name: String, option: CommandOptionSpecification)] {
        originalCommands.namedOptions
    }

    var inputs: [CommandInputSpecification] {
        originalCommands.inputs
    }
    
    var namedInputs: [(name: String, input: CommandInputSpecification)] {
        originalCommands.namedInputs
    }
}
