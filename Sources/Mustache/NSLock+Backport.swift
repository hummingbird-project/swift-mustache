//
// This source file is part of the Hummingbird server framework project
// Copyright (c) the Hummingbird authors
//
// See LICENSE.txt for license information
// SPDX-License-Identifier: Apache-2.0
//

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
