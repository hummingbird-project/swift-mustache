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

import Foundation

protocol HBMustacheCustomRenderable {
    var renderText: String { get }
    var isNull: Bool { get }
}

extension HBMustacheCustomRenderable {
    var renderText: String { String(describing: self) }
    var isNull: Bool { false }
}

extension NSNull: HBMustacheCustomRenderable {
    public var renderText: String { "" }
    public var isNull: Bool { true }
}
