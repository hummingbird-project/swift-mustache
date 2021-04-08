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
protocol HBMustacheSequence {
    /// Render section using template
    func renderSection(with template: HBMustacheTemplate, context: HBMustacheContext) -> String
    /// Render inverted section using template
    func renderInvertedSection(with template: HBMustacheTemplate, context: HBMustacheContext) -> String
}

extension Sequence {
    /// Render section using template
    func renderSection(with template: HBMustacheTemplate, context: HBMustacheContext) -> String {
        var string = ""
        var sequenceContext = HBMustacheSequenceContext(first: true)

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
    func renderInvertedSection(with template: HBMustacheTemplate, context: HBMustacheContext) -> String {
        var iterator = makeIterator()
        if iterator.next() == nil {
            return template.render(context: context.withObject(self))
        }
        return ""
    }
}

extension Array: HBMustacheSequence {}
extension Set: HBMustacheSequence {}
extension ReversedCollection: HBMustacheSequence {}
