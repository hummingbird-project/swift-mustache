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

import Foundation

extension MustacheTemplate {
    /// Render template using object
    /// - Parameters:
    ///   - stack: Object
    ///   - context: Context that render is occurring in. Contains information about position in sequence
    ///   - indentation: indentation of partial
    /// - Returns: Rendered text
    func render(context: MustacheContext) -> String {
        var string = ""
        var context = context

        if let indentation = context.indentation, indentation != "" {
            for token in tokens {
                let renderedString = self.renderToken(token, context: &context)
                if renderedString != "", string.last == "\n" {
                    string += indentation
                }
                string += renderedString
            }
        } else {
            for token in tokens {
                let result = self.renderToken(token, context: &context)
                string += result
            }
        }
        return string
    }

    func renderToken(_ token: Token, context: inout MustacheContext) -> String {
        switch token {
        case .text(let text):
            return text
        case .variable(let variable, let transforms):
            if let child = getChild(named: variable, transforms: transforms, context: context) {
                if let template = child as? MustacheTemplate {
                    return template.render(context: context)
                } else if let renderable = child as? MustacheCustomRenderable {
                    return context.contentType.escapeText(renderable.renderText)
                } else {
                    return context.contentType.escapeText(String(describing: child))
                }
            }
        case .unescapedVariable(let variable, let transforms):
            if let child = getChild(named: variable, transforms: transforms, context: context) {
                if let renderable = child as? MustacheCustomRenderable {
                    return renderable.renderText
                } else {
                    return String(describing: child)
                }
            }
        case .section(let variable, let transforms, let template):
            let child = self.getChild(named: variable, transforms: transforms, context: context)
            return self.renderSection(child, with: template, context: context)

        case .invertedSection(let variable, let transforms, let template):
            let child = self.getChild(named: variable, transforms: transforms, context: context)
            return self.renderInvertedSection(child, with: template, context: context)

        case .inheritedSection(let name, let template):
            if let override = context.inherited?[name] {
                return override.render(context: context)
            } else {
                return template.render(context: context)
            }

        case .partial(let name, let indentation, let overrides):
            if let template = context.library?.getTemplate(named: name) {
                return template.render(context: context.withPartial(indented: indentation, inheriting: overrides))
            }

        case .contentType(let contentType):
            context = context.withContentType(contentType)
        }
        return ""
    }

    /// Render a section
    /// - Parameters:
    ///   - child: Object to render section for
    ///   - parent: Current object being rendered
    ///   - template: Template to render with
    /// - Returns: Rendered text
    func renderSection(_ child: Any?, with template: MustacheTemplate, context: MustacheContext) -> String {
        switch child {
        case let array as MustacheSequence:
            return array.renderSection(with: template, context: context)
        case let bool as Bool:
            return bool ? template.render(context: context) : ""
        case let lambda as MustacheLambda:
            return lambda.run(context.stack.last!, template)
        case let null as MustacheCustomRenderable where null.isNull == true:
            return ""
        case .some(let value):
            return template.render(context: context.withObject(value))
        case .none:
            return ""
        }
    }

    /// Render an inverted section
    /// - Parameters:
    ///   - child: Object to render section for
    ///   - parent: Current object being rendered
    ///   - template: Template to render with
    /// - Returns: Rendered text
    func renderInvertedSection(_ child: Any?, with template: MustacheTemplate, context: MustacheContext) -> String {
        switch child {
        case let array as MustacheSequence:
            return array.renderInvertedSection(with: template, context: context)
        case let bool as Bool:
            return bool ? "" : template.render(context: context)
        case let null as MustacheCustomRenderable where null.isNull == true:
            return template.render(context: context)
        case .some:
            return ""
        case .none:
            return template.render(context: context)
        }
    }

    /// Get child object from variable name
    func getChild(named name: String, transforms: [String], context: MustacheContext) -> Any? {
        func _getImmediateChild(named name: String, from object: Any) -> Any? {
            if let customBox = object as? MustacheParent {
                return customBox.child(named: name)
            } else {
                let mirror = Mirror(reflecting: object)
                return mirror.getValue(forKey: name)
            }
        }

        func _getChild(named names: ArraySlice<String>, from object: Any) -> Any? {
            guard let name = names.first else { return object }
            guard let childObject = _getImmediateChild(named: name, from: object) else { return nil }
            let names2 = names.dropFirst()
            return _getChild(named: names2, from: childObject)
        }

        func _getChildInStack(named names: ArraySlice<String>, from stack: [Any]) -> Any? {
            guard let name = names.first else { return stack.last }
            for object in stack.reversed() {
                if let childObject = _getImmediateChild(named: name, from: object) {
                    let names2 = names.dropFirst()
                    return _getChild(named: names2, from: childObject)
                }
            }
            return nil
        }

        // work out which object to access. "." means the current object, if the variable name is ""
        // and we have a transform to run on the variable then we need the context object, otherwise
        // the name is split by "." and we use mirror to get the correct child object. If we cannot find
        // the root object we look up the context stack until we can find one with a matching name. The
        // stack climbing can be disabled by prefixing the variable name with a "."
        let child: Any?
        if name == "." {
            child = context.stack.last!
        } else if name == "", !transforms.isEmpty {
            child = context.sequenceContext
        } else if name.first == "." {
            let nameSplit = name.split(separator: ".").map { String($0) }
            child = _getChild(named: nameSplit[...], from: context.stack.last!)
        } else {
            let nameSplit = name.split(separator: ".").map { String($0) }
            child = _getChildInStack(named: nameSplit[...], from: context.stack)
        }

        // skip transforms if child is already nil
        guard var child else {
            return nil
        }

        // if we want to run a transform and the current child can have transforms applied to it then
        // run transform on the current child
        for transform in transforms.reversed() {
            if let runnable = child as? MustacheTransformable,
               let transformed = runnable.transform(transform) 
            {
                child = transformed
                continue
            }

            // return nil if transform is unsuccessful or has returned nil
            return nil
        }

        return child
    }
}
