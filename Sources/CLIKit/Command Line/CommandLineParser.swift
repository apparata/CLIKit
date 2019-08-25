//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

public final class CommandLineParser {
    
    public init() {
        // Do nothing
    }
        
    /// Parse command line directly from the CommandLine.arguments array.
    public func parse(command: Command) throws -> Command {
        let (commandName, arguments) = try splitArguments(CommandLine.arguments)
        return try parseArguments(commandName: commandName,
                                  arguments: arguments,
                                  command: command)
    }
    
    /// Parse command line arguments.
    ///
    /// - parameter arguments: Arguments, including the root command argument.
    public func parseArguments(_ argumentsIncludingRootCommand: [String],
                               command: Command,
                               expectedRootCommand: String) throws -> Command {
        
        let (commandName, arguments) = try splitArguments(argumentsIncludingRootCommand)
        guard commandName == expectedRootCommand else {
            if let commands = command as? Commands {
                let namedCommand = InternalNamedCommands(name: expectedRootCommand,
                                                         commands: commands)
                throw CommandLineError.usageRequested(command: namedCommand)
            } else {
                let namedCommand = InternalNamedCommand(name: expectedRootCommand,
                                                        command: command)
                throw CommandLineError.usageRequested(command: namedCommand)
            }
        }
        return try parseArguments(commandName: commandName,
                                  arguments: arguments,
                                  command: command)
    }
    
    private func parseArguments(commandName: String,
                               arguments: [String],
                               command: Command) throws -> Command {
                
        try verifyCommandSpecification(command, name: commandName)
        
        assignArgumentsNames(command)
        
        let internalCommand = buildInternalCommand(command, commandName)
        
        let resultingState = runStateMachine(for: arguments, command: internalCommand)
        
        switch resultingState {
        case .success(let context):
            return context.currentCommand.originalCommand
        case .failure(let error):
            throw error
        default:
            throw CommandLineError.unexpectedError
        }
    }
    
    private func splitArguments(_ arguments: [String]) throws -> (String, [String]) {
        guard let executable = arguments.first else {
            throw CommandLineError.noExecutable
        }
        
        let path = Path(executable)
        
        let commandName = path.lastComponent
        
        guard commandName.count > 0 else {
            throw CommandLineError.noExecutable
        }
        
        let commandArguments = Array(arguments.dropFirst())

        return (commandName, commandArguments)

    }
    
    private func buildInternalCommand(_ command: Command, _ name: String, _ parents: [String] = []) -> InternalCommand {
        if let commands = command as? Commands {
            return InternalNamedCommands(name: name,
                                         commands: commands,
                                         parents: parents)
        } else {
            return InternalNamedCommand(name: name,
                                        command: command,
                                        parents: parents)
        }
    }
        
    private func verifyCommandSpecification(_ command: Command, name: String) throws {
        
        if let command = command as? Commands {
            let commands = command.namedCommands
            for (name, subcommand) in commands {
                try verifyCommandSpecification(subcommand, name: name)
            }
            return
        }
        
        let inputs = command.namedInputs
        var inputType: CommandInputType = .required
        func invalid(_ error: CommandLineError) throws { throw error }
        for (inputName, input) in inputs {
            switch (inputType, input.type) {
            case (.required, .required):
                break
            case (.required, .optional):
                inputType = .optional
            case (.required, .variadic):
                inputType = .variadic
            case (.optional, .required):
                try invalid(.requiredInputArgumentMustNotFollowOptionalInputArgument(command: name, input: inputName))
            case (.optional, .optional):
                break
            case (.optional, .variadic):
                try invalid(.bothOptionalAndVariadicInputArguments(command: name))
            case (.variadic, .required):
                try invalid(.requiredInputArgumentMustNotFollowVariadicInputArgument(command: name, input: inputName))
            case (.variadic, .optional):
                try invalid(.bothOptionalAndVariadicInputArguments(command: name))
            case (.variadic, .variadic):
                try invalid(.multipleVariadicInputArguments(command: name))
            }
        }
    }
    
    private func assignArgumentsNames(_ command: Command) {
        if let command = command as? Commands {
            let commands = command.commands
            for subcommand in commands {
                assignArgumentsNames(subcommand)
            }
            return
        }        
        command.assignArgumentsNames()
    }
    
    private func runStateMachine(for arguments: [String], command: InternalCommand) -> ParserState {

        let context = ParserContext(command: command)
        
        context.remainingInputs = command.inputs

        let stateMachine = ParserStateMachine(context: context)
        stateMachine.delegate = self

        var args = arguments
        
        while stateMachine.isNotInEndState {
            
            if args.isEmpty {
                stateMachine.fireEvent(.noMoreArguments, nil)
            } else {
                let argument = args.removeFirst()
                processArgument(argument, stateMachine)
            }
        }

        return stateMachine.state
    }
    
    private struct StateError: Error {
        let event: ParserEvent
        let argument: String
        
        init(_ event: ParserEvent, _ argument: String) {
            self.event = event
            self.argument = argument
        }
    }
    
    private func processArgument(_ argument: String, _ stateMachine: ParserStateMachine) {
        
        let context = stateMachine.context
        
        do {
        
            switch stateMachine.state {
                
            case .command:
                if isFlagOrOption(argument) {
                    if let flag = try getFlag(correspondingTo: argument, command: context.currentCommand) {
                        stateMachine.fireEvent(.scannedFlag(flag), argument)
                    } else if let option = getOption(correspondingTo: argument, command: context.currentCommand) {
                        stateMachine.fireEvent(.scannedOption(option), argument)
                    } else {
                        throw StateError(.scannedInvalidFlagOrOption, argument)
                    }
                } else if let subcommand = getSubcommand(correspondingTo: argument, command: context.currentCommand) {
                    stateMachine.fireEvent(.scannedSubcommand(subcommand), argument)
                } else if let input = context.remainingInputs.first {
                    stateMachine.fireEvent(.scannedInput(input, argument), argument)
                    if context.remainingInputs.count != 1 || input.type != .variadic {
                        context.remainingInputs.removeFirst()
                    }
                } else {
                    throw StateError(.scannedUnexpectedArgument, argument)
                }
                
            case .parsedSubcommand(_):
                if isFlagOrOption(argument) {
                    if let flag = try getFlag(correspondingTo: argument, command: context.currentCommand) {
                        stateMachine.fireEvent(.scannedFlag(flag), argument)
                    } else if let option = getOption(correspondingTo: argument, command: context.currentCommand) {
                        stateMachine.fireEvent(.scannedOption(option), argument)
                    } else {
                        throw StateError(.scannedInvalidFlagOrOption, argument)
                    }
                } else if let subcommand = getSubcommand(correspondingTo: argument, command: context.currentCommand) {
                    stateMachine.fireEvent(.scannedSubcommand(subcommand), argument)
                } else if let input = context.remainingInputs.first {
                    stateMachine.fireEvent(.scannedInput(input, argument), argument)
                    if context.remainingInputs.count != 1 || input.type != .variadic {
                        context.remainingInputs.removeFirst()
                    }
                } else {
                    throw StateError(.scannedUnexpectedArgument, argument)
                }
                
            case .parsedFlag(_), .parsedOptionValue(_, _):
                if isFlagOrOption(argument) {
                    if let flag = try getFlag(correspondingTo: argument, command: context.currentCommand) {
                        stateMachine.fireEvent(.scannedFlag(flag), argument)
                    } else if let option = getOption(correspondingTo: argument, command: context.currentCommand) {
                        stateMachine.fireEvent(.scannedOption(option), argument)
                    } else {
                        stateMachine.fireEvent(.scannedInvalidFlagOrOption, argument)
                    }
                } else if let input = context.remainingInputs.first {
                    stateMachine.fireEvent(.scannedInput(input, argument), argument)
                    if context.remainingInputs.count != 1 || input.type != .variadic {
                        context.remainingInputs.removeFirst()
                    }
                } else {
                    throw StateError(.scannedUnexpectedArgument, argument)
                }
                
            case .parsedOption(let parsedOption):
                if isFlagOrOption(argument) {
                    throw StateError(.scannedUnexpectedArgument, argument)
                } else {
                    stateMachine.fireEvent(.scannedOptionValue(parsedOption, argument), argument)
                }

            case .parsedInput(_, _):
                if isFlagOrOption(argument) {
                    throw StateError(.scannedUnexpectedArgument, argument)
                } else if let input = context.remainingInputs.first {
                    stateMachine.fireEvent(.scannedInput(input, argument), argument)
                    if context.remainingInputs.count != 1 || input.type != .variadic {
                        context.remainingInputs.removeFirst()
                    }
                } else {
                    throw StateError(.scannedUnexpectedArgument, argument)
                }

            default:
                throw StateError(.scannedUnexpectedArgument, argument)
            }
            
        } catch let error as StateError {
            stateMachine.fireEvent(error.event, error.argument)
        } catch {
            dump(error)
        }
    }

    private func isFlagOrOption(_ string: String) -> Bool {
        return string.starts(with: "-") || string.starts(with: "--")
    }
    
    private func getSubcommand(correspondingTo commandName: String, command: InternalCommand) -> InternalCommand? {
        return (command as? InternalCommands)?[commandName] as? InternalCommand
    }
    
    private func getFlag(correspondingTo argument: String, command: InternalCommand) throws -> CommandFlagSpecification? {
        guard !(command is Commands) else {
            return nil
        }
        
        // Special treatment of the -h / --help flag.
        if argument == "--help" || argument == "-h" {
            throw StateError(.scannedHelpFlag(command), argument)
        }
        
        let mirror = Mirror(reflecting: command.originalCommand)
        for child in mirror.children {
            if let flag = child.value as? CommandFlagSpecification,
                let flagName = child.label?.trimmedPropertyName {
                
                if "--\(flagName)" == argument {
                    return flag
                } else if let shortName = flag.shortName, "-\(shortName)" == argument {
                    return flag
                }
            }
        }
        
        return nil
    }
    
    private func getOption(correspondingTo argument: String, command: InternalCommand) -> CommandOptionSpecification? {
        guard !(command is Commands) else {
            return nil
        }
        
        let mirror = Mirror(reflecting: command.originalCommand)
        for child in mirror.children {
            if let option = child.value as? CommandOptionSpecification,
                let optionName = child.label?.trimmedPropertyName {
                if "--\(optionName)" == argument {
                    return option
                } else if let shortName = option.shortName, "-\(shortName)" == argument {
                    return option
                }
            }
        }
        
        return nil
    }
    
    private func evaluateExitState(_ context: ParserContext) -> ParserState {
        if let remainingInput = context.remainingInputs.first, remainingInput.type == .required {
            return ParserState.failure(CommandLineError.missingInputArgument(remainingInput.name ?? "unknown"))
        }
        return .success(context)
    }
}


extension CommandLineParser: ParserStateMachineDelegate {
    
    func stateToTransitionTo(from state: ParserState, dueTo event: ParserEvent, argument: String?, context: ParserContext, stateMachine: ParserStateMachine) -> ParserState? {
        
        switch (state, event) {
            
        case (_, .errorWasThrown(let error)):
            return .failure(error)
        
        case (.command, .noMoreArguments):
            return evaluateExitState(context)
        case (.command, .scannedSubcommand(let subcommand)):
            return .parsedSubcommand(subcommand)
        case (.command, .scannedFlag(let flag)):
            return .parsedFlag(flag)
        case (.command, .scannedOption(let option)):
            return .parsedOption(option)
        case (.command, .scannedInput(let input, let value)):
            return .parsedInput(input, value)
        case (.command, .scannedInvalidFlagOrOption):
            return .failure(argument.map { .invalidFlagOrOption($0) } ?? .unexpectedError)
        case (.command, .scannedHelpFlag(let subcommand)):
            return .failure(.usageRequested(command: subcommand))
        case (.command, _):
            return .failure(argument.map { .unexpectedArgument($0) } ?? .unexpectedError)

        case (.parsedSubcommand(_), .noMoreArguments):
            return evaluateExitState(context)
        case (.parsedSubcommand(_), .scannedSubcommand(let subcommand)):
            return .parsedSubcommand(subcommand)
        case (.parsedSubcommand(_), .scannedFlag(let flag)):
            return .parsedFlag(flag)
        case (.parsedSubcommand(_), .scannedOption(let option)):
            return .parsedOption(option)
        case (.parsedSubcommand(_), .scannedInput(let input, let value)):
            return .parsedInput(input, value)
        case (.parsedSubcommand(_), .scannedInvalidFlagOrOption):
            return .failure(argument.map { .invalidFlagOrOption($0) } ?? .unexpectedError)
        case (.parsedSubcommand(_), .scannedHelpFlag(let subcommand)):
            return .failure(.usageRequested(command: subcommand))
        case (.parsedSubcommand(_), _):
            return .failure(argument.map { .unexpectedArgument($0) } ?? .unexpectedError)

        case (.parsedFlag(_), .noMoreArguments):
            return evaluateExitState(context)
        case (.parsedFlag(_), .scannedFlag(let flag)):
            return .parsedFlag(flag)
        case (.parsedFlag(_), .scannedOption(let option)):
            return .parsedOption(option)
        case (.parsedFlag(_), .scannedInput(let input, let value)):
            return .parsedInput(input, value)
        case (.parsedFlag(_), .scannedInvalidFlagOrOption):
            return .failure(argument.map { .invalidFlagOrOption($0) } ?? .unexpectedError)
        case (.parsedFlag(_), .scannedHelpFlag(let subcommand)):
            return .failure(.usageRequested(command: subcommand))
        case (.parsedFlag(_), _):
            return .failure(argument.map { .unexpectedArgument($0) } ?? .unexpectedError)

        case (.parsedOption(_), .scannedOptionValue(let option, let value)):
            return .parsedOptionValue(option, value)
        case (.parsedOption(let option), _):
            return .failure(.missingOptionValue(option.name ?? "N/A"))

        case (.parsedOptionValue(_), .noMoreArguments):
            return evaluateExitState(context)
        case (.parsedOptionValue(_), .scannedFlag(let flag)):
            return .parsedFlag(flag)
        case (.parsedOptionValue(_), .scannedOption(let option)):
            return .parsedOption(option)
        case (.parsedOptionValue(_), .scannedInput(let input, let value)):
            return .parsedInput(input, value)
        case (.parsedOptionValue(_), .scannedInvalidFlagOrOption):
            return .failure(argument.map { .invalidFlagOrOption($0) } ?? .unexpectedError)
        case (.parsedOptionValue(_), .scannedHelpFlag(let subcommand)):
            return .failure(.usageRequested(command: subcommand))
        case (.parsedOptionValue(_), _):
            return .failure(argument.map { .unexpectedArgument($0) } ?? .unexpectedError)

        case (.parsedInput(_), .noMoreArguments):
            return evaluateExitState(context)
        case (.parsedInput(_), .scannedInput(let input, let value)):
            return .parsedInput(input, value)
        case (.parsedInput(_), _):
            return .failure(argument.map { .unexpectedArgument($0) } ?? .unexpectedError)
            
        default:
            return .failure(.unexpectedError)
        }
        
    }
    
    func willTransition(from state: ParserState, to newState: ParserState, dueTo event: ParserEvent, argument: String?, context: ParserContext, stateMachine: ParserStateMachine) {
        
    }
    
    func didTransition(from state: ParserState, to newState: ParserState, dueTo event: ParserEvent, argument: String?, context: ParserContext, stateMachine: ParserStateMachine) {
        
        do {
            switch newState {
                
            case .parsedSubcommand(let command):
                context.currentCommand = command
                context.remainingInputs = command.inputs
                                
            case .parsedFlag(let parsedFlag):
                parsedFlag.bindValue(true)
                
            case .parsedOptionValue(let parsedOption, let value):
                if let pattern = parsedOption.validationRegex,
                    !Regex(pattern).isMatch(value) {
                    // TODO: We really should return the name of the option as well.
                    throw CommandLineError.invalidArgumentValueFormat(value)
                }
                try parsedOption.bindValue(value)
                
            case .parsedInput(let parsedInput, let value):
                if let pattern = parsedInput.validationRegex,
                    !Regex(pattern).isMatch(value) {
                    // TODO: We really should return the name of the input as well
                    throw CommandLineError.invalidArgumentValueFormat(value)
                }
                try parsedInput.bindValue(value)
                
            default:
                break
            }
        } catch let error as CommandLineError {
            stateMachine.fireEvent(.errorWasThrown(error), argument)
        } catch {
            stateMachine.fireEvent(.scannedUnexpectedArgument, argument)
        }
    }
}
