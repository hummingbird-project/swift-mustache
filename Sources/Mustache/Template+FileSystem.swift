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

import Foundation

extension MustacheTemplate {
    /// Internal function to load a template from a file
    /// - Parameters
    ///   - string: Template text
    ///   - filename: File template was loaded from
    /// - Throws: MustacheTemplate.Error
    init?(filename: String) throws {
        let fs = FileManager()
        guard let data = fs.contents(atPath: filename) else { return nil }
        let string = String(decoding: data, as: Unicode.UTF8.self)
        self.tokens = try Self.parse(string)
        self.filename = filename
    }
}
