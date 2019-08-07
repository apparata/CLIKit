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

public final class ExecutableFinder {
    
    static var lock = Lock()
    
    static var cachedPaths: [String: Path?] = [:]
    
    public static func find(_ name: String) -> Path? {
        
        guard !name.contains("/") else {
            // This is already a path.
            return Path(name)
        }
        
        let fileInCurrentDirectory = Path
            .currentDirectory
            .normalized
            .appendingComponent(name)
        if fileInCurrentDirectory.exists {
            return fileInCurrentDirectory
        }
        
        lock.lock()
        defer { lock.unlock() }
        
        if let cachedPath = cachedPaths[name] {
            return cachedPath
        }
        
        guard let pathVariable = Environment["PATH"] else {
            return nil
        }
        
        let paths = pathVariable.split(separator: ":").map {
            Path(String($0)).normalized.appendingComponent(name)
        }
        
        for path in paths {
            if path.exists && path.isExecutable {
                return path
            }
        }
                
        return nil
    }
}
