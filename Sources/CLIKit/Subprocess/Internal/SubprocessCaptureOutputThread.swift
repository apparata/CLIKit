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

final class SubprocessCaptureThread: Thread {
    
    private let bufferChunkSize = 4096
    
    private var finishedCondition: NSCondition
    
    private var isThreadFinished: Bool
    
    private var pipe: SubprocessPipe
    
    private var result: Result<Data, Error>? = nil
    
    init(pipe: SubprocessPipe) {
        isThreadFinished = false
        finishedCondition = NSCondition()
        self.pipe = pipe
        super.init()
    }
    
    override func main() {
        finishedCondition.lock()
        
        result = readOutput(on: pipe)
        
        isThreadFinished = true
        finishedCondition.broadcast()
        
        finishedCondition.unlock()
    }
    
    @discardableResult
    public func join() -> Result<Data, Error>? {
        finishedCondition.lock()
        while !isThreadFinished {
            finishedCondition.wait()
        }
        finishedCondition.unlock()
        return result
    }
    
    private func readOutput(on pipe: SubprocessPipe) -> Result<Data, Error> {

        do {
            let data = try readLoop(on: pipe)
            try? pipe.closeReadEnd()
            return .success(Data(data))
        } catch let error {
            try? pipe.closeReadEnd()
            return .failure(error)
        }
    }
    
    private func readLoop(on pipe: SubprocessPipe) throws -> [UInt8] {
        
        var buffer = [UInt8](repeating: 0, count: bufferChunkSize + 1)
        var output = [UInt8]()
        
        while true {
            let readCount = read(pipe.readEnd, &buffer, bufferChunkSize)
            switch readCount {
            case  -1:
                if errno == EINTR {
                    continue
                } else {
                    throw SubprocessError.failedToCaptureOutput(errorCode: Int(errno))
                }
            case 0:
                return output
            default:
                output += buffer[0..<readCount]
            }
        }

    }
}
