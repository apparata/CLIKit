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

public extension Character {
    
    var isEmoji: Bool {
        // swiftlint:disable force_unwrapping
        let emojiPatterns: [ClosedRange<UnicodeScalar>] = [
            UnicodeScalar(0x1F600)!...UnicodeScalar(0x1F64F)!,
            UnicodeScalar(0x1F300)!...UnicodeScalar(0x1F5FF)!,
            UnicodeScalar(0x1F680)!...UnicodeScalar(0x1F6FF)!,
            UnicodeScalar(0x2600)!...UnicodeScalar(0x26FF)!,
            UnicodeScalar(0x2700)!...UnicodeScalar(0x27BF)!,
            UnicodeScalar(0xFE00)!...UnicodeScalar(0xFE0F)!
        ]
        // swiftlint:enable force_unwrapping
        if let scalar = unicodeScalars.first {
            return emojiPatterns.contains { $0 ~= scalar }
        }
        return false
    }
        
    var isPrintable: Bool {
        if isLetter || isNumber || isPunctuation || isSymbol || isMathSymbol || isEmoji {
            return true
        }
        #if macOS
        if let scalar = unicodeScalars.first {
            return iswprint(wint_t(scalar.value)) != 0
        }
        #endif
        return false
    }
    
    var isBackspace: Bool {
        asciiValue == 127
    }
    
    var isCtrlA: Bool {
        asciiValue == 1
    }
    
    var isCtrlC: Bool {
        asciiValue == 3
    }

    var isCtrlD: Bool {
        asciiValue == 4
    }

    var isCtrlE: Bool {
        asciiValue == 5
    }

    var isCtrlK: Bool {
        asciiValue == 11
    }

    var isCtrlL: Bool {
        asciiValue == 12
    }

    var isCtrlT: Bool {
        asciiValue == 20
    }
    
    var isCtrlU: Bool {
        asciiValue == 21
    }
    
    var isEscape: Bool {
        asciiValue == 27
    }
}
