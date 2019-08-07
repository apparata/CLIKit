//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation
#if os(Linux)
import Glibc
#else
import Darwin
import Darwin.C
#endif

public class Subprocess {
    
    typealias Arguments = CStrings
    typealias Environment = KeyValueCStrings
    
    public enum State {
        case initial
        case spawning
        case spawned
        case finished
    }
    
    public private(set) var processID = pid_t()
        
    public let executable: Path
    public let arguments: [String]
    public let environment: [String: String]
    public let captureOutput: Bool
    
    public private(set) var result: SubprocessResult? = nil
    
    public var state: State {
        return stateMachine.state
    }
    
    private let stateMachine = SubprocessStateMachine()
    
    private var captureOutputThread: SubprocessCaptureThread? = nil
    private var captureErrorThread: SubprocessCaptureThread? = nil
    
    public init(executable: Path,
                arguments: [String],
                environment: [String: String] = [:],
                captureOutput: Bool = true) {
        self.executable = executable
        self.arguments = arguments
        self.environment = environment
        self.captureOutput = captureOutput
    }
    
    public func spawn() throws {
                
        guard executable.exists else {
            throw SubprocessError.executableNotFound(name: executable.string)
        }
        
        try stateMachine.enterSpawningState()
        
        let cArguments = Arguments([executable.string] + arguments)
        let cEnvironment = Environment(environment)
        let attributes = SubprocessAttributes()
        let io = try SubprocessIO(captureOutput: captureOutput)
        
        let result = posix_spawnp(&processID,
                                  cArguments.cStrings[0],
                                  &io.actions,
                                  &attributes.attributes,
                                  cArguments.cStrings,
                                  cEnvironment.cStrings)
        
        guard result == 0 else {
            throw SubprocessError.failedToSpawn(errorCode: Int(result),
                                                arguments: arguments)
        }

        if captureOutput {
            try startCapturingOutput(io: io)
        }

        stateMachine.enterSpawnedState()
    }
        
    @discardableResult
    public func wait() throws -> SubprocessResult {
        
        switch stateMachine.state {
        case .initial:
            throw SubprocessError.thereIsNoResult
        case .finished:
            guard let result = self.result else {
                throw SubprocessError.thereIsNoResult
            }
            return result
        default:
            break
        }
        
        let outputResult = captureOutputThread?.join()
        let errorResult = captureErrorThread?.join()
        
        let status = try waitForExit()
        
        let result = SubprocessResult(arguments: arguments,
                                  status: status,
                                  captureOutputResult: outputResult,
                                  captureErrorResult: errorResult)
        
        self.result = result
        
        stateMachine.enterFinishedState()
        
        return result
    }
    
    // MARK: - Wait for process to exit
    
    private func waitForExit() throws -> Int {
        
        var status: Int32 = 0
        var result = waitpid(processID, &status, 0)
        while result == -1 && errno == EINTR {
            result = waitpid(processID, &status, 0)
        }
        if result == -1 {
            throw SubprocessError.failedToWaitForExit(errorCode: Int(errno))
        }
        
        return Int(status)
    }
    
    // MARK: - Capture Output
    
    private func startCapturingOutput(io: SubprocessIO) throws {
        
        try io.outputPipe.closeWriteEnd()
        
        captureOutputThread = SubprocessCaptureThread(pipe: io.outputPipe)
        captureOutputThread?.start()
        
        try io.errorPipe.closeWriteEnd()
        
        captureErrorThread = SubprocessCaptureThread(pipe: io.errorPipe)
        captureErrorThread?.start()
    }
}
