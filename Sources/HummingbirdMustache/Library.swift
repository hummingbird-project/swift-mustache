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

/// Class holding a collection of mustache templates.
///
/// Each template can reference the others via a partial using the name the template is registered under
/// ```
/// {{#sequence}}{{>entry}}{{/sequence}}
/// ```
public struct HBMustacheLibrary: Sendable {
    /// Initialize empty library
    public init() {
        self.templates = [:]
    }

    /// Initialize library with contents of folder.
    ///
    /// Each template is registered with the name of the file minus its extension. The search through
    /// the folder is recursive and templates in subfolders will be registered with the name `subfolder/template`.
    /// - Parameter directory: Directory to look for mustache templates
    /// - Parameter extension: Extension of files to look for
    public init(templates: [String: HBMustacheTemplate]) {
        self.templates = templates
    }

    /// Initialize library with contents of folder.
    ///
    /// Each template is registered with the name of the file minus its extension. The search through
    /// the folder is recursive and templates in subfolders will be registered with the name `subfolder/template`.
    /// - Parameter directory: Directory to look for mustache templates
    /// - Parameter extension: Extension of files to look for
    public init(directory: String, withExtension extension: String = "mustache") async throws {
        self.templates = try await Self.loadTemplates(from: directory, withExtension: `extension`)
    }

    /// Register template under name
    /// - Parameters:
    ///   - template: Template
    ///   - name: Name of template
    public mutating func register(_ template: HBMustacheTemplate, named name: String) {
        self.templates[name] = template
    }

    /// Register template under name
    /// - Parameters:
    ///   - mustache: Mustache text
    ///   - name: Name of template
    public mutating func register(_ mustache: String, named name: String) throws {
        let template = try HBMustacheTemplate(string: mustache)
        self.templates[name] = template
    }

    /// Return template registed with name
    /// - Parameter name: name to search for
    /// - Returns: Template
    public func getTemplate(named name: String) -> HBMustacheTemplate? {
        self.templates[name]
    }

    /// Render object using templated with name
    /// - Parameters:
    ///   - object: Object to render
    ///   - name: Name of template
    /// - Returns: Rendered text
    public func render(_ object: Any, withTemplate name: String) -> String? {
        guard let template = templates[name] else { return nil }
        return template.render(object, library: self)
    }

    /// Error returned by init() when parser fails
    public struct ParserError: Swift.Error {
        /// File error occurred in
        public let filename: String
        /// Context (line, linenumber and column number)
        public let context: HBParser.Context
        /// Actual error that occurred
        public let error: Error
    }

    private var templates: [String: HBMustacheTemplate]
}
