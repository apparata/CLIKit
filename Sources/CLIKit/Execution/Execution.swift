//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

public final class Execution {
    
    /// The signal handler is run when either the `SIGINT` or `SIGTERM`
    /// signal is received by the process. It is used to clean up before
    /// exiting the program.
    ///
    /// Returns `true` if the program should exit, or `false` to keep running.
    /// The normal case would be to return `true`.
    public typealias SignalHandler = () -> Bool
    
    /// Private singleton instance.
    private static let instance = Execution()
    
    private var signalSources: [DispatchSourceSignal] = []
    private let signalQueue = DispatchQueue(label: "clikit.signalhandler")
        
    /// Starts the main run loop and optionally installs a signal handler
    /// for the purpose of cleanup before terminating. The signal handler
    /// will be executed for `SIGINT` and `SIGTERM`.
    ///
    /// - parameter signalHandler: Optional signal handler to execute before
    ///                            the program is terminated. If the signal
    ///                            handler returns `false`, the program will
    ///                            suppress the signal and not exit.
    public static func runUntilTerminated(signalHandler: SignalHandler? = nil) {
        instance.signalSources = instance.installSignalHandler(signalHandler)
        RunLoop.main.run()
    }
    
    /// Installs `SIGINT` and `SIGTERM` signal handler.
    private func installSignalHandler(_ handler: SignalHandler?) -> [DispatchSourceSignal] {
        
        let sigintSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: signalQueue)
        sigintSource.setEventHandler {
            let shouldExit = handler?() ?? true
            print()
            if shouldExit {
                exit(0)
            }
        }
        
        let sigtermSource = DispatchSource.makeSignalSource(signal: SIGTERM, queue: signalQueue)
        sigtermSource.setEventHandler {
            let shouldExit = handler?() ?? true
            print()
            if shouldExit {
                exit(0)
            }
        }
                
        // Ignore default handlers.
        signal(SIGINT, SIG_IGN)
        signal(SIGTERM, SIG_IGN)
        
        sigintSource.resume()
        sigtermSource.resume()
        
        return [sigintSource, sigtermSource]
    }
}
