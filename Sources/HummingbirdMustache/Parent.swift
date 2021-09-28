//===----------------------------------------------------------------------===//
//
// This source file is part of the Hummingbird server framework project
//
// Copyright (c) 2021-2021 the Hummingbird authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See hummingbird/CONTRIBUTORS.txt for the list of Hummingbird authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

/// Protocol for object that has a custom method for accessing their children, instead
/// of using Mirror
public protocol HBMustacheParent {
    func child(named: String) -> Any?
}

/// Extend dictionary where the key is a string so that it uses the key values to access
/// it values
extension Dictionary: HBMustacheParent where Key == String {
    public func child(named: String) -> Any? { return self[named] }
}
