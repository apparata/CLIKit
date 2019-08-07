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

/// Given an array of Swift strings, the `CStrings` class copies the strings
/// as C strings using `strdup()`. When the `CStrings` object is deinitialized
/// the duplicated strings are deallocated.
class CStrings {
    
    /// Null terminated strdup'ed C strings.
    /// Do not access this array unless you know what you are doing.
    let cStrings: [UnsafeMutablePointer<Int8>?]
    
    init(_ strings: [String]) {
        cStrings = strings.map { string in
            string.withCString {
                // Make a copy of the C string.
                // This results in a malloc'ed string buffer.
                strdup($0)
            }
        } + [nil]
    }
    
    deinit {
        // We have to free() all the malloc()'ed string buffers.
        for case let cString? in cStrings {
            free(cString)
        }
    }
}

/// Given an dictionary of key/value Swift strings, the `KeyValueCStrings` class
/// creates strings on the form `"\(key)=\(value)"` and then copies the strings
/// as C strings using `strdup()`. When the `CStrings` object is deinitialized
/// the duplicated strings are deallocated.
class KeyValueCStrings: CStrings {
    
    init(_ keyValues: [String: String]) {
        super.init(keyValues.map { keyValue in
            "\(keyValue.key)=\(keyValue.value)"
        })
    }
}
