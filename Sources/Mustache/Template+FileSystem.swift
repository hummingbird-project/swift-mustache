//
// This source file is part of the Hummingbird server framework project
// Copyright (c) the Hummingbird authors
//
// See LICENSE.txt for license information
// SPDX-License-Identifier: Apache-2.0
//

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
        let template = try Self.parse(string)
        self.tokens = template.tokens
        self.text = string
        self.filename = filename
    }
}
