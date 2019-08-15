//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import XCTest
@testable import CLIKit

final class CLIKitTests: XCTestCase {
    
    func testCommandFibonacci() {
        
        func runCommand() throws {
            let parser = CommandLineParser()
            
            let arguments: [String] = [
                "math",
                "fibonacci",
                "-v",
                "-i",
                "10"
            ]
        
            let parsedCommand = try parser.parseArguments(arguments, command: MathCommand(), expectedRootCommand: "math")
            try parsedCommand.run()
        }
        
        XCTAssertNoThrow(try runCommand())
    }
    
    func testUnrecognizedCommand() {
        
        func runCommand() throws {
            let parser = CommandLineParser()
            
            let arguments: [String] = [
                "test"
            ]
        
            let parsedCommand = try parser.parseArguments(arguments, command: MathCommand(), expectedRootCommand: "math")
            try parsedCommand.run()
        }
        
        do {
            try runCommand()
        } catch {
            print(error.localizedDescription)
        }
        
        XCTAssertTrue(true)
    }

    static var allTests = [
        ("testCommandFibonacci", testCommandFibonacci,
         "testUnrecognizedCommand", testUnrecognizedCommand),
    ]
}
