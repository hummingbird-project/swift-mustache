
public class HBMustacheTemplate {
    public init(string: String) throws {
        self.tokens = try Self.parse(string)
    }

    internal init(_ tokens: [Token]) {
        self.tokens = tokens
    }
    
    public func render(_ object: Any) -> String {
        self.render(object, context: nil)
    }
    
    internal func setLibrary(_ library: HBMustacheLibrary) {
        self.library = library
        for token in tokens {
            switch token {
            case .section(_, _, let template), .invertedSection(_, _, let template):
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
        case partial(String)
    }

    let tokens: [Token]
    var library: HBMustacheLibrary?
}

