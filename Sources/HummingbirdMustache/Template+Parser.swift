
extension HBMustacheTemplate {
    enum Error: Swift.Error {
        case sectionCloseNameIncorrect
        case unfinishedName
        case expectedSectionEnd
    }

    /// parse mustache text to generate a list of tokens
    static func parse(_ string: String) throws -> [Token] {
        var parser = HBParser(string)
        return try parse(&parser, sectionName: nil)
    }

    /// parse section in mustache text
    static func parse(_ parser: inout HBParser, sectionName: String?, newLine: Bool = true) throws -> [Token] {
        var tokens: [Token] = []
        var newLine = newLine
        var whiteSpaceBefore: String = ""
        while !parser.reachedEnd() {
            // if new line read whitespace
            if newLine {
                whiteSpaceBefore = parser.read(while: Set(" \t")).string
            }
            // read until we hit either a newline or "{"
            let text = try parser.read(until: Set("{\n"), throwOnOverflow: false)
            // if new line append all text read plus newline
            if parser.current() == "\n" {
                tokens.append(.text(whiteSpaceBefore + text.string + "\n"))
                newLine = true
                parser.unsafeAdvance()
                continue
            } else if parser.current() == "{" {
                parser.unsafeAdvance()
                // if next character is not "{" then is normal text
                if parser.current() != "{" {
                    if text.count > 0 {
                        tokens.append(.text(whiteSpaceBefore + text.string + "{"))
                        whiteSpaceBefore = ""
                        newLine = false
                    }
                    continue
                } else {
                    parser.unsafeAdvance()
                }
            }

            // whatever text we found before the "{{" should be added
            if text.count > 0 {
                tokens.append(.text(whiteSpaceBefore + text.string))
                whiteSpaceBefore = ""
                newLine = false
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
                let (name, method) = try parseName(&parser)
                if newLine, hasLineFinished(&parser) {
                    setNewLine = true
                    if parser.current() == "\n" {
                        parser.unsafeAdvance()
                    }
                } else if whiteSpaceBefore.count > 0 {
                    tokens.append(.text(whiteSpaceBefore))
                    whiteSpaceBefore = ""
                }
                let sectionTokens = try parse(&parser, sectionName: name, newLine: newLine)
                tokens.append(.section(name: name, method: method, template: HBMustacheTemplate(sectionTokens)))

            case "^":
                // inverted section
                parser.unsafeAdvance()
                let (name, method) = try parseName(&parser)
                if newLine, hasLineFinished(&parser) {
                    setNewLine = true
                    if parser.current() == "\n" {
                        parser.unsafeAdvance()
                    }
                } else if whiteSpaceBefore.count > 0 {
                    tokens.append(.text(whiteSpaceBefore))
                    whiteSpaceBefore = ""
                }
                let sectionTokens = try parse(&parser, sectionName: name, newLine: newLine)
                tokens.append(.invertedSection(name: name, method: method, template: HBMustacheTemplate(sectionTokens)))

            case "/":
                // end of section
                parser.unsafeAdvance()
                let (name, _) = try parseName(&parser)
                guard name == sectionName else {
                    throw Error.sectionCloseNameIncorrect
                }
                if newLine, hasLineFinished(&parser) {
                    setNewLine = true
                    if parser.current() == "\n" {
                        parser.unsafeAdvance()
                    }
                } else if whiteSpaceBefore.count > 0 {
                    tokens.append(.text(whiteSpaceBefore))
                    whiteSpaceBefore = ""
                }
                return tokens

            case "!":
                // comment
                parser.unsafeAdvance()
                _ = try parseComment(&parser)
                if newLine, hasLineFinished(&parser) {
                    setNewLine = true
                    if !parser.reachedEnd() {
                        parser.unsafeAdvance()
                    }
                }

            case "{":
                // unescaped variable
                if whiteSpaceBefore.count > 0 {
                    tokens.append(.text(whiteSpaceBefore))
                    whiteSpaceBefore = ""
                }
                parser.unsafeAdvance()
                let (name, method) = try parseName(&parser)
                guard try parser.read("}") else { throw Error.unfinishedName }
                tokens.append(.unescapedVariable(name: name, method: method))

            case "&":
                // unescaped variable
                if whiteSpaceBefore.count > 0 {
                    tokens.append(.text(whiteSpaceBefore))
                    whiteSpaceBefore = ""
                }
                parser.unsafeAdvance()
                let (name, method) = try parseName(&parser)
                tokens.append(.unescapedVariable(name: name, method: method))

            case ">":
                // partial
                parser.unsafeAdvance()
                let (name, _) = try parseName(&parser)
                /* if newLine && hasLineFinished(&parser) {
                     setNewLine = true
                     if parser.current() == "\n" {
                         parser.unsafeAdvance()
                     }
                 } */
                if whiteSpaceBefore.count > 0 {
                    tokens.append(.text(whiteSpaceBefore))
                }
                if newLine, hasLineFinished(&parser) {
                    setNewLine = true
                    if parser.current() == "\n" {
                        parser.unsafeAdvance()
                    }
                    tokens.append(.partial(name, indentation: whiteSpaceBefore))
                } else {
                    tokens.append(.partial(name, indentation: nil))
                }
                whiteSpaceBefore = ""

            default:
                // variable
                if whiteSpaceBefore.count > 0 {
                    tokens.append(.text(whiteSpaceBefore))
                    whiteSpaceBefore = ""
                }
                let (name, method) = try parseName(&parser)
                tokens.append(.variable(name: name, method: method))
            }
            newLine = setNewLine
        }
        // should never get here if reading section
        guard sectionName == nil else {
            throw Error.expectedSectionEnd
        }
        return tokens
    }

    /// parse variable name
    static func parseName(_ parser: inout HBParser) throws -> (String, String?) {
        parser.read(while: \.isWhitespace)
        var text = parser.read(while: sectionNameChars)
        parser.read(while: \.isWhitespace)
        guard try parser.read("}"), try parser.read("}") else { throw Error.unfinishedName }
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

    static func parseComment(_ parser: inout HBParser) throws -> String {
        let text = try parser.read(untilString: "}}", throwOnOverflow: true, skipToEnd: true)
        return text.string
    }

    static func hasLineFinished(_ parser: inout HBParser) -> Bool {
        var parser2 = parser
        if parser.reachedEnd() { return true }
        parser2.read(while: Set(" \t\r"))
        if parser2.current() == "\n" {
            try! parser.setPosition(parser2.getPosition())
            return true
        }
        return false
    }

    private static let sectionNameCharsWithoutBrackets = Set<Unicode.Scalar>("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ._?")
    private static let sectionNameChars = Set<Unicode.Scalar>("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ._?()")
}
