//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

class Lock {
    
    private let internalLock = NSLock()
    
    func lock() {
        internalLock.lock()
    }
    
    func unlock() {
        internalLock.unlock()
    }
    
    func run<T>(_ action: () throws -> T) rethrows -> T {
        internalLock.lock()
        defer {
            internalLock.unlock()
        }
        return try action()
    }
}
