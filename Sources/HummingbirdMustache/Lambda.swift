
/// Lambda function. Can add this to object being rendered to filter contents of objects.
///
/// See http://mustache.github.io/mustache.5.html for more details on
/// mustache lambdas
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
        callback = cb
    }

    internal func run(_ object: Any, _ template: HBMustacheTemplate) -> String {
        return callback(object, template)
    }
}
