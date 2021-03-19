
/// Context that current object inside a sequence is being rendered in. Only relevant when rendering a sequence
struct HBMustacheSequenceContext: HBMustacheTransformable {
    var first: Bool
    var last: Bool
    var index: Int

    init(first: Bool = false, last: Bool = false) {
        self.first = first
        self.last = last
        index = 0
    }

    /// Transform `HBMustacheContext`. These are available when processing elements
    /// of a sequence.
    ///
    /// Format your mustache as follows to accept them. They look like a function without any arguments
    /// ```
    /// {{#sequence}}{{index()}}{{/sequence}}
    /// ```
    ///
    /// Transforms available are `first`, `last`, `index`, `even` and `odd`
    /// - Parameter name: Method name
    /// - Returns: Result
    func transform(_ name: String) -> Any? {
        switch name {
        case "first":
            return first
        case "last":
            return last
        case "index":
            return index
        case "even":
            return (index & 1) == 0
        case "odd":
            return (index & 1) == 1
        default:
            return nil
        }
    }
}
