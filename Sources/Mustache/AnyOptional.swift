//
// This source file is part of the Hummingbird server framework project
// Copyright (c) the Hummingbird authors
//
// See LICENSE.txt for license information
// SPDX-License-Identifier: Apache-2.0
//

/// Internal protocol to allow testing if a variable contains a wrapped value
protocol AnyOptional {
    var anyWrapped: Any? { get }
}

/// Internal extension to allow testing if a variable contains a wrapped value
extension Optional: AnyOptional {
    var anyWrapped: Any? { self }
}
