//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation
import CLIKit

class MainframeCommand: Command {
    
    let description = "Starts the server."
    
    @CommandOption(short: "p", default: 4040, regex: #"^\d+$"#, description: "Listening port.")
    var port: Int
    
    func run() {
        print("Port: \(port)")
    }
}
