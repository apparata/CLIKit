//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

public final class LineReader {
    
    private let input: Input
    
    private var buffer: String = ""
    
    public init(input: Input) {
        self.input = input
    }

    public func readLine(includeNewline: Bool = false) -> String? {
        guard let string = input.read() else {
            return nil
        }
        
        buffer += string
        
        guard let range = buffer.range(of: "\n") else {
            return nil
        }

        let upperBound = includeNewline ? range.upperBound : buffer.index(range.upperBound, offsetBy: -1)
        
        let line = String(buffer[..<upperBound])
        
        if range.upperBound < buffer.endIndex {
            let remainingLowerBound = buffer.index(range.upperBound, offsetBy: 1)
            buffer = String(buffer[remainingLowerBound...])
        } else {
            buffer = ""
        }
        
        return line
    }
}
