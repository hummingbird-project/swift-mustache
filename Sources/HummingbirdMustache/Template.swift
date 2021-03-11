
enum HBMustacheError: Error {
    case sectionCloseNameIncorrect
    case unfinishedSectionName
    case expectedSectionEnd
}

public class HBTemplate {
    public init(_ string: String) throws {
        self.tokens = try Self.parse(string)
    }

    internal init(_ tokens: [Token]) {
        self.tokens = tokens
    }
    
    enum Token {
        case text(String)
        case variable(String)
        case section(String, HBTemplate)
        case invertedSection(String, HBTemplate)
    }

    let tokens: [Token]
}

