//
// This source file is part of the Hummingbird server framework project
// Copyright (c) the Hummingbird authors
//
// See LICENSE.txt for license information
// SPDX-License-Identifier: Apache-2.0
//

/// Class holding Mustache template
public struct MustacheTemplate: Sendable, CustomStringConvertible {
    /// Initialize template
    /// - Parameter string: Template text
    /// - Throws: MustacheTemplate.Error
    public init(string: String) throws {
        let template = try Self.parse(string)
        self.tokens = template.tokens
        self.text = string
        self.filename = nil
    }

    /// Render object using this template
    /// - Parameters
    ///   - object: Object to render
    ///   - library: library template uses to access partials
    /// - Returns: Rendered text
    public func render(_ object: Any, library: MustacheLibrary? = nil) -> String {
        self.render(context: .init(object, library: library))
    }

    /// Render object using this template
    /// - Parameters
    ///   - object: Object to render
    ///   - library: library template uses to access partials
    ///   - reload: Should I reload this template when rendering. This is only available in debug builds
    /// - Returns: Rendered text
    public func render(_ object: Any, library: MustacheLibrary? = nil, reload: Bool) -> String {
        #if DEBUG
        if reload {
            guard let filename else {
                preconditionFailure("Can only use reload if template was generated from a file")
            }
            do {
                guard let template = try MustacheTemplate(filename: filename) else { return "Cannot find template at \(filename)" }
                return template.render(context: .init(object, library: library, reloadPartials: reload))
            } catch {
                return "\(error)"
            }
        }
        #endif
        return self.render(context: .init(object, library: library))
    }

    internal init(_ tokens: [Token], text: String) {
        self.tokens = tokens
        self.filename = nil
        self.text = text
    }

    public var description: String { self.text }

    enum Token: Sendable /* , CustomStringConvertible */ {
        case text(String)
        case variable(name: String, transforms: [String] = [])
        case unescapedVariable(name: String, transforms: [String] = [])
        case section(name: String, transforms: [String] = [], template: MustacheTemplate)
        case invertedSection(name: String, transforms: [String] = [], template: MustacheTemplate)
        case blockDefinition(name: String, template: MustacheTemplate)
        case blockExpansion(name: String, default: MustacheTemplate, indentation: String?)
        case partial(String, indentation: String?, inherits: [String: MustacheTemplate]?)
        case dynamicNamePartial(String, indentation: String?, inherits: [String: MustacheTemplate]?)
        case contentType(MustacheContentType)
    }

    var tokens: [Token]
    let text: String
    let filename: String?
}
