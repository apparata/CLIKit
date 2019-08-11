//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation
#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

public enum TerminalType {
    
    /// Terminal as described by the `TERM` environment variable.
    case terminal(String)
    
    /// A dumb terminal cannot be expected to handle ANSI terminal codes.
    case dumb
    
    /// Indicates a file and not a terminal.
    case file
    
    var isFile: Bool {
        switch self {
        case .file: return true
        default: return false
        }
    }

    var isDumb: Bool {
        switch self {
        case .dumb: return true
        default: return false
        }
    }

    var isTerminal: Bool {
        switch self {
        case .terminal(_): return true
        default: return false
        }
    }
    
    /// Indicates whether the terminal is detected to be an xterm-256color
    /// terminal that supports the use of extended color ANSI terminal codes.
    var is256ColorXterm: Bool {
        switch self {
        case .terminal(let type) where type == "xterm-256color":
            return true
        default: return false
        }
    }
}

public final class Terminal {
    
    public typealias WindowSizeDidChangeHandler = (_ rows: Int, _ columns: Int) -> Void
    
    /// Closure that is invoked whenever the size of the terminal window
    /// changes. Invocations are done on the main thread. The first argument
    /// represents the row count and the second argument the column count.
    public static var windowSizeDidChange: WindowSizeDidChangeHandler? {
        didSet {
            windowSizeSource?.cancel()
            windowSizeSource = DispatchSource.makeSignalSource(signal: SIGWINCH, queue: .main)
            windowSizeSource?.setEventHandler {
                var windowSize = winsize()
                if ioctl(1, UInt(TIOCGWINSZ), &windowSize) == 0 {
                    Terminal.windowSizeDidChange?(Int(windowSize.ws_row), Int(windowSize.ws_col))
                }
            }
            windowSizeSource?.resume()
        }
    }
    
    private static var windowSizeSource: DispatchSourceSignal?
    
    /// The current size of the terminal window.
    public static var windowSize: (rows: Int, columns: Int) {
        let columns = getenv("COLUMNS").flatMap { String(validatingUTF8: $0) }
        let rows = getenv("LINES").flatMap { String(validatingUTF8: $0) }

        if let columns = columns, let columnCount = Int(columns),
            let rows = rows, let rowCount = Int(rows) {
            return (rows: rowCount, columns: columnCount)
        }
            
        var windowSize = winsize()
        if ioctl(1, UInt(TIOCGWINSZ), &windowSize) == 0 {
            return (rows: Int(windowSize.ws_row), columns: Int(windowSize.ws_col))
        }
            
        return (rows: 0, columns: 0)
    }
    
    /// The detected terminal type for the specified file handle.
    public static func type(fileHandle: FileHandle) -> TerminalType {
        let terminal = getenv("TERM").flatMap { String(validatingUTF8: $0) }
        if let terminalString = terminal?.lowercased().trimmingWhitespace() {
            if ["", "dumb", "cons25", "emacs"].contains(terminalString) {
                return .dumb
            }
            if isatty(fileHandle.fileDescriptor) == 1 {
                return .terminal(terminalString)
            }
        }
        return .file
    }
}

public extension Terminal {
    
    /// The detected terminal type for the specified output channel.
    static func type(output: Output) -> TerminalType {
        if let wrapper = output as? WrapsFileHandle {
            return type(fileHandle: wrapper.fileHandle)
        } else {
            return .file // Better safe than sorry.
        }
    }
}
