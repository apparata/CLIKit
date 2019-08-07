//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

enum ParserState {
    case command
    case parsedSubcommand(InternalCommand)
    case parsedFlag(CommandFlagSpecification)
    case parsedOption(CommandOptionSpecification)
    case parsedOptionValue(CommandOptionSpecification, String)
    case parsedInput(CommandInputSpecification, String)
    case failure(CommandLineError)
    case success(ParserContext)
}
