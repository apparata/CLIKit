//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

public protocol IO {
    var `in`: Input { get }
    var out: Output { get }
    var error: Output { get }
}

public protocol Input {
    func readData() -> Data?
    func readDataToEndOfFile() -> Data?
    func readData(ofLength length: Int) -> Data?
    func read() -> String?
    func readToEndOfFile() -> String?
    func read(length: Int) -> String?
    func close()
}

public protocol Output {
    func write(_ data: Data)
    func write(_ string: String)
    func writeLine(_ string: String)
    func flush()
    func close()
}
