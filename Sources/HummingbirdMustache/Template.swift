/// Class holding Mustache template
public final class HBMustacheTemplate {
    /// Initialize template
    /// - Parameter string: Template text
    /// - Throws: HBMustacheTemplate.Error
    public init(string: String) throws {
        tokens = try Self.parse(string)
    }

    /// Render object using this template
    /// - Parameter object: Object to render
    /// - Returns: Rendered text
    public func render(_ object: Any) -> String {
        render(object, context: nil)
    }

    internal init(_ tokens: [Token]) {
        self.tokens = tokens
    }

    internal func setLibrary(_ library: HBMustacheLibrary) {
        self.library = library
        for token in tokens {
            switch token {
            case let .section(_, _, template), let .invertedSection(_, _, template):
                template.setLibrary(library)
            default:
                break
            }
        }
    }

    enum Token {
        case text(String)
        case variable(name: String, method: String? = nil)
        case unescapedVariable(name: String, method: String? = nil)
        case section(name: String, method: String? = nil, template: HBMustacheTemplate)
        case invertedSection(name: String, method: String? = nil, template: HBMustacheTemplate)
        case partial(String, indentation: String?)
    }

    let tokens: [Token]
    var library: HBMustacheLibrary?
}
