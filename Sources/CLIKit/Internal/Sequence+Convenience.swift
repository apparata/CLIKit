//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

internal extension Sequence {
    
    func filterByProperty<T>(_ keyPath: KeyPath<Element, T>, where condition: (T) -> Bool) -> [Element] {
        return filter { element in
            let value = element[keyPath: keyPath]
            return condition(value)
        }
    }
    
    func filterByProperty(_ keyPath: KeyPath<Element, String>, matching regex: Regex) -> [Element] {
        return filterByProperty(keyPath, where: { regex.isMatch($0) })
    }
    
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        return sorted { a, b in
            return a[keyPath: keyPath] < b[keyPath: keyPath]
        }
    }
}
