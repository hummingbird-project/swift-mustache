
/// Context that current object is being rendered in. Only really relevant when rendering a sequence
struct HBMustacheContext: HBMustacheMethods {
    var first: Bool
    var last: Bool
    var index: Int

    init(first: Bool = false, last: Bool = false) {
        self.first = first
        self.last = last
        index = 0
    }

    /// Apply method to `HBMustacheContext`. These are available when processing elements
    /// of a sequence.
    ///
    /// Format your mustache as follows to accept them. They look like a function without any arguments
    /// ```
    /// {{#sequence}}{{index()}}{{/sequence}}
    /// ```
    ///
    /// Methods available are `first`, `last`, and `index`
    /// - Parameter name: Method name
    /// - Returns: Result
    func runMethod(_ name: String) -> Any? {
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
