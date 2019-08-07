//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

public enum CommandLineError: LocalizedError {
    
    case unexpectedError
    case invalidFlagOrOption(String)
    case unexpectedArgument(String)
    case missingOptionValue(String)
    case missingInputArgument(String)
    case invalidArgumentValueFormat(String)
    case requiredInputArgumentMustNotFollowOptionalInputArgument(command: String, input: String)
    case requiredInputArgumentMustNotFollowVariadicInputArgument(command: String, input: String)
    case multipleVariadicInputArguments(command: String)
    case bothOptionalAndVariadicInputArguments(command: String)
    case usageRequested(command: Command)
    case noSuchSubcommand(command: String)
    
    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        switch self {
        case .unexpectedError:
            return "Error: There was an unexpected error while parsing the command line."
        case .invalidFlagOrOption(let flagOrOption):
            return "Error: Invalid flag or option \"\(flagOrOption)\""
        case .unexpectedArgument(let argument):
            return "Error: Unexpected argument \"\(argument)\""
        case .missingOptionValue(let option):
            return "Error: Missing value for option \"\(option)\""
        case .missingInputArgument(let input):
            return "Error: Missing value for input argument \"\(input)\""
        case .invalidArgumentValueFormat(let value):
            return "Error: Incorrect format for argument \(value)"
        case .requiredInputArgumentMustNotFollowOptionalInputArgument(let command, let input):
            return "Error: The required input argument '\(input)' must not follow an optional input argument in \(command)'."
        case .requiredInputArgumentMustNotFollowVariadicInputArgument(let command, let input):
            return "Error: The required input argument '\(input)' must not follow a variadic input argument in \(command)'."
        case .multipleVariadicInputArguments(let command):
            return "Error: There must only be one variadic input argument in '\(command)'."
        case .bothOptionalAndVariadicInputArguments(let command):
            return "Error: The command '\(command)' may not have both optional and variadic input arguments."
        case .usageRequested(let command):
            return CommandUsage.formatUsage(for: command)
        case .noSuchSubcommand(let name):
            return "Error: There is no subcommand '\(name)'"
        }
    }
    
    /// A localized message describing the reason for the failure.
    public var failureReason: String? {
        return errorDescription
    }
}
