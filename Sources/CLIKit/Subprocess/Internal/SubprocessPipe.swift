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

final class SubprocessPipe {
    
    private var internalPipe: [Int32]
    
    var readEnd: Int32 {
        return internalPipe[0]
    }
    
    var writeEnd: Int32 {
        return internalPipe[1]
    }
    
    init() {
        internalPipe = [0, 0]
    }
    
    func open() throws {
        guard pipe(&internalPipe) == 0 else {
            throw SubprocessError.failedToOpenPipe(errorCode: Int(errno))
        }
    }
    
    func closeWriteEnd() throws {
        guard close(writeEnd) == 0 else {
            throw SubprocessError.failedToClosePipe(errorCode: Int(errno))
        }
    }
    
    func closeReadEnd() throws {
        guard close(readEnd) == 0 else {
            throw SubprocessError.failedToClosePipe(errorCode: Int(errno))
        }
    }
}
