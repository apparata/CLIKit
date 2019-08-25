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
                "fibonacci",
                "-v",
                "-i",
                "10"
            ]
        
            let parsedCommand = try parser.parseArguments(arguments, command: FibonacciCommand(), expectedRootCommand: "fibonacci")
            try parsedCommand.run()
        }
        
        XCTAssertNoThrow(try runCommand())
    }
    
    func testSubcommandFibonacci() {
        
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
    
    func testRequiredInput() {
        
        func runCommand() throws {
            let parser = CommandLineParser()
            
            let arguments: [String] = [
                "math",
                "sum"
            ]
        
            let parsedCommand = try parser.parseArguments(arguments, command: MathCommand(), expectedRootCommand: "math")
            try parsedCommand.run()
        }
        
        XCTAssertThrowsError(try runCommand())
    }

    func testOptionalInput() {
        
        func runCommand() throws {
            let parser = CommandLineParser()
            
            let arguments: [String] = [
                "math",
                "sum",
                "1"
            ]
        
            let parsedCommand = try parser.parseArguments(arguments, command: MathCommand(), expectedRootCommand: "math")
            try parsedCommand.run()
        }
        
        XCTAssertNoThrow(try runCommand())
    }
    
    func testOptionalInput2() {
        
        func runCommand() throws {
            let parser = CommandLineParser()
            
            let arguments: [String] = [
                "math",
                "sum",
                "1",
                "2"
            ]
        
            let parsedCommand = try parser.parseArguments(arguments, command: MathCommand(), expectedRootCommand: "math")
            try parsedCommand.run()
        }
        
        XCTAssertNoThrow(try runCommand())
    }
    
    func testCommandBuildBot() {
        
        func runCommand() throws {
            let parser = CommandLineParser()
            
            let arguments: [String] = [
                "bot",
                "build",
                "master"
            ]
        
            let parsedCommand = try parser.parseArguments(arguments, command: BotCommands(), expectedRootCommand: "bot")
            try parsedCommand.run()
        }
        
        do {
            try runCommand()
        } catch {
            print(error.localizedDescription)
        }
        
        XCTAssertTrue(true)
    }
    
    func testMainframeCommand() {
        
        func runCommand(_ arguments: [String]) throws {
            let parser = CommandLineParser()
            
            let parsedCommand = try parser.parseArguments(arguments, command: MainframeCommand(), expectedRootCommand: "mainframe")
            try parsedCommand.run()
        }
        
        XCTAssertNoThrow(try runCommand(["mainframe", "-p", "4040"]))
        XCTAssertNoThrow(try runCommand(["mainframe"]))
    }
    
    static var allTests = [
        ("testCommandFibonacci", testCommandFibonacci),
        ("testSubcommandFibonacci", testSubcommandFibonacci),
        ("testUnrecognizedCommand", testUnrecognizedCommand),
        ("testRequiredInput", testRequiredInput),
        ("testOptionalInput", testOptionalInput),
        ("testOptionalInput2", testOptionalInput2),
        ("testCommandBuildBot", testCommandBuildBot),
        ("testMainframeCommand", testMainframeCommand),
    ]
}
