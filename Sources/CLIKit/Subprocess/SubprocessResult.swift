//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

public class SubprocessResult {
    
    public let arguments: [String]
    
    public let status: Int
    
    public let captureOutputResult: Result<Data, Error>?
    
    public let captureErrorResult: Result<Data, Error>?
    
    public init(arguments: [String],
                status: Int,
                captureOutputResult: Result<Data, Error>?,
                captureErrorResult: Result<Data, Error>?) {
        self.arguments = arguments
        self.status = status
        self.captureOutputResult = captureOutputResult
        self.captureErrorResult = captureErrorResult
    }
    
    public func capturedOutputData() throws -> Data {
        guard let result = captureOutputResult else {
            throw SubprocessError.failedToCaptureOutput(errorCode: 1337)
        }
        switch result {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }
    
    public func capturedErrorData() throws -> Data {
        guard let result = captureErrorResult else {
            throw SubprocessError.failedToCaptureOutput(errorCode: 1337)
        }
        switch result {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }
    
    public func capturedOutputString() throws -> String {
        let data = try capturedOutputData()
        guard let string = String(data: data, encoding: .utf8) else {
            throw SubprocessError.dataIsNotUTF8
        }
        return string
    }

    public func capturedErrorString() throws -> String {
        let data = try capturedErrorData()
        guard let string = String(data: data, encoding: .utf8) else {
            throw SubprocessError.dataIsNotUTF8
        }
        return string
    }
}
