//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

public struct TerminalString: CustomStringConvertible {

    public enum Fragment {
        case string(String)
        case terminalCode(String)
    }
    
    private var fragments: [Fragment]
    
    public init(_ string: String) {
        fragments = [.string(string)]
    }
    
    public init(_ fragment: Fragment) {
        fragments = [fragment]
    }
    
    public init(_ fragments: [Fragment]) {
        self.fragments = fragments
    }
    
    public var description: String {
        return asPlainString
    }

    public var asPlainString: String {
        return fragments.compactMap {
            switch $0 {
            case .string(let string): return string
            case .terminalCode(_): return nil
            }
        }.joined()
    }
    
    public func forTerminal(_ type: TerminalType) -> String {
        if type.isTerminal, !ExecutionMode.isDebuggerAttached {
            return fragments.compactMap {
                switch $0 {
                case .string(let string): return string
                case .terminalCode(let string): return string
                }
            }.joined()
        } else {
            return asPlainString
        }
    }
}

extension TerminalString: ExpressibleByStringInterpolation {
    
    public init(stringLiteral value: String) {
        self.init(value)
    }
    
    public init(stringInterpolation: StringInterpolation) {
        self.init(stringInterpolation.fragments)
    }
    
    public struct StringInterpolation: StringInterpolationProtocol {
        
        var fragments: [Fragment]

        public init(literalCapacity: Int, interpolationCount: Int) {
            fragments = []
        }

        public mutating func appendLiteral(_ literal: String) {
            fragments.append(.string(literal))
        }
        
        public mutating func appendInterpolation(_ code: TerminalCode) {
            fragments.append(.terminalCode(code.terminalCode))
        }
    }
}
