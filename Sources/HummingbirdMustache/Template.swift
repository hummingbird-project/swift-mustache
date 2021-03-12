
public class HBMustacheTemplate {
    public init(string: String) throws {
        self.tokens = try Self.parse(string)
    }

    internal init(_ tokens: [Token]) {
        self.tokens = tokens
    }
    
    enum Token {
        case text(String)
        case variable(String, String? = nil)
        case unescapedVariable(String)
        case section(String, HBMustacheTemplate)
        case invertedSection(String, HBMustacheTemplate)
        case partial(String)
    }

    let tokens: [Token]
}

