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

#if compiler(<6.0)
import Foundation

extension NSLock {
    func withLock<Value>(_ operation: () throws -> Value) rethrows -> Value {
        self.lock()
        defer {
            self.unlock()
        }
        return try operation()
    }
}
#endif
