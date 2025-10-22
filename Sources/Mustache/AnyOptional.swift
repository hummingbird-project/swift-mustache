//===----------------------------------------------------------------------===//
//
// This source file is part of the Hummingbird server framework project
//
// Copyright (c) 2021-2024 the Hummingbird authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See hummingbird/CONTRIBUTORS.txt for the list of Hummingbird authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

/// Internal protocol to allow testing if a variable contains a wrapped value
protocol AnyOptional {
    var anyWrapped: Any? { get }
}

/// Internal extension to allow testing if a variable contains a wrapped value
extension Optional: AnyOptional {
    var anyWrapped: Any? { self }
}
