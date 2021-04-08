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
