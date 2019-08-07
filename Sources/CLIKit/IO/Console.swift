//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

public class Console {
    
    public static let standard = StandardIO()
    
    public static let lineReader = LineReader(input: standard.in)
    
    public static let terminalType: TerminalType = {
        return Terminal.type(output: standard.out)
    }()
    
    public static let errorTerminalType: TerminalType = {
        return Terminal.type(output: standard.error)
    }()
    
    // MARK: - Read
    
    public static func readLine() -> String? {
        return lineReader.readLine()
    }
    
    // MARK: - Write
    
    public static func write(_ string: String) {
        standard.out.write(string)
    }

    public static func writeError(_ string: String) {
        standard.error.write(string)
    }
    
    public static func writeLine(_ string: String) {
        standard.out.writeLine(string)
    }
    
    public static func writeLineError(_ string: String) {
        standard.error.writeLine(string)
    }
    
    public static func write(terminalString: TerminalString) {
        standard.out.write(terminalString.forTerminal(terminalType))
    }

    public static func writeError(terminalString: TerminalString) {
        standard.out.write(terminalString.forTerminal(errorTerminalType))
    }
        
    public static func print(_ string: TerminalString) {
        standard.out.writeLine(string.forTerminal(terminalType))
    }

    public static func printError(_ string: TerminalString) {
        standard.error.writeLine(string.forTerminal(errorTerminalType))
    }
    
    // MARK: - Write Terminal Code
    
    public static func write(_ code: TerminalCode.ClearScreen) {
        write(code.terminalCode)
    }

    public static func writeError(_ code: TerminalCode.ClearScreen) {
        write(code.terminalCode)
    }
    
    public static func write(_ code: TerminalCode.ClearLine) {
        write(code.terminalCode)
    }

    public static func writeError(_ code: TerminalCode.ClearLine) {
        write(code.terminalCode)
    }

    public static func write(_ code: TerminalCode.TextStyle) {
        write(code.terminalCode)
    }

    public static func writeError(_ code: TerminalCode.TextStyle) {
        write(code.terminalCode)
    }

    public static func write(_ code: TerminalCode.ExtendedColor) {
        write(code.terminalCode)
    }

    public static func writeError(_ code: TerminalCode.ExtendedColor) {
        write(code.terminalCode)
    }
    
    // MARK: - Convenience
    
    public static func ask(question: String, default defaultValue: String?) -> String? {
        if let defaultValue = defaultValue {
            write("\(question) [\(defaultValue)] ")
        } else {
            write("\(question) ")
        }
        
        if let line = readLine() {
            switch line.lowercased() {
            case "":
                return defaultValue
            default:
                return line
            }
        } else {
            return nil
        }
    }
    
    public static func confirmYesOrNo(question: String, default defaultValue: Bool) -> Bool? {
        write("\(question) [\(defaultValue ? "Y/n" : "y/N")] ")
        if let line = readLine() {
            switch line.lowercased() {
            case "y", "yes", "yep":
                return true
            case "n", "no", "nope":
                return false
            case "":
                return defaultValue
            default:
                return nil
            }
        } else {
            return nil
        }
    }
    
    // MARK: - Clear
    
    public static func clear() {
        write(.clearScreen)
        write("\r")
        flush()
    }
    
    public static func clearError() {
        writeError(.clearScreen)
        write("\r")
        flush()
    }

    public static func clearLine() {
        write(.clearLine)
        write("\r")
        flush()
    }
    
    public static func clearLineError() {
        write(.clearLine)
        write("\r")
        flush()
    }
    
    // MARK: - Flush
    
    public static func flush() {
        standard.out.flush()
    }
    
    public static func flushError() {
        standard.error.flush()
    }
}
