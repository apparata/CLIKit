//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

public class SimpleWordCompletion: TextCompletion {
    
    public let completions: [String]
    
    public init(completions: [String]) {
        self.completions = completions
    }
    
    public func complete(input: String, index: Int) -> (String, Int) {
        
        guard input.count > 0 else {
            return (input, index)
        }
        
        var cursor = index
        if cursor == input.count {
            cursor -= 1
        }
        
        if cursor > 0 {
            let characterAtCursor = input[input.index(input.startIndex, offsetBy: cursor)]
            if characterAtCursor.isWhitespace {
                cursor -= 1
            }
        }
        
        if let (word, range) = input.word(at: cursor) {
            let candidates = completions.filter {
                $0.hasPrefix(word)
            }
            if candidates.count == 1, let completion = candidates.first {
                var completedInput = input
                completedInput.replaceSubrange(range, with: completion)
                let wordEndIndex = range.upperBound.utf16Offset(in: completedInput)
                let adjustedColumn = wordEndIndex + completedInput.count - input.count
                return (completedInput, adjustedColumn)
            }
        }
        
        return (input, index)
    }
}
