//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

public final class StandardIO: IO {
    public let `in`: Input = StandardInput()
    public let out: Output = StandardOutput()
    public let error: Output = StandardError()
}

public final class StandardInput: Input, WrapsFileHandle {
    
    public let fileHandle = FileHandle.standardInput
    
    public func readData() -> Data? {
        let data = fileHandle.availableData
        if data.isEmpty {
            return nil
        }
        return data
    }
    
    public func readDataToEndOfFile() -> Data? {
        let data = fileHandle.readDataToEndOfFile()
        if data.isEmpty {
            return nil
        }
        return data
    }
    
    public func readData(ofLength length: Int) -> Data? {
        let data = fileHandle.readData(ofLength: length)
        if data.isEmpty {
            return nil
        }
        return data
    }
    
    public func read() -> String? {
        return dataToString(readData())
    }
    
    public func readToEndOfFile() -> String? {
        return dataToString(readDataToEndOfFile())
    }
    
    public func read(length: Int) -> String? {
        return dataToString(readData(ofLength: length))
    }
    
    public func close() {
        fileHandle.closeFile()
    }
    
    private func dataToString(_ data: Data?) -> String? {
        guard let data = data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}

public class StandardBaseOutput: Output, WrapsFileHandle {
    
    public let fileHandle: FileHandle
    
    init(fileHandle: FileHandle) {
        self.fileHandle = fileHandle
    }
    
    public func write(_ data: Data) {
        fileHandle.write(data)
    }
    
    public func write(_ string: String) {
        guard let data = string.data(using: .utf8) else {
            fatalError("String could not be encoded as UTF-8.")
        }
        fileHandle.write(data)
    }
    
    public func writeLine(_ string: String) {
        write(string)
        write("\n")
    }
    
    public func flush() {
        fileHandle.synchronizeFile()
    }
    
    public func close() {
        fileHandle.closeFile()
    }
}

public final class StandardOutput: StandardBaseOutput {
    
    init() {
        super.init(fileHandle: FileHandle.standardOutput)
    }
}

public final class StandardError: StandardBaseOutput {

    init() {
        super.init(fileHandle: FileHandle.standardError)
    }
}
