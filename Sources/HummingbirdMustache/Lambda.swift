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

/// Lambda function. Can add this to object being rendered to filter contents of objects.
///
/// See http://mustache.github.io/mustache.5.html for more details on
/// mustache lambdas. Lambdas work slightly differently in HummingbirdMustache though
/// as they are passed a template representing the contained text and not the raw text
/// e.g
/// ```
/// struct Object {
///     let name: String
///     let wrapped: HBMustacheLambda
/// }
/// let willy = Object(name: "Willy", wrapped: .init({ object, template in
///     return "<b>\(template.render(object))</b>"
/// }))
/// let mustache = "{{#wrapped}}{{name}} is awesome.{{/wrapped}}"
/// let template = try HBMustacheTemplate(string: mustache)
/// let output = template.render(willy)
/// print(output) // <b>Willy is awesome</b>
/// ```
///
public struct HBMustacheLambda {
    /// lambda callback
    public typealias Callback = (Any, HBMustacheTemplate) -> String

    let callback: Callback

    /// Initialize `HBMustacheLambda`
    /// - Parameter cb: function to be called by lambda
    public init(_ cb: @escaping Callback) {
        self.callback = cb
    }

    internal func run(_ object: Any, _ template: HBMustacheTemplate) -> String {
        return self.callback(object, template)
    }
}
