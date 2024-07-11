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
        case variable(name: String, transform: String? = nil)
        case unescapedVariable(name: String, transform: String? = nil)
        case section(name: String, transform: String? = nil, template: MustacheTemplate)
        case invertedSection(name: String, transform: String? = nil, template: MustacheTemplate)
        case blockDefinition(name: String, template: MustacheTemplate)
        case blockExpansion(name: String, default: MustacheTemplate, indentation: String?)
        case partial(String, indentation: String?, inherits: [String: MustacheTemplate]?)
        case dynamicNamePartial(String, indentation: String?)
        case contentType(MustacheContentType)
    }

    var tokens: [Token]
}
