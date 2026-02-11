//
// This source file is part of the Hummingbird server framework project
// Copyright (c) the Hummingbird authors
//
// See LICENSE.txt for license information
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

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

    private static let lock = NSLock()

    static func get(_ name: String) -> MustacheContentType? {
        lock.withLock {
            self.types[name]
        }
    }

    /// Register new content type
    /// - Parameters:
    ///   - contentType: Content type
    ///   - name: String to identify it
    public static func register(_ contentType: MustacheContentType, named name: String) {
        lock.withLock {
            self.types[name] = contentType
        }
    }

    private static let _types: [String: MustacheContentType] = [
        "HTML": HTMLContentType(),
        "TEXT": TextContentType(),
    ]

    #if compiler(>=6.0)
    nonisolated(unsafe) static var types: [String: MustacheContentType] = _types
    #else
    static var types: [String: MustacheContentType] = _types
    #endif
}
