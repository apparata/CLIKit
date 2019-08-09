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
    
    case terminal(String)
    case dumb
    case file
    
    var isTerminal: Bool {
        switch self {
        case .terminal(_): return true
        default: return false
        }
    }
    
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
            
        return (rows: 10, columns: 80)
    }
    
    public static func type(fileHandle: FileHandle) -> TerminalType {
        let terminal = getenv("TERM").flatMap { String(validatingUTF8: $0) }
        if terminal?.lowercased() == "dumb" {
            return .dumb
        }
        if isatty(fileHandle.fileDescriptor) == 1 {
            return .terminal(terminal ?? "generic")
        }
        return .file
    }
}

public extension Terminal {
    
    static func type(output: Output) -> TerminalType {
        if let wrapper = output as? WrapsFileHandle {
            return type(fileHandle: wrapper.fileHandle)
        } else {
            return .file // Better safe than sorry.
        }
    }
}
