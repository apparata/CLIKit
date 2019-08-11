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
        var readCount = 0
        var stringData = Data.init(capacity: length * 2)
        while readCount < length {
            guard let data = readData(ofLength: 1) else {
                return nil
            }
            guard let firstByte: UInt8 = data.first else {
                return nil
            }
            stringData.append(data)
            var utfByteCount = 0
            if firstByte & UInt8(0b1100_0000) == 0b1100_0000,
                firstByte & UInt8(0b0010_0000) == 0 {
                // This is a 2 byte UTF-8 character.
                utfByteCount = 1
            } else if firstByte & UInt8(0b1110_0000) == 0b1110_0000,
                firstByte & UInt8(0b0001_0000) == 0 {
                // This is a 3 byte UTF-8 character.
                utfByteCount = 2
            } else if firstByte & 0b1111_0000 == 0b1111_0000,
                firstByte & 0b0000_1000 == 0 {
                // This is a 4 byte UTF-8 character.
                utfByteCount = 3
            }
            if utfByteCount > 0 {
                guard let additionalData = readData(ofLength: utfByteCount) else {
                    return nil
                }
                stringData.append(additionalData)
            }
            readCount += 1
        }
        return dataToString(stringData)
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

    public func write(_ character: Character) {
        write(String(character))
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
