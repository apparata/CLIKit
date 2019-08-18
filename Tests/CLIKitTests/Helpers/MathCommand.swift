//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation
import CLIKit

func fibonacci(_ n: Int, printSteps: Bool) -> Int {
    var f1 = 0
    var f2 = 1
    for index in 0..<n {
        let f = f1 + f2
        f1 = f2
        f2 = f
        if printSteps {
            print("\(index + 1): \(f2)")
        }
    }
    return f2
}

class FibonacciCommand: Command {
    
    let description = "Calculate fibonacci numbers"

    @CommandFlag(short: "v", description: "Prints verbose output")
    var verbose: Bool
    
    @CommandOption(short: "i", default: 5, regex: #"^\d+$"#,
                   description: "Number of iterations to perform.")
    var iterations: Int
    
    func run() {
        let result = fibonacci(iterations, printSteps: verbose)
        print("Result: \(result)")
    }
}

class FactorizeCommand: Command {
    
    let description = "Factorize a number"

    @CommandFlag(short: "v", description: "Prints verbose output")
    var verbose: Bool
    
    @CommandOptionalInput(description: "Number to factorize")
    var number: Int?
    
    func run() {
        print("Supposed to factorize \(number!), but can't be bothered.")
    }
}

class SumOfTwoCommand: Command {
    
    let description = "Sum two numbers"

    @CommandRequiredInput(description: "First number")
    var numberA: Int

    @CommandOptionalInput(description: "Second number")
    var numberB: Int?
        
    func run() {
        print("\(numberA + (numberB ?? 0))")
    }
}

class SumCommand: Command {
    
    let description = "Sum arbitrary amount of numbers"

    @CommandRequiredInput(description: "First number")
    var firstNumber: Int
    
    @CommandVariadicInput(description: "More numbers")
    var numbers: [Int]

    func run() {
        print("\(firstNumber + numbers.reduce(0, +))")
    }
}

class MathCommand: Commands {
    
    let description = "Perform math operations"
    
    let fibonacci = FibonacciCommand()
    let factorize = FactorizeCommand()
    let sumoftwo = SumOfTwoCommand()
    let sum = SumCommand()
}
