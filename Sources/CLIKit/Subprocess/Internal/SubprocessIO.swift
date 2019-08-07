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

final class SubprocessIO {
    
    var actions: posix_spawn_file_actions_t? = nil
    
    private var devNull = strdup("/dev/null")
    
    private(set) var outputPipe = SubprocessPipe()
    
    private(set) var errorPipe = SubprocessPipe()
    
    init(captureOutput: Bool) throws {
        posix_spawn_file_actions_init(&actions)
        try setUp(captureOutput: captureOutput)
    }
    
    deinit {
        posix_spawn_file_actions_destroy(&actions)
        free(devNull)
    }
    
    private func setUp(captureOutput: Bool) throws {
        // Open /dev/null as stdin.
        posix_spawn_file_actions_addopen(&actions, 0, devNull, O_RDONLY, 0)
        
        if captureOutput {

            try outputPipe.open()
            try errorPipe.open()
            
            // Open the write end of the pipe as stdout and stderr
            posix_spawn_file_actions_adddup2(&actions, outputPipe.writeEnd, 1)
            posix_spawn_file_actions_adddup2(&actions, errorPipe.writeEnd, 2)
            
            // Close the other ends of the pipe.
            for pipe in [outputPipe, errorPipe] {
                posix_spawn_file_actions_addclose(&actions, pipe.readEnd)
                posix_spawn_file_actions_addclose(&actions, pipe.writeEnd)
            }
        } else {
            posix_spawn_file_actions_adddup2(&actions, 1, 1)
            posix_spawn_file_actions_adddup2(&actions, 2, 2)
        }
    }
}
