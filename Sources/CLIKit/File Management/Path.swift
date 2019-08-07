//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

/// Represents a file system path.
///
/// - Example:
/// ```
/// let absolutePath = Path("/usr/bin/zip")
/// absolutePath.isAbsolute
/// absolutePath.isRelative
///
/// let relativePath = Path("bin/whatever")
/// relativePath.isAbsolute
/// relativePath.isRelative
///
/// let concatenatedPath = Path("/usr") + Path("/bin")
///
/// let messyPath = Path("//usr/../usr/local/bin/./whatever")
/// messyPath.normalized
///
/// let pathFromLiteralString: Path = "/this/is/a/path"
/// let pathFromEmptyString: Path = ""
/// let pathFromConcatenatedStrings: Path = "/usr" + "/bin"
///
/// let pathFromComponents = Path(components: ["/", "usr/", "bin", "/", "swift"])
/// let pathFromEmptyComponents = Path(components: [])
///
/// let appendedPath = Path("/usr/local").appendingComponent("bin")
/// let appendedPath3 = Path("/usr/local").appending(Path("bin"))
/// let appendedPath2 = Path("/usr/local") + Path("bin")
///
/// let imagePath = Path("photos/photo").appendingExtension("jpg")
/// imagePath.extension
///
/// let imagePathWithoutExtension = imagePath.deletingExtension
/// let imagePathWithoutLastComponent = imagePath.deletingLastComponent
///
/// absolutePath.exists
/// absolutePath.isFile
/// absolutePath.isDirectory
/// absolutePath.isDeletable
/// absolutePath.isExecutable
/// absolutePath.isReadable
/// absolutePath.isWritable
/// ```
public struct Path {
    
    fileprivate var path: String
    
    var internalPath: String {
        path
    }
        
    public var isAbsolute: Bool {
        path.first == "/"
    }
    
    public var isRelative: Bool {
        !isAbsolute
    }
    
    public var normalized: Path {
        Path((path as NSString).standardizingPath)
    }
    
    public var string: String {
        path
    }
    
    public var url: URL {
        URL(fileURLWithPath: path)
    }
    
    public init() {
        path = "."
    }
    
    public init(_ path: String) {
        if path.isEmpty {
            self.path = "."
        } else {
            self.path = path
        }
    }
    
    public func appending(_ path: Path) -> Path {
        Path((self.path as NSString).appendingPathComponent(path.path))
    }
    
    public init<T: Collection>(components: T) where T.Iterator.Element == String {
        if components.isEmpty {
            path = "."
        } else {
            let strings: [String] = components.map { $0 }
            path = NSString.path(withComponents: strings)
        }
    }
    
    public var lastComponent: String {
        (path as NSString).lastPathComponent
    }
    
    public var deletingLastComponent: Path {
        Path((path as NSString).deletingLastPathComponent)
    }
    
    public func appendingComponent(_ string: String) -> Path {
        Path((path as NSString).appendingPathComponent(string))
    }
    
    public func replacingLastComponent(with string: String) -> Path {
        deletingLastComponent.appendingComponent(string)
    }
    
    public var `extension`: String {
        (path as NSString).pathExtension
    }
    
    public var deletingExtension: Path {
        Path((path as NSString).deletingPathExtension)
    }
    
    public func appendingExtension(_ string: String) -> Path {
        guard let newPath = (path as NSString).appendingPathExtension(string) else {
            // Not sure what could cause it to be nil, so here's a fallback plan.
            return Path(path + "." + string)
        }
        return Path(newPath)
    }
    
    public func replacingExtension(with string: String) -> Path {
        deletingExtension.appendingExtension(string)
    }
}

// MARK: - Object Description

extension Path: CustomStringConvertible {
    public var description: String {
        path
    }
}

// MARK: - String Literal Convertible

extension Path: ExpressibleByStringLiteral {
    public typealias UnicodeScalarLiteralType = StringLiteralType
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        path = "\(value)"
        if path.isEmpty {
            path = "."
        }
    }
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        path = value
        if path.isEmpty {
            path = "."
        }
    }
    
    public init(stringLiteral value: StringLiteralType) {
        path = value
        if path.isEmpty {
            path = "."
        }
    }
}

// MARK: - Hashable, Equatable, Comparable

extension Path: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }
}

extension Path: Equatable {
    
    public static func ==(lhs: Path, rhs: Path) -> Bool {
        lhs.path == rhs.path
    }
}

extension Path : Comparable {
 
    public static func <(lhs: Path, rhs: Path) -> Bool {
        lhs.path < rhs.path
    }
}

// MARK: - Concatenation

public func +(lhs: Path, rhs: Path) -> Path {
    lhs.appending(rhs)
}

public func +(lhs: Path, rhs: String) -> Path {
    lhs.appendingComponent(rhs)
}

