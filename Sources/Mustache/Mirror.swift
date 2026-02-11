//
// This source file is part of the Hummingbird server framework project
// Copyright (c) the Hummingbird authors
//
// See LICENSE.txt for license information
// SPDX-License-Identifier: Apache-2.0
//

extension Mirror {
    /// Return value from Mirror given name
    func getValue(forKey key: String) -> Any? {
        guard let matched = children.filter({ $0.label == key }).first else {
            return nil
        }
        return unwrapOptional(matched.value)
    }
}

/// Return object and if it is an Optional return object Optional holds
private func unwrapOptional(_ object: Any) -> Any? {
    let mirror = Mirror(reflecting: object)
    guard mirror.displayStyle == .optional else { return object }
    guard let first = mirror.children.first else { return nil }
    return first.value
}
