//
// This source file is part of the Hummingbird server framework project
// Copyright (c) the Hummingbird authors
//
// See LICENSE.txt for license information
// SPDX-License-Identifier: Apache-2.0
//

/// Protocol for objects that can be rendered as a sequence in Mustache
public protocol MustacheSequence: Sequence {}

extension MustacheSequence {
    /// Render section using template
    func renderSection(with template: MustacheTemplate, context: MustacheContext) -> String {
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
    func renderInvertedSection(with template: MustacheTemplate, context: MustacheContext) -> String {
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
