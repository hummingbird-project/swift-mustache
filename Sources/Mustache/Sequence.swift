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

/// Protocol for objects that can be rendered as a sequence in Mustache
///
/// You're not supposed to manually conform to this protocol.
/// Instead, conform your type to `Sequence`, and then declare conformance to `MustacheSequence` too.
/// This way you'll get the automatically-synthesized conformance of `Sequence` to `MustacheSequence`.
///
/// ```swift
/// import Mustache
///
/// struct MyCustomMustacheSequence: Sequence {
/// /// Provide necessary declarations so the type conforms to `Sequence`
/// }
///
/// /// Receive the automatically-synthesized conformance to `MustacheSequence` for free.
/// extension MyCustomMustacheSequence: MustacheSequence {}
/// ```
public protocol MustacheSequence: Sequence {
    /// Render section using template
    func renderSection(with template: MustacheTemplate, context: MustacheContext) -> String
    /// Render inverted section using template
    func renderInvertedSection(with template: MustacheTemplate, context: MustacheContext) -> String
}

extension MustacheSequence {
    /// Render section using template
    public func renderSection(with template: MustacheTemplate, context: MustacheContext) -> String {
        var string = ""
        var sequenceContext = MustacheSequenceContext(first: true)

        var iterator = makeIterator()
        guard var currentObject = iterator.next() else { return "" }

        while let object = iterator.next() {
            string += template.render(context: context.withSequence(currentObject, sequenceContext: sequenceContext))
            currentObject = object
            sequenceContext.first = false
            sequenceContext.index += 1
        }

        sequenceContext.last = true
        string += template.render(context: context.withSequence(currentObject, sequenceContext: sequenceContext))

        return string
    }

    /// Render inverted section using template
    public func renderInvertedSection(with template: MustacheTemplate, context: MustacheContext) -> String {
        var iterator = makeIterator()
        if iterator.next() == nil {
            return template.render(context: context.withObject(self))
        }
        return ""
    }
}

extension Array: MustacheSequence {}
extension Set: MustacheSequence {}
extension ReversedCollection: MustacheSequence {}
