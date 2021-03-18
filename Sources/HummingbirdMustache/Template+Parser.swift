
extension HBMustacheTemplate {
    enum Error: Swift.Error {
        case sectionCloseNameIncorrect
        case unfinishedName
        case expectedSectionEnd
        case invalidSetDelimiter
    }

    struct ParserState {
        var sectionName: String?
        var sectionMethod: String?
        var newLine: Bool
        var startDelimiter: String
        var endDelimiter: String

        init() {
            sectionName = nil
            newLine = true
            startDelimiter = "{{"
            endDelimiter = "}}"
        }

        func withSectionName(_ name: String, method: String? = nil) -> ParserState {
            var newValue = self
            newValue.sectionName = name
            newValue.sectionMethod = method
            return newValue
        }

        func withDelimiters(start: String, end: String) -> ParserState {
            var newValue = self
            newValue.startDelimiter = start
            newValue.endDelimiter = end
            return newValue
        }

        func withDefaultDelimiters(start _: String, end _: String) -> ParserState {
            var newValue = self
            newValue.startDelimiter = "{{"
            newValue.endDelimiter = "}}"
            return newValue
        }
    }

    /// parse mustache text to generate a list of tokens
    static func parse(_ string: String) throws -> [Token] {
        var parser = HBParser(string)
        return try parse(&parser, state: .init())
    }

    /// parse section in mustache text
    static func parse(_ parser: inout HBParser, state: ParserState) throws -> [Token] {
        var tokens: [Token] = []
        var state = state
        var whiteSpaceBefore: String = ""
        while !parser.reachedEnd() {
            // if new line read whitespace
            if state.newLine {
                whiteSpaceBefore = parser.read(while: Set(" \t")).string
            }
            let text = try readUntilDelimiterOrNewline(&parser, state: state)
            // if we hit a newline add text
            if parser.current() == "\n" {
                tokens.append(.text(whiteSpaceBefore + text + "\n"))
                state.newLine = true
                parser.unsafeAdvance()
                continue
            }
            // we have found a tag
            // whatever text we found before the tag should be added as a token
            if text.count > 0 {
                tokens.append(.text(whiteSpaceBefore + text))
                whiteSpaceBefore = ""
                state.newLine = false
            }
            // have we reached the end of the text
            if parser.reachedEnd() {
                break
            }
            var setNewLine = false
            switch parser.current() {
            case "#":
                // section
                parser.unsafeAdvance()
                let (name, method) = try parseName(&parser, state: state)
                if isStandalone(&parser, state: state) {
                    setNewLine = true
                } else if whiteSpaceBefore.count > 0 {
                    tokens.append(.text(whiteSpaceBefore))
                    whiteSpaceBefore = ""
                }
                let sectionTokens = try parse(&parser, state: state.withSectionName(name, method: method))
                tokens.append(.section(name: name, method: method, template: HBMustacheTemplate(sectionTokens)))

            case "^":
                // inverted section
                parser.unsafeAdvance()
                let (name, method) = try parseName(&parser, state: state)
                if isStandalone(&parser, state: state) {
                    setNewLine = true
                } else if whiteSpaceBefore.count > 0 {
                    tokens.append(.text(whiteSpaceBefore))
                    whiteSpaceBefore = ""
                }
                let sectionTokens = try parse(&parser, state: state.withSectionName(name, method: method))
                tokens.append(.invertedSection(name: name, method: method, template: HBMustacheTemplate(sectionTokens)))

            case "/":
                // end of section
                parser.unsafeAdvance()
                let (name, method) = try parseName(&parser, state: state)
                guard name == state.sectionName, method == state.sectionMethod else {
                    throw Error.sectionCloseNameIncorrect
                }
                if isStandalone(&parser, state: state) {
                    setNewLine = true
                } else if whiteSpaceBefore.count > 0 {
                    tokens.append(.text(whiteSpaceBefore))
                    whiteSpaceBefore = ""
                }
                return tokens

            case "!":
                // comment
                parser.unsafeAdvance()
                _ = try parseComment(&parser, state: state)
                setNewLine = isStandalone(&parser, state: state)

            case "{":
                // unescaped variable
                if whiteSpaceBefore.count > 0 {
                    tokens.append(.text(whiteSpaceBefore))
                    whiteSpaceBefore = ""
                }
                parser.unsafeAdvance()
                let (name, method) = try parseName(&parser, state: state)
                guard try parser.read("}") else { throw Error.unfinishedName }
                tokens.append(.unescapedVariable(name: name, method: method))

            case "&":
                // unescaped variable
                if whiteSpaceBefore.count > 0 {
                    tokens.append(.text(whiteSpaceBefore))
                    whiteSpaceBefore = ""
                }
                parser.unsafeAdvance()
                let (name, method) = try parseName(&parser, state: state)
                tokens.append(.unescapedVariable(name: name, method: method))

            case ">":
                // partial
                parser.unsafeAdvance()
                let (name, _) = try parseName(&parser, state: state)
                if whiteSpaceBefore.count > 0 {
                    tokens.append(.text(whiteSpaceBefore))
                }
                if isStandalone(&parser, state: state) {
                    setNewLine = true
                    tokens.append(.partial(name, indentation: whiteSpaceBefore))
                } else {
                    tokens.append(.partial(name, indentation: nil))
                }
                whiteSpaceBefore = ""

            case "=":
                // set delimiter
                parser.unsafeAdvance()
                state = try parserSetDelimiter(&parser, state: state)
                setNewLine = isStandalone(&parser, state: state)

            default:
                // variable
                if whiteSpaceBefore.count > 0 {
                    tokens.append(.text(whiteSpaceBefore))
                    whiteSpaceBefore = ""
                }
                let (name, method) = try parseName(&parser, state: state)
                tokens.append(.variable(name: name, method: method))
            }
            state.newLine = setNewLine
        }
        // should never get here if reading section
        guard state.sectionName == nil else {
            throw Error.expectedSectionEnd
        }
        return tokens
    }

    /// read until we hit either the start delimiter of a tag or a newline
    static func readUntilDelimiterOrNewline(_ parser: inout HBParser, state: ParserState) throws -> String {
        var untilSet = Set("\n")
        guard let delimiterFirstChar = state.startDelimiter.first,
              let delimiterFirstScalar = delimiterFirstChar.unicodeScalars.first else { return "" }
        var totalText = ""
        untilSet.insert(delimiterFirstScalar)

        while !parser.reachedEnd() {
            // read until we hit either a newline or "{"
            let text = try parser.read(until: untilSet, throwOnOverflow: false).string
            totalText += text
            // if new line append all text read plus newline
            if parser.current() == "\n" {
                break
            } else if parser.current() == delimiterFirstScalar {
                if try parser.read(state.startDelimiter) {
                    break
                }
                totalText += String(delimiterFirstScalar)
                parser.unsafeAdvance()
            }
        }
        return totalText
    }

    /// parse variable name
    static func parseName(_ parser: inout HBParser, state: ParserState) throws -> (String, String?) {
        parser.read(while: \.isWhitespace)
        var text = parser.read(while: sectionNameChars)
        parser.read(while: \.isWhitespace)
        guard try parser.read(state.endDelimiter) else { throw Error.unfinishedName }

        // does the name include brackets. If so this is a method call
        let string = text.read(while: sectionNameCharsWithoutBrackets)
        if text.reachedEnd() {
            return (text.string, nil)
        } else {
            // parse function parameter, as we have just parsed a function name
            guard text.current() == "(" else { throw Error.unfinishedName }
            text.unsafeAdvance()
            let string2 = text.read(while: sectionNameCharsWithoutBrackets)
            guard text.current() == ")" else { throw Error.unfinishedName }
            text.unsafeAdvance()
            guard text.reachedEnd() else { throw Error.unfinishedName }
            return (string2.string, string.string)
        }
    }

    static func parseComment(_ parser: inout HBParser, state: ParserState) throws -> String {
        let text = try parser.read(untilString: state.endDelimiter, throwOnOverflow: true, skipToEnd: true)
        return text.string
    }

    static func parserSetDelimiter(_ parser: inout HBParser, state: ParserState) throws -> ParserState {
        parser.read(while: \.isWhitespace)
        let startDelimiter = try parser.read(until: \.isWhitespace).string
        parser.read(while: \.isWhitespace)
        let endDelimiter = try parser.read(until: { $0 == "=" || $0.isWhitespace }).string
        parser.read(while: \.isWhitespace)
        guard try parser.read("=") else { throw Error.invalidSetDelimiter }
        guard try parser.read(state.endDelimiter) else { throw Error.invalidSetDelimiter }
        guard startDelimiter.count > 0, endDelimiter.count > 0 else { throw Error.invalidSetDelimiter }
        return state.withDelimiters(start: startDelimiter, end: endDelimiter)
    }

    static func hasLineFinished(_ parser: inout HBParser) -> Bool {
        var parser2 = parser
        if parser.reachedEnd() { return true }
        parser2.read(while: Set(" \t\r"))
        if parser2.current() == "\n" {
            parser2.unsafeAdvance()
            try! parser.setPosition(parser2.getPosition())
            return true
        }
        return false
    }

    static func isStandalone(_ parser: inout HBParser, state: ParserState) -> Bool  {
        return state.newLine && hasLineFinished(&parser)
    }

    private static let sectionNameCharsWithoutBrackets = Set<Unicode.Scalar>("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ._?")
    private static let sectionNameChars = Set<Unicode.Scalar>("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ._?()")
}
