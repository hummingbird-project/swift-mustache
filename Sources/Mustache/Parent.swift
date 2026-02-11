//
// This source file is part of the Hummingbird server framework project
// Copyright (c) the Hummingbird authors
//
// See LICENSE.txt for license information
// SPDX-License-Identifier: Apache-2.0
//

/// Protocol for object that has a custom method for accessing their children, instead
/// of using Mirror
public protocol MustacheParent {
    func child(named: String) -> Any?
}

/// Extend dictionary where the key is a string so that it uses the key values to access
/// it values
extension Dictionary: MustacheParent where Key == String {
    public func child(named: String) -> Any? { self[named] }
}
