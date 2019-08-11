//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

public enum ReadEvaluatePrintLoopError: Error {
    case unsupportedTerminal
    case endOfInput
    case interrupted
}

public enum ReadEvaluatePrintLoopResult {
    case `continue`
    case `break`
}

internal protocol REPLImplementation {
        
    var prompt: TerminalString { get set }
    
    var textCompletion: TextCompletion? { get set }

    init(prompt: TerminalString,
         maxHistoryLineCount: Int,
         textCompletion: TextCompletion?)

    func run(evaluateAndPrint: @escaping ReadEvaluatePrintLoop.Evaluator) throws
}


public final class ReadEvaluatePrintLoop {
        
    public typealias Evaluator = (String) throws -> ReadEvaluatePrintLoopResult
    
    public var prompt: TerminalString {
        didSet {
            repl.prompt = prompt
        }
    }
    
    public var textCompletion: TextCompletion? {
        didSet {
            repl.textCompletion = textCompletion
        }
    }

    private var repl: REPLImplementation
    
    public init(prompt: TerminalString = ">>> ",
                maxHistoryLineCount: Int = 1000,
                textCompletion: TextCompletion? = nil) throws {
        self.prompt = prompt
        switch Terminal.type(output: Console.standard.out) {
        case .terminal(_):
            repl = TerminalREPL(prompt: prompt, maxHistoryLineCount: maxHistoryLineCount)
        case .dumb:
            repl = BasicREPL(prompt: prompt)
        default:
            if ExecutionMode.isDebuggerAttached {
                // We are probably running in Xcode.
                repl = BasicREPL(prompt: prompt)
            } else {
                throw ReadEvaluatePrintLoopError.unsupportedTerminal
            }
        }        
    }

    public func run(evaluateAndPrint: @escaping Evaluator) throws {
        try repl.run(evaluateAndPrint: evaluateAndPrint)
    }
}
