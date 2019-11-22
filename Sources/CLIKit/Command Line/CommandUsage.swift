//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

public final class CommandUsage {
    
    static public func formatUsage(for command: Command) -> String {
        
        let description = formatDescription(command: command)
        let commandLine = formatCommandLine(command: command)
        let subcommands = formatSubcommands(command: command)
        let flags = formatFlags(command: command)
        let options = formatOptions(command: command)
        let inputs = formatInputs(command: command)
        
        let usage = [
            description,
            commandLine,
            subcommands,
            flags,
            options,
            inputs,
        ].compactMap { $0 }
        
        return usage.joined(separator: "\n").trimmingWhitespace()
    }
    
    static private func formatDescription(command: Command) -> String? {
        return "OVERVIEW: \(command.description)\n"
    }
    
    static private func formatCommandLine(command: Command) -> String {
        
        var text: String = "USAGE: " + commandNameChain(command: command)
        
        if command is Commands {
            text += " [subcommand [arguments]]"
        } else {
            if command.flags.count > 0 {
                text += " [flags]"
            }
            if command.options.count > 0 {
                text += " [options]"
            }
            if command.inputs.count > 0 {
                text += " <inputs>"
            }
        }
        text += "\n"
        return text
    }
    
    static private func commandNameChain(command: Command) -> String {
        
        if let command = command as? InternalCommand {
            if command.parentCommands.isEmpty {
                return "\(command.name)"
            } else {
                let parents = command.parentCommands.joined(separator: " ")
                return "\(parents) \(command.name)"
            }
        } else {
            return "command"
        }
    }
    
    static private func formatSubcommands(command: Command) -> String? {
        guard let commands = (command as? InternalNamedCommands)?.internalCommands, commands.count > 0 else {
            return nil
        }
        var text = "SUBCOMMANDS:\n"
        
        for subcommand in commands {
            var row = "  \(subcommand.name)"
            row += calculatePadding(string: row)
            row += "\(subcommand.description)\n"
            text += row
        }
        
        return text
    }
    
    static private func formatFlags(command: Command) -> String? {
        var flags = (command as? InternalNamedCommand)?.namedFlags ?? command.namedFlags
        flags.insert(("help", HelpFlag()), at: 0)
        guard flags.count > 0 else {
            return nil
        }
                
        var text = "FLAGS:\n"
        
        for (name, flag) in flags.sorted(by: \.name) {
            var row = "  "
            if let short = flag.shortName {
                row += "-\(short), "
            }
            row += "--\(name)"
            row += calculatePadding(string: row)
            row += "\(flag.description)\n"
            text += row
        }
        
        return text
    }
    
    static private func formatOptions(command: Command) -> String? {
        let options = (command as? InternalNamedCommand)?.namedOptions ?? command.namedOptions
        guard options.count > 0 else {
            return nil
        }

        var text = "OPTIONS:\n"
        
        for (name, option) in options.sorted(by: \.name) {
            var row = "  "
            if let short = option.shortName {
                row += "-\(short), "
            }
            row += "--\(name) <\(option.valueName)>"
            row += calculatePadding(string: row)
            row += "\(option.description)"
            
            row += " Defaults to \"\(option.defaultValueString)\"."
            
            row += "\n"
            text += row
        }
        
        return text
    }

    static private func formatInputs(command: Command) -> String? {
        let inputs = (command as? InternalNamedCommand)?.namedInputs ?? command.namedInputs
        guard inputs.count > 0 else {
            return nil
        }

        var text = "INPUTS:\n"
        
        for (name, input) in inputs.sorted(by: \.name) {
            var row = "  "
            row += name
            row += calculatePadding(string: row)
            if input is ExpressibleByNilLiteral {
                row += "\(input.description) (OPTIONAL)\n"
            } else {
                row += "\(input.description)\n"
            }
            text += row
        }
        
        return text
    }
    
    static private func calculatePadding(string: String, columns: Int = 26) -> String {
        let length = string.count
        if length + 1 > columns {
            return "\n" + String(repeating: " ", count: columns)
        } else {
            return String(repeating: " ", count: columns - string.count)
        }
    }
}
