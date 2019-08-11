//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

public final class BasicREPL: REPLImplementation {
    
    var prompt: TerminalString
    
    /// Text completion is not supported by `BasicREPL`
    var textCompletion: TextCompletion?
    
    /// Command history and text completion are not supported by `BasicREPL`
    init(prompt: TerminalString,
         maxHistoryLineCount: Int = 0,
         textCompletion: TextCompletion? = nil) {
        self.prompt = prompt
    }
    
    func run(evaluateAndPrint: @escaping ReadEvaluatePrintLoop.Evaluator) throws {

        while true {
            Console.write(prompt.asPlainString)
            guard let line = Console.readLine() else {
                break
            }
            guard try evaluateAndPrint(line) == .continue else {
                break
            }
        }
        
        Console.write("\n")
        Console.flush()
    }
    

}

