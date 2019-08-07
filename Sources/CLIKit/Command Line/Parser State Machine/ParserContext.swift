//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

class ParserContext {
    
    let topCommand: InternalCommand
    
    var currentCommand: InternalCommand {
        willSet {
            commandSequence.append(currentCommand)
        }
    }
    
    var commandSequence: [InternalCommand] = []
    
    var remainingInputs: [CommandInputSpecification] = []
    
    init(command: InternalCommand) {
        topCommand = command
        currentCommand = command
    }
}
