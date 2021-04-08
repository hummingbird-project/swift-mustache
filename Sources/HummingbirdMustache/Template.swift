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
public final class HBMustacheTemplate {
    /// Initialize template
    /// - Parameter string: Template text
    /// - Throws: HBMustacheTemplate.Error
    public init(string: String) throws {
        self.tokens = try Self.parse(string)
    }

    /// Render object using this template
    /// - Parameter object: Object to render
    /// - Returns: Rendered text
    public func render(_ object: Any) -> String {
        self.render(context: .init(object))
    }

    internal init(_ tokens: [Token]) {
        self.tokens = tokens
    }

    internal func setLibrary(_ library: HBMustacheLibrary) {
        self.library = library
        for token in self.tokens {
            switch token {
            case .section(_, _, let template), .invertedSection(_, _, let template), .inheritedSection(_, let template):
                template.setLibrary(library)
            case .partial(_, _, let templates):
                templates?.forEach { $1.setLibrary(library) }
            default:
                break
            }
        }
    }

    enum Token {
        case text(String)
        case variable(name: String, transform: String? = nil)
        case unescapedVariable(name: String, transform: String? = nil)
        case section(name: String, transform: String? = nil, template: HBMustacheTemplate)
        case invertedSection(name: String, transform: String? = nil, template: HBMustacheTemplate)
        case inheritedSection(name: String, template: HBMustacheTemplate)
        case partial(String, indentation: String?, inherits: [String: HBMustacheTemplate]?)
        case contentType(HBMustacheContentType)
    }

    let tokens: [Token]
    var library: HBMustacheLibrary?
}
