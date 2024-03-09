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

extension MustacheLibrary {
    /// Load templates from a folder
    static func loadTemplates(from directory: String, withExtension extension: String = "mustache") async throws -> [String: MustacheTemplate] {
        var directory = directory
        if !directory.hasSuffix("/") {
            directory += "/"
        }
        let extWithDot = ".\(`extension`)"
        let fs = FileManager()
        guard let enumerator = fs.enumerator(atPath: directory) else { return [:] }
        var templates: [String: MustacheTemplate] = [:]
        for case let path as String in enumerator {
            guard path.hasSuffix(extWithDot) else { continue }
            guard let data = fs.contents(atPath: directory + path) else { continue }
            let string = String(decoding: data, as: Unicode.UTF8.self)
            var template: MustacheTemplate
            do {
                template = try MustacheTemplate(string: string)
            } catch let error as MustacheTemplate.ParserError {
                throw ParserError(filename: path, context: error.context, error: error.error)
            }
            // drop ".mustache" from path to get name
            let name = String(path.dropLast(extWithDot.count))
            templates[name] = template
        }
        return templates
    }
}
