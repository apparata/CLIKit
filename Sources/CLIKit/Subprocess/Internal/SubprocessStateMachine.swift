//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

final class SubprocessStateMachine {
    
    var state: Subprocess.State {
        stateLock.lock()
        defer { stateLock.unlock() }
        return internalState
    }
    
    private var internalState: Subprocess.State = .initial
    
    private var stateLock = Lock()
    
    func enterSpawningState() throws {
        stateLock.lock()
        guard internalState == .initial else {
            stateLock.unlock()
            throw SubprocessError.alreadySpawned
        }
        internalState = .spawning
        stateLock.unlock()
    }
    
    func enterSpawnedState() {
        stateLock.lock()
        internalState = Subprocess.State.spawned
        stateLock.unlock()
    }
    
    func enterFinishedState() {
        stateLock.lock()
        internalState = Subprocess.State.finished
        stateLock.unlock()
    }
}
