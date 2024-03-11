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

/// Context that current object inside a sequence is being rendered in. Only relevant when rendering a sequence
struct MustacheSequenceContext: MustacheTransformable {
    var first: Bool
    var last: Bool
    var index: Int

    init(first: Bool = false, last: Bool = false) {
        self.first = first
        self.last = last
        self.index = 0
    }

    /// Transform `MustacheContext`. These are available when processing elements
    /// of a sequence.
    ///
    /// Format your mustache as follows to accept them. They look like a function without any arguments
    /// ```
    /// {{#sequence}}{{index()}}{{/sequence}}
    /// ```
    ///
    /// Transforms available are `first`, `last`, `index`, `even` and `odd`
    /// - Parameter name: transform name
    /// - Returns: Result
    func transform(_ name: String) -> Any? {
        switch name {
        case "first":
            return self.first
        case "last":
            return self.last
        case "index":
            return self.index
        case "even":
            return (self.index & 1) == 0
        case "odd":
            return (self.index & 1) == 1
        default:
            return nil
        }
    }
}
