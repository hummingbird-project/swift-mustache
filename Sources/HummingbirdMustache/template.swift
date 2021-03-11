import Hummingbird

enum HBMustacheError: Error {
    case sectionCloseNameIncorrect
    case unfinishedSectionName
}

class HBTemplate {
    init(_ string: String) throws {
        self.tokens = try Self.parse(string)
    }

    static func parse(_ string: String) throws -> [Token] {
        var parser = Parser(string)
        return try parse(&parser, sectionName: nil)
    }

    static func parse(_ parser: inout Parser, sectionName: String?) throws -> [Token] {
        var tokens: [Token] = []
        while !parser.reachedEnd() {
            let text = try parser.read(untilString: "{{", throwOnOverflow: false, skipToEnd: true)
            tokens.append(.text(text.string))
            switch parser.current() {
            case "#":
                let name = try readSectionName(&parser)
                let sectionTokens = try parse(&parser, sectionName: name)
                tokens.append(.section(name, sectionTokens))

            case "^":
                let name = try readSectionName(&parser)
                let sectionTokens = try parse(&parser, sectionName: name)
                tokens.append(.invertedSection(name, sectionTokens))

            case "/":
                let name = try readSectionName(&parser)
                if name != sectionName {
                    throw HBMustacheError.sectionCloseNameIncorrect
                }
                return tokens

            case "{":
                let name = try readSectionName(&parser)
                guard try parser.read("}") else { throw HBMustacheError.unfinishedSectionName }
                tokens.append(.variable(name))

            case "!":
                _ = try readSection(&parser)

            default:
                let name = try readSectionName(&parser)
                tokens.append(.variable(name))
            }
        }
        return tokens
    }

    static func readSectionName(_ parser: inout Parser) throws -> String {
        let text = parser.read(while: { $0.isLetter || $0.isNumber } )
        guard try parser.read("}"), try parser.read("}") else { throw HBMustacheError.unfinishedSectionName }
        return text.string
    }

    static func readSection(_ parser: inout Parser) throws -> String {
        let text = try parser.read(untilString: "}}", throwOnOverflow: true, skipToEnd: true)
        return text.string
    }

    enum Token {
        case text(String)
        case variable(String)
        case section(String, [Token])
        case invertedSection(String, [Token])
    }

    let tokens: [Token]
}

