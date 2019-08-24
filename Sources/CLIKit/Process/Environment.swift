//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

/// Gets and sets environment variables for the current process.
public class Environment {
        
    /// Returns a dictionary of all environment variables for
    /// the current process.
    public static var variables: [String: String] {
        return ProcessInfo.processInfo.environment
    }
        
    /// Class method that sets the value of the specificed environment variable.
    ///
    /// - Example:
    /// ```
    /// Environment.set("NAME", to: "VALUE")
    /// Environment.set("NAME", to: "VALUE", overwrite: false)
    /// ```
    ///
    /// - Parameters:
    ///   - variable: Name of variable to set.
    ///   - value: Value to set variable to, or nil to unset variable.
    ///   - overwrite: Indicate whether value should be overwritten or not.
    public static func set(_ name: String, to value: String?, overwrite: Bool = true) {
        if let value = value {
            setenv(name, value, overwrite ? 1 : 0)
        } else {
            unset(name)
        }
    }
    
    /// Class method that unsets the specified environment variable.
    ///
    /// - Example:
    /// ```
    /// Environment.unset("NAME")
    /// ```
    ///
    /// - Parameter variable: Name of the environment variable to unset.
    public static func unset(_ name: String) {
        unsetenv(name)
    }
    
    /// Gets or sets an environment variable using subscript syntax.
    ///
    /// - Example:
    /// ```
    /// let name = Environment["NAME"]
    /// Environment["NAME"] = "VALUE"
    /// Environment["NAME"] = nil
    /// ```
    ///
    /// - Parameter key: Variable to get or set.
    public static subscript(key: String) -> String? {
        get {
            return ProcessInfo.processInfo.environment[key]
        }
        set {
            guard let value = newValue else {
                unset(key)
                return
            }
            setenv(key, value, 1)
        }
    }
    
}
