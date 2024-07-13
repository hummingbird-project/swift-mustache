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

/// Class holding Mustache template
public struct MustacheTemplate: Sendable {
    /// Initialize template
    /// - Parameter string: Template text
    /// - Throws: MustacheTemplate.Error
    public init(string: String) throws {
        self.tokens = try Self.parse(string)
    }

    /// Render object using this template
    /// - Parameter object: Object to render
    /// - Returns: Rendered text
    public func render(_ object: Any, library: MustacheLibrary? = nil) -> String {
        self.render(context: .init(object, library: library))
    }

    internal init(_ tokens: [Token]) {
        self.tokens = tokens
    }

    enum Token: Sendable {
        case text(String)
        case variable(name: String, transforms: [String] = [])
        case unescapedVariable(name: String, transforms: [String] = [])
        case section(name: String, transforms: [String] = [], template: MustacheTemplate)
        case invertedSection(name: String, transforms: [String] = [], template: MustacheTemplate)
        case inheritedSection(name: String, template: MustacheTemplate)
        case partial(String, indentation: String?, inherits: [String: MustacheTemplate]?)
        case contentType(MustacheContentType)
    }

    var tokens: [Token]
}
