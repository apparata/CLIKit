# CLIKit

[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/) ![MIT License](https://img.shields.io/badge/license-MIT-blue.svg) ![language Swift 5.1](https://img.shields.io/badge/language-Swift%205.1-orange.svg) ![platform macOS](https://img.shields.io/badge/platform-macOS-lightgrey.svg)

The CLIKit framework contains various convenient utilities for making it easier to write
command line tools in Swift.

## License

CLIKit is released under the MIT license. See `LICENSE` file for more detailed information.

# Table of Contents

- [Getting Started](#getting-started)
- [Features](#features)
  - [Command Line Parser](#command-line-parser)
  - [Subprocesses](#subprocesses)
  - [Terminal Output](#terminal-output)
  - [Execution](#execution)
  - [Path Management](#path-management)

# Getting Started

Add CLIKit to your Swift package by adding the following to your `Package.swift` file in
the dependencies array:

```swift
.package(url: "https://github.com/apparata/CLIKit.git", from: "0.1.0")
```
If you are using Xcode 11 or newer, you can add CLIKit by entering the URL to the
repository via the `File` menu:

```
File > Swift Packages > Add Package Dependency...
```

**Note:** CLIKit requires **Swift 5.1** or later.

# Features

The following sections contain some rudimentary information about the most prominent
features in CLIKit, along with examples.

## Command Line Parser

Example of a command definition:

```swift
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

Example of running the parser on the executable arguments and then runing the
command handler after the command has been parsed:

```swift
let command = try CommandLineParser().parse(FibonacciCommand())
try command.run()
```

If the binary is called `fibonacci`, the command can be run like this in a shell:

```bash
$ fibonacci -i 4
```

Several commands can be grouped together as subcommands:

```swift
class MathCommand: Commands {
    
    let description = "Perform math operations"
    
    let fibonacci = FibonacciCommand()
    let factorize = FactorizeCommand()
    let sum = SumCommand()
}
```

Example of running the parser on the executable arguments and then runing the
command handler after the command has been parsed:

```swift
let command = try CommandLineParser().parse(MathCommand())
try command.run()
```

If the binary is called `math`, the `fibonacci` subcommand can be run like this in a shell:

```bash
$ math fibonacci -i 4
```

## Subprocesses

Example of launching a subprocess and capturing its output:

```swift
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

```swift
Console.print("\(.green)This is green.\(.reset)\(.bold)This is bold.\(.reset)")
```

If the console is a "dumb" terminal or the Xcode console, the ANSI terminal codes will be
filtered out.

The `Console` class has a few convenience methods for console input and output:

```swift
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

```swift
Execution.runUntilTerminated()
```

There is an optional closure parameter to handle any necessary cleanup when the
program is terminated. The closure is called if the process receives `SIGINT` (typically if 
the user presses Ctrl-C) or `SIGTERM`.

Example:

```swift
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

## Path Management

CLIKit contains a `Path` struct that makes working with file system paths easier.

Examples:

```swift
let absolutePath = Path("/usr/bin/zip")
absolutePath.isAbsolute
absolutePath.isRelative

let relativePath = Path("bin/whatever")
relativePath.isAbsolute
relativePath.isRelative

let concatenatedPath = Path("/usr") + Path("/bin")

let messyPath = Path("//usr/../usr/local/bin/./whatever")
messyPath.normalized

let pathFromLiteralString: Path = "/this/is/a/path"
let pathFromEmptyString: Path = ""
let pathFromConcatenatedStrings: Path = "/usr" + "/bin"

let pathFromComponents = Path(components: ["/", "usr/", "bin", "/", "swift"])
let pathFromEmptyComponents = Path(components: [])

let appendedPath = Path("/usr/local").appendingComponent("bin")
let appendedPath3 = Path("/usr/local").appending(Path("bin"))
let appendedPath2 = Path("/usr/local") + Path("bin")

let imagePath = Path("photos/photo").appendingExtension("jpg")
imagePath.extension

let imagePathWithoutExtension = imagePath.deletingExtension
let imagePathWithoutLastComponent = imagePath.deletingLastComponent

absolutePath.exists
absolutePath.isFile
absolutePath.isDirectory
absolutePath.isDeletable
absolutePath.isExecutable
absolutePath.isReadable
absolutePath.isWritable

// Return an array of Path objects representing files in the current directory.
let filesInDirectory = try Path.currentDirectory.contentsOfDirectory

// Change directory to the user's home directory
Path.homeDirectory?.becomeCurrentDirectory()

if let desktop = Path.desktopDirectory {
    Path("/path/myfile.txt").copy(to: desktop)
}

desktop.appendingComponent("myfile.txt").remove()

try (desktop + "My Folder").createDirectory()

Path("/path/myscript.sh").setPosixPermissions(0o700)
```
