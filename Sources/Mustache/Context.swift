//
// This source file is part of the Hummingbird server framework project
// Copyright (c) the Hummingbird authors
//
// See LICENSE.txt for license information
// SPDX-License-Identifier: Apache-2.0
//

/// Context while rendering mustache tokens
struct MustacheContext {
    let stack: [Any]
    let sequenceContext: MustacheSequenceContext?
    let indentation: String?
    let inherited: [String: MustacheTemplate]?
    let contentType: MustacheContentType
    let library: MustacheLibrary?
    let reloadPartials: Bool

    /// initialize context with a single objectt
    init(_ object: Any, library: MustacheLibrary? = nil, reloadPartials: Bool = false) {
        self.stack = [object]
        self.sequenceContext = nil
        self.indentation = nil
        self.inherited = nil
        self.contentType = HTMLContentType()
        self.library = library
        self.reloadPartials = reloadPartials
    }

    private init(
        stack: [Any],
        sequenceContext: MustacheSequenceContext?,
        indentation: String?,
        inherited: [String: MustacheTemplate]?,
        contentType: MustacheContentType,
        library: MustacheLibrary? = nil,
        reloadPartials: Bool
    ) {
        self.stack = stack
        self.sequenceContext = sequenceContext
        self.indentation = indentation
        self.inherited = inherited
        self.contentType = contentType
        self.library = library
        self.reloadPartials = reloadPartials
    }

    /// return context with object add to stack
    func withObject(_ object: Any) -> MustacheContext {
        var stack = self.stack
        stack.append(object)
        return .init(
            stack: stack,
            sequenceContext: nil,
            indentation: self.indentation,
            inherited: self.inherited,
            contentType: self.contentType,
            library: self.library,
            reloadPartials: self.reloadPartials
        )
    }

    /// return context with indent and parameter information for invoking a partial
    func withPartial(indented: String?, inheriting: [String: MustacheTemplate]?) -> MustacheContext {
        let indentation: String?
        if let indented {
            indentation = (self.indentation ?? "") + indented
        } else {
            indentation = self.indentation
        }
        let inherits: [String: MustacheTemplate]?
        if let inheriting {
            if let originalInherits = self.inherited {
                inherits = originalInherits.merging(inheriting) { value, _ in value }
            } else {
                inherits = inheriting
            }
        } else {
            inherits = self.inherited
        }
        return .init(
            stack: self.stack,
            sequenceContext: nil,
            indentation: indentation,
            inherited: inherits,
            contentType: HTMLContentType(),
            library: self.library,
            reloadPartials: self.reloadPartials
        )
    }

    /// return context with indent information for invoking an inheritance block
    func withBlockExpansion(indented: String?) -> MustacheContext {
        let indentation: String?
        if let indented {
            indentation = (self.indentation ?? "") + indented
        } else {
            indentation = self.indentation
        }
        return .init(
            stack: self.stack,
            sequenceContext: nil,
            indentation: indentation,
            inherited: self.inherited,
            contentType: self.contentType,
            library: self.library,
            reloadPartials: self.reloadPartials
        )
    }

    /// return context with sequence info and sequence element added to stack
    func withSequence(_ object: Any, sequenceContext: MustacheSequenceContext) -> MustacheContext {
        var stack = self.stack
        stack.append(object)
        return .init(
            stack: stack,
            sequenceContext: sequenceContext,
            indentation: self.indentation,
            inherited: self.inherited,
            contentType: self.contentType,
            library: self.library,
            reloadPartials: self.reloadPartials
        )
    }

    /// return context with sequence info and sequence element added to stack
    func withContentType(_ contentType: MustacheContentType) -> MustacheContext {
        .init(
            stack: self.stack,
            sequenceContext: self.sequenceContext,
            indentation: self.indentation,
            inherited: self.inherited,
            contentType: contentType,
            library: self.library,
            reloadPartials: self.reloadPartials
        )
    }
}
