
extension HBMustacheTemplate {
    enum Error: Swift.Error {
        case sectionCloseNameIncorrect
        case unfinishedName
        case expectedSectionEnd
    }

    static func parse(_ string: String) throws -> [Token] {
        var parser = HBParser(string)
        return try parse(&parser, sectionName: nil)
    }

    static func parse(_ parser: inout HBParser, sectionName: String?) throws -> [Token] {
        var tokens: [Token] = []
        while !parser.reachedEnd() {
            let text = try parser.read(untilString: "{{", throwOnOverflow: false, skipToEnd: true)
            if text.count > 0 {
                tokens.append(.text(text.string))
            }
            if parser.reachedEnd() {
                break
            }
            switch parser.current() {
            case "#":
                parser.unsafeAdvance()
                let name = try parseName(&parser)
                if parser.current() == "\n" {
                    parser.unsafeAdvance()
                }
                let sectionTokens = try parse(&parser, sectionName: name)
                tokens.append(.section(name, HBMustacheTemplate(sectionTokens)))

            case "^":
                parser.unsafeAdvance()
                let name = try parseName(&parser)
                if parser.current() == "\n" {
                    parser.unsafeAdvance()
                }
                let sectionTokens = try parse(&parser, sectionName: name)
                tokens.append(.invertedSection(name, HBMustacheTemplate(sectionTokens)))

            case "/":
                parser.unsafeAdvance()
                let name = try parseName(&parser)
                guard name == sectionName else {
                    throw Error.sectionCloseNameIncorrect
                }
                if parser.current() == "\n" {
                    parser.unsafeAdvance()
                }
                return tokens

            case "{":
                parser.unsafeAdvance()
                let name = try parseName(&parser)
                guard try parser.read("}") else { throw Error.unfinishedName }
                tokens.append(.unescapedVariable(name))

            case "!":
                parser.unsafeAdvance()
                _ = try parseComment(&parser)

            case ">":
                parser.unsafeAdvance()
                let name = try parseName(&parser)
                tokens.append(.partial(name))

            default:
                let name = try parseName(&parser)
                tokens.append(.variable(name))
            }
        }
        // should never get here if reading section
        guard sectionName == nil else {
            throw Error.expectedSectionEnd
        }
        return tokens
    }

    static func parseName(_ parser: inout HBParser) throws -> String {
        parser.read(while: \.isWhitespace)
        let text = parser.read(while: sectionNameChars )
        parser.read(while: \.isWhitespace)
        guard try parser.read("}"), try parser.read("}") else { throw Error.unfinishedName }
        return text.string
    }

    static func parseComment(_ parser: inout HBParser) throws -> String {
        let text = try parser.read(untilString: "}}", throwOnOverflow: true, skipToEnd: true)
        return text.string
    }
    
    private static let sectionNameChars = Set<Unicode.Scalar>("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ._?")
}
