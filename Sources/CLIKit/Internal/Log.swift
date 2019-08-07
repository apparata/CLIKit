//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

#if canImport(os)
import os.log
#endif

public struct EnabledLogLevels: OptionSet {
    public let rawValue: Int

    public static let debug = EnabledLogLevels(rawValue: 1 << 0)
    public static let `default` = EnabledLogLevels(rawValue: 1 << 1)
    public static let info = EnabledLogLevels(rawValue: 1 << 2)
    public static let error = EnabledLogLevels(rawValue: 1 << 3)
    public static let fault = EnabledLogLevels(rawValue: 1 << 4)
    
    public static let all: EnabledLogLevels = [.debug, .default, .info, .error, .fault]
    
    public static let critical: EnabledLogLevels = [.error, .fault]
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

#if SWIFT_PACKAGE
public var enabledLogLevels: EnabledLogLevels = EnabledLogLevels.critical
#else
public var enabledLogLevels: EnabledLogLevels = EnabledLogLevels.all
#endif

#if canImport(os)
/// User of library can plug in their own OSLog object for the log here.
/// It will be used for subsequent logging.
public var moduleLog: OSLog? = {
    if #available(iOS 10, macOS 10.12, *) {
        return OSLog(subsystem: "se.apparata.foundation", category: "default")
    } else {
        return nil
    }
}()
#endif

#if canImport(os)
/// Debug-level messages are only captured in memory when debug logging is
/// enabled through a configuration change. They’re purged in accordance with
/// the configuration’s persistence setting. Messages logged at this level
/// contain information that may be useful during development or while
/// troubleshooting a specific problem. Debug logging is intended for use in
/// a development environment and not in shipping software.
///
/// **Example:**
/// ```
/// log("This is a debug level log.")
/// ```
internal func log(to: OSLog? = moduleLog, _ message: @autoclosure () -> String) {
    #if DEBUG
    guard enabledLogLevels.contains(.debug) else {
        return
    }
    if #available(iOS 10, macOS 10.12, *), let toLog = to {
        os_log("%@", log: toLog, type: .debug, message())
    } else {
        print(message())
    }
    #endif
}
#else
internal func log(_ message: @autoclosure () -> String) {
    #if DEBUG
    guard enabledLogLevels.contains(.debug) else {
        return
    }
    print(message())
    #endif
}
#endif

#if canImport(os)
/// Default-level messages are initially stored in memory buffers. Without a
/// configuration change, they are compressed and moved to the data store as
/// memory buffers fill. They remain there until a storage quota is exceeded,
/// at which point, the oldest messages are purged. Use this level to capture
/// information about things that might result a failure.
///
/// **Example:**
/// ```
/// log(default: "This is a default level log.")
/// ```
internal func log(to: OSLog? = moduleLog, default message: @autoclosure () -> String) {
    guard enabledLogLevels.contains(.default) else {
        return
    }
    if #available(iOS 10, macOS 10.12, *), let toLog = to  {
        os_log("%@", log: toLog, type: .default, message())
    } else {
        print(message())
    }
}
#else
internal func log(default message: @autoclosure () -> String) {
    guard enabledLogLevels.contains(.default) else {
        return
    }
    print(message())
}
#endif

#if canImport(os)
/// Info-level messages are initially stored in memory buffers. Without a
/// configuration change, they are not moved to the data store and are purged
/// as memory buffers fill. They are, however, captured in the data store
/// when faults and, optionally, errors occur. When info-level messages are
/// added to the data store, they remain there until a storage quota is
/// exceeded, at which point, the oldest messages are purged. Use this
/// level to capture information that may be helpful, but isn’t essential,
/// for troubleshooting errors.
///
/// **Example:**
/// ```
/// log(info: "This is an info level log.")
/// ```
internal func log(to: OSLog? = moduleLog, info message: @autoclosure () -> String) {
    guard enabledLogLevels.contains(.info) else {
        return
    }
    if #available(iOS 10, macOS 10.12, *), let toLog = to  {
        os_log("%@", log: toLog, type: .info, message())
    } else {
        print(message())
    }
}
#else
internal func log(info message: @autoclosure () -> String) {
    guard enabledLogLevels.contains(.info) else {
        return
    }
    print(message())
}
#endif

#if canImport(os)
/// Error-level messages are always saved in the data store. They remain there
/// until a storage quota is exceeded, at which point, the oldest messages are
/// purged. Error-level messages are intended for reporting process-level
/// errors. If an activity object exists, logging at this level captures
/// information for the entire process chain.
///
/// **Example:**
/// ```
/// log(error: "This is an error level log.")
/// ```
internal func log(to: OSLog? = moduleLog, error message: @autoclosure () -> String) {
    guard enabledLogLevels.contains(.error) else {
        return
    }
    if #available(iOS 10, macOS 10.12, *), let toLog = to  {
        os_log("%@", log: toLog, type: .error, message())
    } else {
        print(message())
    }
}
#else
internal func log(error message: @autoclosure () -> String) {
    guard enabledLogLevels.contains(.error) else {
        return
    }
    print(message())
}
#endif

#if canImport(os)
/// Fault-level messages are always saved in the data store. They remain there
/// until a storage quota is exceeded, at which point, the oldest messages are
/// purged. Fault-level messages are intended for capturing system-level or
/// multi-process errors only. If an activity object exists, logging at this
/// level captures information for the entire process chain.
///
/// **Example:**
/// ```
/// log(fault: "This is a fault level log.")
/// ```
internal func log(to: OSLog? = moduleLog, fault message: @autoclosure () -> String) {
    guard enabledLogLevels.contains(.fault) else {
        return
    }
    if #available(iOS 10, macOS 10.12, *), let toLog = to  {
        os_log("%@", log: toLog, type: .fault, message())
    } else {
        print(message())
    }
}
#else
internal func log(fault message: @autoclosure () -> String) {
    guard enabledLogLevels.contains(.fault) else {
        return
    }
    print(message())
}
#endif
