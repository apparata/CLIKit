//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

public final class CommandLineHistory {
    
    public var lineCount: Int {
        return history.count
    }
        
    private var maxLineCount: Int
    private var history: [String]
    
    public init(maxLineCount: Int) {
        history = []
        self.maxLineCount = maxLineCount
    }
    
    public func addEntry(_ string: String) {
        if string.trimmingWhitespace().isEmpty {
            if history.first == "" {
                return
            }
        }
        history.insert(string, at: 0)
        if history.count > maxLineCount {
            history.removeLast()
        }
    }
    
    public func updateEntry(_ string: String, at index: Int) {
        history[index] = string
    }
    
    public func removeFirstEntry() {
        history.removeFirst()
    }
    
    public subscript(index: Int) -> String {
        return history[index]
    }
}
