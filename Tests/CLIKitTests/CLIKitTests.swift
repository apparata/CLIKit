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
        
            let parsedCommand = try parser.parseArguments(arguments, command: MathCommand())
            try parsedCommand.run()
        }
        
        XCTAssertNoThrow(try runCommand())
    }

    static var allTests = [
        ("testCommandFibonacci", testCommandFibonacci),
    ]
}
