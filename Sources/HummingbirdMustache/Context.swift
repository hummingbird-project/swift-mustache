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

/// Context while rendering mustache tokens
struct HBMustacheContext {
    let stack: [Any]
    let sequenceContext: HBMustacheSequenceContext?
    let indentation: String?
    let inherited: [String: HBMustacheTemplate]?
    let contentType: HBMustacheContentType
    let library: HBMustacheLibrary?

    /// initialize context with a single objectt
    init(_ object: Any, library: HBMustacheLibrary? = nil) {
        self.stack = [object]
        self.sequenceContext = nil
        self.indentation = nil
        self.inherited = nil
        self.contentType = HBHTMLContentType()
        self.library = library
    }

    private init(
        stack: [Any],
        sequenceContext: HBMustacheSequenceContext?,
        indentation: String?,
        inherited: [String: HBMustacheTemplate]?,
        contentType: HBMustacheContentType,
        library: HBMustacheLibrary? = nil
    ) {
        self.stack = stack
        self.sequenceContext = sequenceContext
        self.indentation = indentation
        self.inherited = inherited
        self.contentType = contentType
        self.library = library
    }

    /// return context with object add to stack
    func withObject(_ object: Any) -> HBMustacheContext {
        var stack = self.stack
        stack.append(object)
        return .init(
            stack: stack,
            sequenceContext: nil,
            indentation: self.indentation,
            inherited: self.inherited,
            contentType: self.contentType,
            library: self.library
        )
    }

    /// return context with indent and parameter information for invoking a partial
    func withPartial(indented: String?, inheriting: [String: HBMustacheTemplate]?) -> HBMustacheContext {
        let indentation: String? = if let indented {
            (self.indentation ?? "") + indented
        } else {
            self.indentation
        }
        let inherits: [String: HBMustacheTemplate]? = if let inheriting {
            if let originalInherits = self.inherited {
                originalInherits.merging(inheriting) { value, _ in value }
            } else {
                inheriting
            }
        } else {
            self.inherited
        }
        return .init(
            stack: self.stack,
            sequenceContext: nil,
            indentation: indentation,
            inherited: inherits,
            contentType: HBHTMLContentType(),
            library: self.library
        )
    }

    /// return context with sequence info and sequence element added to stack
    func withSequence(_ object: Any, sequenceContext: HBMustacheSequenceContext) -> HBMustacheContext {
        var stack = self.stack
        stack.append(object)
        return .init(
            stack: stack,
            sequenceContext: sequenceContext,
            indentation: self.indentation,
            inherited: self.inherited,
            contentType: self.contentType,
            library: self.library
        )
    }

    /// return context with sequence info and sequence element added to stack
    func withContentType(_ contentType: HBMustacheContentType) -> HBMustacheContext {
        return .init(
            stack: self.stack,
            sequenceContext: self.sequenceContext,
            indentation: self.indentation,
            inherited: self.inherited,
            contentType: contentType,
            library: self.library
        )
    }
}
