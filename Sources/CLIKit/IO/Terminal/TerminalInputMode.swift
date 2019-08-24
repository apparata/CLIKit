//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

public enum TerminalInputModeError: Error {
    case stdinIsNotATerminal
    case failedToRestoreTerminalAttributes
    case failedToReadTerminalAttributes
    case failedToApplyTerminalAttributes
}

public final class TerminalInputMode {
    
    public enum Mode {
        case normal
        case cbreak
        case raw
    }
    
    public private(set) static var currentMode: Mode = .normal
    
    private static var normalAttributes: termios?
    
    private static var isStdinTerminal: Bool {
        isatty(STDIN_FILENO) == 1
    }
    
    public static func setCBreakMode() throws {
        guard isStdinTerminal else {
            throw TerminalInputModeError.stdinIsNotATerminal
        }
        if normalAttributes != nil {
            try reset()
        }
        
        var attributes = try storeTerminalAttributes()
        
        // Echo off, canonical mode off
        attributes.c_lflag &= ~tcflag_t(ECHO | ICANON)

        // 1 byte at a time, no timer.
        attributes[VMIN] = 1
        attributes[VTIME] = 0
        
        try applyTerminalAttributes(attributes)
        
        // Verify the changes. tcsetattr() sometimes reports partial success.
        do {
            let attributes = try readTerminalAttributes()
            guard
                attributes.c_lflag & tcflag_t(ECHO | ICANON) == 0,
                attributes[VMIN] == 1,
                attributes[VTIME] == 0 else {
                // Only some of the changes were made.
                throw TerminalInputModeError.failedToApplyTerminalAttributes
            }
        } catch {
            try restoreTerminalAttributes()
            throw TerminalInputModeError.failedToApplyTerminalAttributes
        }
        
        currentMode = .cbreak
    }
    
    public static func setRawMode() throws {
        guard isStdinTerminal else {
            throw TerminalInputModeError.stdinIsNotATerminal
        }
        if normalAttributes != nil {
            try reset()
        }
        
        var attributes = try storeTerminalAttributes()
        
        // Echo off, canonical mode off, extended input processing off,
        // signal chars off.
        attributes.c_lflag &= ~tcflag_t(ECHO | ICANON | IEXTEN)
        
        // No SIGINT on BREAK, CR-to-NL off, input parity check off,
        // don't strip 8th bit on input, output flow control off.
        attributes.c_iflag &= ~tcflag_t(BRKINT | ICRNL | INPCK | ISTRIP | IXON)
        
        // Helps backspace out with UTF-8 sequences. Or something.
        attributes.c_iflag |= tcflag_t(IUTF8)
        
        // Clear size bits, parity checking off.
        attributes.c_cflag &= ~tcflag_t(CSIZE | PARENB)
        
        // 8 bits/char.
        attributes.c_cflag |= tcflag_t(CS8)
        
        // Output processing off.
        attributes.c_oflag &= ~tcflag_t(OPOST)
        
        // 1 byte at a time, no timer.
        attributes[VMIN] = 1
        attributes[VTIME] = 0
        
        try applyTerminalAttributes(attributes)
        
        // Verify the changes. tcsetattr() sometimes reports partial success.
        do {
            let attributes = try readTerminalAttributes()
            guard
                attributes.c_lflag & tcflag_t(ECHO | ICANON | IEXTEN) == 0,
                attributes.c_iflag & tcflag_t(BRKINT | ICRNL | INPCK | ISTRIP | IXON) == 0,
                attributes.c_cflag & tcflag_t(CSIZE | PARENB | CS8) == tcflag_t(CS8),
                attributes.c_oflag & tcflag_t(OPOST) == 0,
                attributes[VMIN] == 1,
                attributes[VTIME] == 0 else {
                // Only some of the changes were made.
                throw TerminalInputModeError.failedToApplyTerminalAttributes
            }
        } catch {
            try restoreTerminalAttributes()
            throw TerminalInputModeError.failedToApplyTerminalAttributes
        }
        
        currentMode = .raw
    }
    
    public static func reset() throws {
        guard isStdinTerminal else {
            throw TerminalInputModeError.stdinIsNotATerminal
        }
        try restoreTerminalAttributes()
        currentMode = .normal
    }
 
    private static func storeTerminalAttributes() throws -> termios {
        let attributes = try readTerminalAttributes()
        normalAttributes = attributes
        return attributes
    }
    
    private static func restoreTerminalAttributes() throws {
        guard let normalAttributes = normalAttributes else {
            throw TerminalInputModeError.failedToRestoreTerminalAttributes
        }
        try applyTerminalAttributes(normalAttributes)
    }
    
    private static func readTerminalAttributes() throws -> termios {
        var attributes: termios = .zero
        guard tcgetattr(STDIN_FILENO, &attributes) == 0 else {
            throw TerminalInputModeError.failedToReadTerminalAttributes
        }
        return attributes
    }
    
    private static func applyTerminalAttributes(_ attributes: termios) throws {
        var attributesToApply = attributes
        guard tcsetattr(STDIN_FILENO, TCSAFLUSH, &attributesToApply) == 0 else {
            throw TerminalInputModeError.failedToApplyTerminalAttributes
        }
    }
}

private extension termios {
    
    static var zero: termios {
        let zero: cc_t = 0
        let zeroFlag: tcflag_t = 0
        let cct = (zero, zero, zero, zero, zero, zero, zero, zero, zero, zero,
                   zero, zero, zero, zero, zero, zero, zero, zero, zero, zero)
        return termios(c_iflag: zeroFlag,
                       c_oflag: zeroFlag,
                       c_cflag: zeroFlag,
                       c_lflag: zeroFlag,
                       c_cc: cct,
                       c_ispeed: speed_t(0),
                       c_ospeed: speed_t(0))
    }
    
    subscript(cc: Int32) -> cc_t {
        get {
            switch cc {
            case 0: return c_cc.0
            case 1: return c_cc.1
            case 2: return c_cc.2
            case 3: return c_cc.3
            case 4: return c_cc.4
            case 5: return c_cc.5
            case 6: return c_cc.6
            case 7: return c_cc.7
            case 8: return c_cc.8
            case 9: return c_cc.9
            case 10: return c_cc.10
            case 11: return c_cc.11
            case 12: return c_cc.12
            case 13: return c_cc.13
            case 14: return c_cc.14
            case 15: return c_cc.15
            case 16: return c_cc.16
            case 17: return c_cc.17
            case 18: return c_cc.18
            case 19: return c_cc.19
            default: return 0
            }
        }
        set {
            switch cc {
            case 0: c_cc.0 = newValue
            case 1: c_cc.1 = newValue
            case 2: c_cc.2 = newValue
            case 3: c_cc.3 = newValue
            case 4: c_cc.4 = newValue
            case 5: c_cc.5 = newValue
            case 6: c_cc.6 = newValue
            case 7: c_cc.7 = newValue
            case 8: c_cc.8 = newValue
            case 9: c_cc.9 = newValue
            case 10: c_cc.10 = newValue
            case 11: c_cc.11 = newValue
            case 12: c_cc.12 = newValue
            case 13: c_cc.13 = newValue
            case 14: c_cc.14 = newValue
            case 15: c_cc.15 = newValue
            case 16: c_cc.16 = newValue
            case 17: c_cc.17 = newValue
            case 18: c_cc.18 = newValue
            case 19: c_cc.19 = newValue
            default: break
            }
        }
    }
}
