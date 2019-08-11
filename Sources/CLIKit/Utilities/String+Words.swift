//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

public extension String {
    
    func wordRange(at index: Int) -> Range<String.Index>? {
        let clampedIndex = min(index, count - 1)
        let tagger = NSLinguisticTagger(tagSchemes: [NSLinguisticTagScheme.tokenType], options: 0)
        var range: NSRange = NSMakeRange(0, 0)
        tagger.string = self
        tagger.tag(at: clampedIndex, scheme: NSLinguisticTagScheme.tokenType, tokenRange: &range, sentenceRange: nil)
        return Range(range, in: self)
    }

    func word(at index: Int) -> (String, Range<String.Index>)? {
        guard let range = wordRange(at: index) else {
            return nil
        }
        return (String(self[range]), range)
    }
}
