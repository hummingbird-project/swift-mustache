
public class HBMustacheTemplate {
    public init(string: String) throws {
        self.tokens = try Self.parse(string)
    }

    internal init(_ tokens: [Token]) {
        self.tokens = tokens
    }
    
    enum Token {
        case text(String)
        case variable(name: String, method: String? = nil)
        case unescapedVariable(name: String, method: String? = nil)
        case section(name: String, method: String? = nil, template: HBMustacheTemplate)
        case invertedSection(name: String, method: String? = nil, template: HBMustacheTemplate)
        case partial(String)
    }

    let tokens: [Token]
}

