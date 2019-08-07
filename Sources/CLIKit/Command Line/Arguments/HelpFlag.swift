//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

internal class HelpFlag: CommandFlagSpecification {
    
    let shortName: String? = "h"
    
    public let name: String? = "help"
    var value: Bool = true
    
    func bindValue(_ value: Bool) {
        // Always true anyway.
    }
    
    func assignName(_ name: String) {
        // Always named help
    }
    
    let description = "Displays help text."
}
