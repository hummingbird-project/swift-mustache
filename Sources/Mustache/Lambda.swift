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
///     let wrapped: MustacheLambda
/// }
/// let willy = Object(name: "Willy", wrapped: .init({ string in
///     return "<b>\(string)</b>"
/// }))
/// let mustache = "{{#wrapped}}{{name}} is awesome.{{/wrapped}}"
/// let template = try MustacheTemplate(string: mustache)
/// let output = template.render(willy)
/// print(output) // <b>Willy is awesome</b>
/// ```
///
public struct MustacheLambda {
    /// lambda callback
    public typealias Callback = (String) -> Any?

    let callback: Callback

    /// Initialize `MustacheLambda`
    /// - Parameter cb: function to be called by lambda
    public init(_ cb: @escaping Callback) {
        self.callback = cb
    }

    /// Initialize `MustacheLambda`
    /// - Parameter cb: function to be called by lambda
    public init(_ cb: @escaping () -> Any?) {
        self.callback = { _ in cb() }
    }

    internal func callAsFunction(_ s: String) -> Any? {
        return self.callback(s)
    }
}
