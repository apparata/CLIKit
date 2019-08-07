# CLIKit

[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/) ![MIT License](https://img.shields.io/badge/license-MIT-blue.svg) ![language Swift 5.1](https://img.shields.io/badge/language-Swift%205.1-orange.svg) ![platform macOS](https://img.shields.io/badge/platform-macOS-lightgrey.svg)

The CLIKit framework contains various convenient utilities for making it easier to write
command line tools in Swift.

## License

CLIKit is released under the MIT license. See `LICENSE` file for more detailed information.

## Getting Started

Add CLIKit to your Swift package by adding the following to your `Package.swift` file in
the dependencies array:

```Swift
.package(url: "https://github.com/apparata/CLIKit.git", from: "0.1.0")
```
If you are using Xcode 11 or newer, you can add CLIKit by entering the URL to the
repository via the `File` menu:

```
File > Swift Packages > Add Package Dependency...
```

## Command Line Parser

Example of a command definition:

```Swift
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
```

## Subprocesses

Example of launching a subprocess and capturing its output:

```Swift
import CLIKit

// Search for Swift in using PATH environment variable.
guard let path = ExecutableFinder.find("swift") else {
    print("Didn't find swift, exiting.")
    exit(1)
}

do {
    // Launch Swift as a subprocess and capture its output.
    let subprocess = Subprocess(executable: path,
                                arguments: ["-h"],
                                captureOutput: true)
    try subprocess.spawn()

    // Wait for the process to finish.
    let result = try subprocess.wait()

    // Print the captured output from the subprocess.
    print(try result.capturedOutputString())
} catch {
    dump(error)    
}
```

## Terminal Output

Example of using the `TerminalString` struct to print a string with ANSI terminal codes:

```Swift
Console.print("\(.green)This is green.\(.reset)\(.bold)This is bold.\(.reset)")
```

If the console is a "dumb" terminal or the Xcode console, the ANSI terminal codes will be
filtered out.

The `Console` class has a few convenience methods for console input and output:

```Swift
if Console.confirmYesOrNo(question: "Clear the screen?", default: false) {
    // Clear the screen.
    Console.clear()
} else {
    // Do not clear the screen.
}
```

## Execution

Command line programs usually end when there is no more code to run on the main 
thread. To do asynchronous work, such as network requests, or running code on a
dispatch queue, a runloop needs to be started. The `runUntilTerminated()` method
of the `Execution` class can be used to start a runloop that will run until the program is terminated, either programmatically using `exit()` or similar, or explicitly terminated
by the system, e.g. if the user presses Ctrl-C.

Example:

```Swift
Execution.runUntilTerminated()
```

There is an optional closure parameter to handle any necessary cleanup when the
program is terminated. The closure is called if the process receives `SIGINT` (typically if 
the user presses Ctrl-C) or `SIGTERM`.

Example:

```Swift
Execution.runUntilTerminated { signal in 

    switch signal {
    case .terminate:
        // Do any necessary cleanup here.
        ...
        
        // Return true to allow the system to handle the SIGTERM signal.
        return true
        
    case .interrupt:
        // Do any necessary cleanup here.
        ...

        // Return false to suppress the SIGINT signal.
        // This will not allow Ctrl-C to terminate the program.
        return false
    }
}
```
