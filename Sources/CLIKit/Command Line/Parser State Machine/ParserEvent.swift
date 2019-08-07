//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

enum ParserEvent {
    case scannedSubcommand(InternalCommand)
    case scannedFlag(CommandFlagSpecification)
    case scannedOption(CommandOptionSpecification)
    case scannedOptionValue(CommandOptionSpecification, String)
    case scannedInput(CommandInputSpecification, String)
    case scannedInvalidFlagOrOption
    case scannedHelpFlag(InternalCommand)
    case scannedUnexpectedArgument
    case errorWasThrown(CommandLineError)
    case noMoreArguments
}
