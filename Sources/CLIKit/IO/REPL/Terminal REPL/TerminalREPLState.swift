//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

class TerminalREPLState {
    
    var isLogEnabled = false
    
    var prompt: TerminalString = ">>> " {
        didSet {
            promptLength = prompt.asPlainString.count
        }
    }
    var promptLength: Int = 4
    var input: String = "" {
        didSet {
            let width = Terminal.windowSize.columns
            let height = 1 + (promptLength + input.count) / width
            expandedToRows = max(height, expandedToRows)
        }
    }
    var row: Int = 1
    var column: Int = 1
    var expandedToRows: Int = 1
    
    var startRow: Int
    var startColumn: Int
    
    var end: (row: Int, column: Int) {
        let width = Terminal.windowSize.columns
        let entireRows = ((startColumn - 1) + promptLength + input.count) / width
        let endRow = startRow + entireRows
        let endColumn = 1 + ((startColumn - 1) + promptLength + input.count) % width
        return (row: endRow, column: endColumn)
    }
    
    var index: Int {
        get {
            let width = Terminal.windowSize.columns
            return (row - startRow) * width + (column - 1) - promptLength
        }
        set {
            let width = Terminal.windowSize.columns
            let index = newValue + promptLength
            row = startRow + (index / width)
            column = startColumn + (index % width)
        }
    }
                
    init() {
        (startRow, startColumn) = Console.cursorPosition()
        row = startRow
        column = startColumn + promptLength
        
        if isLogEnabled {
            Console.printError("startRow:\(startRow) startColumn:\(startColumn)")
        }
    }
    
    func stringIndex(offset: Int) -> String.Index {
        return input.index(input.startIndex, offsetBy: index + offset)
    }
    
    func moveToStart() {
        row = startRow
        column = startColumn + promptLength
    }
    
    func moveToEnd() {
        (row, column) = end
    }
    
    func moveLeft(actionBeforeMove: ((TerminalREPLState, String.Index) -> Void)? = nil) {
        let width = Terminal.windowSize.columns
        if row == startRow && column == startColumn + promptLength {
            Console.bell()
        } else {
            actionBeforeMove?(self, stringIndex(offset: -1))
            column -= 1
            if column == 0 {
                row -= 1
                column = width
            }
        }
    }
    
    func moveRight(actionBeforeMove: ((TerminalREPLState, String.Index) -> Void)? = nil) {
        let width = Terminal.windowSize.columns
        let (endRow, endColumn) = end
        if row == endRow && column == endColumn {
            Console.bell()
        } else {
            actionBeforeMove?(self, stringIndex(offset: -1))
            column += 1
            if column > width {
                row += 1
                column = 1
            }
        }
    }
}
