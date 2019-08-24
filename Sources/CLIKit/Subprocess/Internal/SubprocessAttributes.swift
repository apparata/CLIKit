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

final class SubprocessAttributes {
    
    #if os(macOS)
    var attributes: posix_spawnattr_t? = nil
    #elseif os(Linux)
    var attributes: posix_spawnattr_t = posix_spawnattr_t()
    #endif
    
    init() {
        makeAttributes()
        clearSignals()
        restoreDefaultSignals()
        setUpProcessGroup()
    }
    
    deinit {
        destroyAttributes()
    }
    
    private func makeAttributes() {
        posix_spawnattr_init(&attributes)
    }
    
    private func destroyAttributes() {
        posix_spawnattr_destroy(&attributes)
    }
    
    private func clearSignals() {
        // Clear all signals
        var signals = sigset_t()
        sigemptyset(&signals)
        posix_spawnattr_setsigmask(&attributes, &signals)
    }
    
    private func restoreDefaultSignals() {
        // All signals except for SIGKILL and SIGSTOP
        var signals = sigset_t()
        sigfillset(&signals)
        sigdelset(&signals, SIGKILL)
        sigdelset(&signals, SIGSTOP)
        posix_spawnattr_setsigdefault(&attributes, &signals)
    }
    
    private func setUpProcessGroup() {
        posix_spawnattr_setpgroup(&attributes, 0)
        posix_spawnattr_setflags(&attributes,
                                 Int16(POSIX_SPAWN_SETSIGMASK
                                    | POSIX_SPAWN_SETSIGDEF
                                    | POSIX_SPAWN_SETPGROUP))
    }
}
