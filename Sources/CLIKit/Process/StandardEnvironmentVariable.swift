//
//  Copyright © 2018 Apparata AB. All rights reserved.
//

import Foundation

public enum StandardEnvironmentVariable: String {
    
    // User
    case user = "USER"
    
    // Paths
    case home = "HOME"
    case path = "PATH"
    case tmpDir = "TMPDIR"
    
    // Shell
    case shell = "SHELL"
    
    // Terminal
    case term = "TERM"
    case termProgram = "TERM_PROGRAM"
    
    // Locale
    case tz = "TZ"
    case lang = "LANG"
    case language = "LANGUAGE"
    case lcCType = "LC_CTYPE"
    case lcNumeric = "LC_NUMERIC"
    case lcTime = "LC_TIME"
    case lcCollate = "LC_COLLATE"
    case lcMonetary = "LC_MONETARY"
    case lcMessages = "LC_MESSAGES"
    case lcPaper = "LC_PAPER"
    case lcName = "LC_NAME"
    case lcAddress = "LC_ADDRESS"
    case lcTelephone = "LC_TELEPHONE"
    case lcMeasurement = "LC_MEASUREMENT"
    case lcIdentification = "LC_IDENTIFICATION"
    case lcAll = "LC_ALL"
}

