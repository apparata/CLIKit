//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

public enum TerminalCode {

    // MARK: - Cursor
    
    case up(steps: Int)
    case down(steps: Int)
    case right(steps: Int)
    case left(steps: Int)
    
    /// Moves cursor to beginning of line `steps` lines down.
    case nextLine(steps: Int)
    
    /// Moves cursor to beginning of line `steps` lines up.
    case previousLine(steps: Int)
    
    /// Moves cursor to specified column.
    case setColumn(Int)
    
    /// Moves cursor to specified row and column.
    case setPosition(row: Int, column: Int)
    
    // Saves the current cursor position.
    case savePosition
    
    // Restores the cursor to the last saved position.
    case restorePosition
    
    case clearScreen
    case clearScreenFromCursor
    case clearScreenToCursor
    
    // MARK: - Clear Line
    
    case clearLine
    case clearLineFromCursor
    case clearLineToCursor
    
    // MARK: - Text Style
    
    case reset
    case bold
    case boldOff
    case italic
    case italicOff
    case underline
    case underlineOff
    case inverse
    case inverseOff
    case strikethrough
    case strikethroughOff
    
    // MARK: - Foreground Color
    
    case black
    case red
    case green
    case yellow
    case blue
    case magenta
    case cyan
    case white
        
    case brightBlack
    case brightRed
    case brightGreen
    case brightYellow
    case brightBlue
    case brightMagenta
    case brightCyan
    case brightWhite
    
    // MARK: - Background Color
    
    case blackBackground
    case redBackground
    case greenBackground
    case yellowBackground
    case blueBackground
    case magentaBackground
    case cyanBackground
    case whiteBackground

    case brightBlackBackground
    case brightRedBackground
    case brightGreenBackground
    case brightYellowBackground
    case brightBlueBackground
    case brightMagentaBackground
    case brightCyanBackground
    case brightWhiteBackground
    
    // MARK: - Extended Color
    
    case foreground(UInt8)
    case background(UInt8)
    
    // MARK: - Terminal Code String
    
    public var terminalCode: String {
        switch self {
        
        // -- Cursor --
            
        case .up(let steps): return "\u{001B}[\(steps)A"
        case .down(let steps): return "\u{001B}[\(steps)B"
        case .right(let steps): return "\u{001B}[\(steps)C"
        case .left(let steps): return "\u{001B}[\(steps)D"
        case .nextLine(let steps): return "\u{001B}[\(steps)E"
        case .previousLine(let steps): return "\u{001B}[\(steps)F"
        case .setColumn(let column): return "\u{001B}[\(column)G"
        case .setPosition(let row, let column): return "\u{001B}[\(row);\(column)H"
        case .savePosition: return "\u{001B}[s"
        case .restorePosition: return "\u{001B}[u"

        // -- Clear Screen --
        
        case .clearScreen: return "\u{001B}[2J"
        case .clearScreenFromCursor: return "\u{001B}[0J"
        case .clearScreenToCursor: return "\u{001B}[1J"

        // -- Clear Line --
        case .clearLine: return "\u{001B}[2K"
        case .clearLineFromCursor: return "\u{001B}[0K"
        case .clearLineToCursor: return "\u{001B}[1K"

        // -- Text Style --
            
        case .reset: return "\u{001B}[0m"
        case .bold: return "\u{001B}[1m"
        case .boldOff: return "\u{001B}[22m"
        case .italic: return "\u{001B}[3m"
        case .italicOff: return "\u{001B}[23m"
        case .underline: return "\u{001B}[4m"
        case .underlineOff: return "\u{001B}[24m"
        case .inverse: return "\u{001B}[7m"
        case .inverseOff: return "\u{001B}[27m"
        case .strikethrough: return "\u{001B}[9m"
        case .strikethroughOff: return "\u{001B}[29m"
        
        // -- Foreground Color --

        case .black: return "\u{001B}[30m"
        case .red: return "\u{001B}[31m"
        case .green: return "\u{001B}[32m"
        case .yellow: return "\u{001B}[33m"
        case .blue: return "\u{001B}[34m"
        case .magenta: return "\u{001B}[35m"
        case .cyan: return "\u{001B}[36m"
        case .white: return "\u{001B}[37m"
            
        case .brightBlack: return "\u{001B}[90m"
        case .brightRed: return "\u{001B}[91m"
        case .brightGreen: return "\u{001B}[92m"
        case .brightYellow: return "\u{001B}[93m"
        case .brightBlue: return "\u{001B}[94m"
        case .brightMagenta: return "\u{001B}[95m"
        case .brightCyan: return "\u{001B}[96m"
        case .brightWhite: return "\u{001B}[97m"
            
        // -- Background Color --

        case .blackBackground: return "\u{001B}[40m"
        case .redBackground: return "\u{001B}[41m"
        case .greenBackground: return "\u{001B}[42m"
        case .yellowBackground: return "\u{001B}[43m"
        case .blueBackground: return "\u{001B}[44m"
        case .magentaBackground: return "\u{001B}[45m"
        case .cyanBackground: return "\u{001B}[46m"
        case .whiteBackground: return "\u{001B}[47m"

        case .brightBlackBackground: return "\u{001B}[100m"
        case .brightRedBackground: return "\u{001B}[101m"
        case .brightGreenBackground: return "\u{001B}[102m"
        case .brightYellowBackground: return "\u{001B}[103m"
        case .brightBlueBackground: return "\u{001B}[104m"
        case .brightMagentaBackground: return "\u{001B}[105m"
        case .brightCyanBackground: return "\u{001B}[106m"
        case .brightWhiteBackground: return "\u{001B}[107m"
            
        // -- Extended Color -- https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit
        
        case .foreground(let code): return "\u{001B}[38;5;\(code)m"
        case .background(let code): return "\u{001B}[48;5;\(code)m"
        }
    }
    
    /// See https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit
    public enum ExtendedColor {
        

        
        public var terminalCode: String {
            switch self {

            }
        }
    }
}
