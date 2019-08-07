//
//  Copyright © 2018 Apparata AB. All rights reserved.
//

import Foundation

public extension Path {
    
    fileprivate static var fileManager: FileManager {
        FileManager.default
    }
    
    fileprivate var fileManager: FileManager {
        FileManager.default
    }
    
    /// Note: No-op if file does not exist.
    func excludeFromBackup() throws {
        guard exists else {
            return
        }
        
        let mutableURL: NSURL = url as NSURL
        
        try mutableURL.setResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
    }
    
    var exists: Bool {
        fileManager.fileExists(atPath: internalPath)
    }
    
    var doesNotExist: Bool {
        !exists
    }
    
    var isFile: Bool {
        !isDirectory
    }
    
    var isDirectory: Bool {
        var isDirectory = ObjCBool(false)
        if fileManager.fileExists(atPath: internalPath, isDirectory: &isDirectory) {
            return isDirectory.boolValue
        }
        return false
    }
    
    var isDeletable: Bool {
        fileManager.isDeletableFile(atPath: internalPath)
    }
    
    var isExecutable: Bool {
        fileManager.isExecutableFile(atPath: internalPath)
    }
    
    var isReadable: Bool {
        fileManager.isReadableFile(atPath: internalPath)
    }
    
    var isWritable: Bool {
        fileManager.isWritableFile(atPath: internalPath)
    }
    
    func contentsOfDirectory(fullPaths: Bool = false) throws -> [Path] {
        let pathStrings = try fileManager.contentsOfDirectory(atPath: internalPath)
        let paths: [Path]
        if fullPaths {
            paths = pathStrings.map {
                self.appendingComponent($0)
            }
        } else {
            paths = pathStrings.map {
                Path($0)
            }
        }
        return paths
    }
    
    static var currentDirectory: Path {
        Path(fileManager.currentDirectoryPath)
    }
    
    static var homeDirectory: Path? {
        Path(NSHomeDirectory())
    }
            
    static var documentDirectory: Path? {
        if let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last {
            return Path(documentDirectory)
        } else {
            return nil
        }
    }
    
    static var cachesDirectory: Path {
        if let directory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last {
            return Path(directory)
        } else {
            fatalError("The Caches directory could not be found.")
        }
    }
    
    /// The application support directory typically does not exist at first.
    /// You need to create it if it doesn't exist. The getter of this variable
    /// will try to append the app bundle identifier to the path as recommended
    /// by Apple.
    static var applicationSupportDirectory: Path {
        if let directory = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).last {
            var appSupportPath = Path(directory)
            if let bundleIdentifier = Bundle.main.bundleIdentifier {
                appSupportPath = appSupportPath.appendingComponent(bundleIdentifier)
            }
            return appSupportPath
        } else {
            fatalError("The Application Support directory could not be found.")
        }
    }
    
    static var downloadsDirectory: Path? {
        if let documentDirectory = NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true).last {
            return Path(documentDirectory)
        } else {
            return nil
        }
    }
    
    static var desktopDirectory: Path? {
        if let documentDirectory = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true).last {
            return Path(documentDirectory)
        } else {
            return nil
        }
    }
    
    static var applicationsDirectory: Path? {
        if let documentDirectory = NSSearchPathForDirectoriesInDomains(.applicationDirectory, .userDomainMask, true).last {
            return Path(documentDirectory)
        } else {
            return nil
        }
    }
    
    func becomeCurrentDirectory() {
        fileManager.changeCurrentDirectoryPath(internalPath)
    }
    
    func createDirectory(withIntermediateDirectories createIntermediateDirectories: Bool = true, attributes: [FileAttributeKey: Any]? = nil) throws {
        try fileManager.createDirectory(at: URL(fileURLWithPath: internalPath, isDirectory: true), withIntermediateDirectories: createIntermediateDirectories, attributes: attributes)
    }
    
    func remove() throws {
        try fileManager.removeItem(at: url)
    }
    
    func copy(to toPath: Path) throws {
        try fileManager.copyItem(atPath: internalPath, toPath: toPath.internalPath)
    }

    func copy(to toPath: String) throws {
        try fileManager.copyItem(atPath: internalPath, toPath: toPath)
    }
    
    func copy(to toURL: URL) throws {
        try fileManager.copyItem(at: url, to: toURL)
    }
    
    func safeReplace(withItemAt itemPath: Path) throws -> URL? {
        let resultingURL = try fileManager.replaceItemAt(url,
                                                         withItemAt: itemPath.url,
                                                         backupItemName: itemPath.url.lastPathComponent + ".safeReplaceBackup",
                                                         options: .usingNewMetadataOnly)
        return resultingURL
    }
    
    /// Set POSIX file permissions. Same as chmod. Octal number is recommended.
    func setPosixPermissions(_ permissions: Int) throws {
        try fileManager.setAttributes([.posixPermissions: permissions],
                                      ofItemAtPath: internalPath)
    }
}

