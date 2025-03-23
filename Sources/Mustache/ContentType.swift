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

/// Protocol for content types
public protocol MustacheContentType: Sendable {
    /// escape text for this content type eg for HTML replace "<" with "&lt;"
    func escapeText(_ text: String) -> String
}

/// Text content type where no character is escaped
struct TextContentType: MustacheContentType {
    func escapeText(_ text: String) -> String {
        text
    }
}

/// HTML content where text is escaped for HTML output
struct HTMLContentType: MustacheContentType {
    func escapeText(_ text: String) -> String {
        text.htmlEscape()
    }
}

/// Map of strings to content types.
///
/// The string is read from the "CONTENT_TYPE" pragma `{{% CONTENT_TYPE: type}}`. Replace type with
/// the content type required. The default available types are `TEXT` and `HTML`. You can register your own
/// with `MustacheContentTypes.register`.
public enum MustacheContentTypes {
    static func get(_ name: String) -> MustacheContentType? {
        self.types[name]
    }

    /// Register new content type
    /// - Parameters:
    ///   - contentType: Content type
    ///   - name: String to identify it
    public static func register(_ contentType: MustacheContentType, named name: String) {
        self.types[name] = contentType
    }

    private static let _types: [String: MustacheContentType] = [
        "HTML": HTMLContentType(),
        "TEXT": TextContentType(),
    ]

    #if compiler(>=6)
    nonisolated(unsafe) static var types: [String: MustacheContentType] = _types
    #else
    static var types: [String: MustacheContentType] = _types
    #endif
}
