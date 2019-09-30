//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation
import CLIKit

class BuildCommand: Command {
    
    let description = "Request a build"
    
    @CommandRequiredInput(description: "branch")
    var branch: String
    
    var action: ((BuildCommand) -> Void)?
        
    func run() {
        print("Requested a build for branch!")
        action?(self)
    }
}

class ListBranchesCommand: Command {

    let description = "List branches"

    var action: ((ListBranchesCommand) -> Void)?

    func run() {
        print("Requested a branch list")
        action?(self)
    }
}


class BranchCommand: Commands {

    let description = "Branch commands"

    let list = ListBranchesCommand()
}

class BotCommands: Commands {
    
    let description = "BuildBot commands"
    
    let build = BuildCommand()
    let branch = BranchCommand()
}
