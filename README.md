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
