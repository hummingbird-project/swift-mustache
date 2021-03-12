
extension HBMustacheTemplate {
    static func parse(_ string: String) throws -> [Token] {
        var parser = HBParser(string)
        return try parse(&parser, sectionName: nil)
    }

    static func parse(_ parser: inout HBParser, sectionName: String?) throws -> [Token] {
        var tokens: [Token] = []
        while !parser.reachedEnd() {
            let text = try parser.read(untilString: "{{", throwOnOverflow: false, skipToEnd: true)
            tokens.append(.text(text.string))
            if parser.reachedEnd() {
                break
            }
            switch parser.current() {
            case "#":
                parser.unsafeAdvance()
                let name = try parseSectionName(&parser)
                if parser.current() == "\n" {
                    parser.unsafeAdvance()
                }
                let sectionTokens = try parse(&parser, sectionName: name)
                tokens.append(.section(name, HBMustacheTemplate(sectionTokens)))

            case "^":
                parser.unsafeAdvance()
                let name = try parseSectionName(&parser)
                if parser.current() == "\n" {
                    parser.unsafeAdvance()
                }
                let sectionTokens = try parse(&parser, sectionName: name)
                tokens.append(.invertedSection(name, HBMustacheTemplate(sectionTokens)))

            case "/":
                parser.unsafeAdvance()
                let name = try parseSectionName(&parser)
                guard name == sectionName else {
                    throw HBMustacheError.sectionCloseNameIncorrect
                }
                if parser.current() == "\n" {
                    parser.unsafeAdvance()
                }
                return tokens

            case "{":
                parser.unsafeAdvance()
                let name = try parseSectionName(&parser)
                guard try parser.read("}") else { throw HBMustacheError.unfinishedSectionName }
                tokens.append(.unescapedVariable(name))

            case "!":
                parser.unsafeAdvance()
                _ = try parseSection(&parser)

            default:
                let name = try parseSectionName(&parser)
                tokens.append(.variable(name))
            }
        }
        // should never get here if reading section
        guard sectionName == nil else {
            throw HBMustacheError.expectedSectionEnd
        }
        return tokens
    }

    static func parseSectionName(_ parser: inout HBParser) throws -> String {
        let text = parser.read(while: sectionNameChars )
        guard try parser.read("}"), try parser.read("}") else { throw HBMustacheError.unfinishedSectionName }
        return text.string
    }

    static func parseSection(_ parser: inout HBParser) throws -> String {
        let text = try parser.read(untilString: "}}", throwOnOverflow: true, skipToEnd: true)
        return text.string
    }
    
    private static let sectionNameChars = Set<Unicode.Scalar>("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ._?")
}
