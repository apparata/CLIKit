//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

public enum SubprocessError: LocalizedError {
    
    case failedToSpawn(errorCode: Int, arguments: [String])
    case failedToOpenPipe(errorCode: Int)
    case failedToClosePipe(errorCode: Int)
    case alreadySpawned
    case failedToCaptureOutput(errorCode: Int)
    case executableNotFound(name: String)
    case failedToWaitForExit(errorCode: Int)
    case dataIsNotUTF8
    case thereIsNoResult
    
    public var errorDescription: String? {
        switch self {
        case .failedToSpawn(let errorCode, let arguments):
            return "Error \(errorCode): Failed to launch subprocess with arguments: \(arguments)"
        case .failedToOpenPipe(let errorCode):
            return "Error \(errorCode): Failed to open pipe while launching subprocess."
        case .failedToClosePipe(let errorCode):
            return "Error \(errorCode): Failed to close pipe after running subprocess."
        case .alreadySpawned:
            return "Error: Failed to launch subprocess as it has already been launched."
        case .failedToCaptureOutput(let errorCode):
            return "Error \(errorCode): Failed to capture output from subprocess."
        case .executableNotFound(let name):
            return "Error: Cannot find the subprocess executable: \(name)"
        case .failedToWaitForExit(let errorCode):
            return "Error \(errorCode): Failed to wait for subprocess to exit."
        case .dataIsNotUTF8:
            return "Error: The requested data is not a UTF-8 compliant string."
        case .thereIsNoResult:
            return "Error: There is no subprocess result."
        }
    }
}
