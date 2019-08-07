//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

internal extension String {
        
    var trimmedPropertyName: String {
        trimmingCharacters(in: CharacterSet(charactersIn: "_"))
    }
    
    func trimmingWhitespace() -> String {
        trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}
