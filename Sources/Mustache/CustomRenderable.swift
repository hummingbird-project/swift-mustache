//
// This source file is part of the Hummingbird server framework project
// Copyright (c) the Hummingbird authors
//
// See LICENSE.txt for license information
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Allow object to override standard hummingbird type rendering which uses
/// `String(describing)`.
public protocol MustacheCustomRenderable {
    /// Custom rendered version of object
    var renderText: String { get }
    /// Whether the object is a null object. Used when scoping sections
    var isNull: Bool { get }
}

extension MustacheCustomRenderable {
    /// default version returning the standard rendering
    var renderText: String { String(describing: self) }
    /// default version returning false
    var isNull: Bool { false }
}

/// Extend NSNull to conform to `MustacheCustomRenderable` to avoid outputting `<null>` and returning
/// a valid response for `isNull`
extension NSNull: MustacheCustomRenderable {
    public var renderText: String { "" }
    public var isNull: Bool { true }
}
