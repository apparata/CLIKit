//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

public enum TerminalCode {

    public enum ClearScreen: Int {
        
        case clearScreen = 2
        case clearScreenFromCursor = 0
        case clearScreenToCursor = 1

        public var terminalCode: String {
            return "\u{001B}[\(self.rawValue)J"
        }
    }
    
    public enum ClearLine: Int {
        
        // Clear line
        case clearLine = 2
        case clearLineFromCursor = 0
        case clearLineToCursor = 1
        
        public var terminalCode: String {
            return "\u{001B}[\(self.rawValue)K"
        }
    }
    
    public enum TextStyle: Int {
        
        case reset = 0

        case bold = 1
        case boldOff = 22

        case italic = 3
        case italicOff = 23

        case underline = 4
        case underlineOff = 24

        case inverse = 7
        case inverseOff = 27

        case strikethrough = 9
        case strikethroughOff = 29
        
        case black = 30
        case red = 31
        case green = 32
        case yellow = 33
        case blue = 34
        case magenta = 35
        case cyan = 36
        case white = 37
        
        case brightBlack = 90
        case brightRed = 91
        case brightGreen = 92
        case brightYellow = 93
        case brightBlue = 94
        case brightMagenta = 95
        case brightCyan = 96
        case brightWhite = 97
    
        case blackBackground = 40
        case redBackground = 41
        case greenBackground = 42
        case yellowBackground = 43
        case blueBackground = 44
        case magentaBackground = 45
        case cyanBackground = 46
        case whiteBackground = 47

        case brightBlackBackground = 100
        case brightRedBackground = 101
        case brightGreenBackground = 102
        case brightYellowBackground = 103
        case brightBlueBackground = 104
        case brightMagentaBackground = 105
        case brightCyanBackground = 106
        case brightWhiteBackground = 107
                
        public var terminalCode: String {
            return "\u{001B}[\(self.rawValue)m"
        }
    }
    
    /// See https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit
    public enum ExtendedColor {
        
        case foreground(UInt8)
        case background(UInt8)
        
        public var terminalCode: String {
            switch self {
            case .foreground(let code):
                return "\u{001B}[38;5;\(code)m"
            case .background(let code):
                return "\u{001B}[48;5;\(code)m"
            }
        }
    }
}
