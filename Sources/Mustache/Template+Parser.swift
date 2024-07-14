//===----------------------------------------------------------------------===//
//
// This source file is part of the Hummingbird server framework project
//
// Copyright (c) 2021-2021 the Hummingbird authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See hummingbird/CONTRIBUTORS.txt for the list of Hummingbird authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension MustacheTemplate {
    /// Error return by `MustacheTemplate.parse`. Includes information about where error occurred
    public struct ParserError: Swift.Error {
        public let context: MustacheParserContext
        public let error: Swift.Error
    }

    /// Error generated by `MustacheTemplate.parse`
    public enum Error: Swift.Error {
        /// the end section does not match the name of the start section
        case sectionCloseNameIncorrect
        /// tag was badly formatted
        case unfinishedName
        /// was expecting a section end
        case expectedSectionEnd
        /// set delimiter tag badly formatted
        case invalidSetDelimiter
        /// cannot apply transform to inherited section
        case transformAppliedToInheritanceSection
        /// illegal token inside inherit section of partial
        case illegalTokenInsideInheritSection
        /// text found inside inherit section of partial
        case textInsideInheritSection
        /// config variable syntax is wrong
        case invalidConfigVariableSyntax
        /// unrecognised config variable
        case unrecognisedConfigVariable
    }

    struct ParserState {
        var sectionName: String?
        var sectionTransforms: [String] = []
        var newLine: Bool
        var startDelimiter: String
        var endDelimiter: String

        init() {
            self.sectionName = nil
            self.newLine = true
            self.startDelimiter = "{{"
            self.endDelimiter = "}}"
        }

        func withSectionName(_ name: String, transforms: [String] = []) -> ParserState {
            var newValue = self
            newValue.sectionName = name
            newValue.sectionTransforms = transforms
            return newValue
        }

        func withDelimiters(start: String, end: String) -> ParserState {
            var newValue = self
            newValue.startDelimiter = start
            newValue.endDelimiter = end
            return newValue
        }
    }

    /// parse mustache text to generate a list of tokens
    static func parse(_ string: String) throws -> [Token] {
        var parser = Parser(string)
        do {
            return try self.parse(&parser, state: .init())
        } catch {
            throw ParserError(context: parser.getContext(), error: error)
        }
    }

    /// parse section in mustache text
    static func parse(_ parser: inout Parser, state: ParserState) throws -> [Token] {
        var tokens: [Token] = []
        var state = state
        var whiteSpaceBefore: Substring = ""
        while !parser.reachedEnd() {
            // if new line read whitespace
            if state.newLine {
                whiteSpaceBefore = parser.read(while: Set(" \t"))
            }
            let text = try readUntilDelimiterOrNewline(&parser, state: state)
            // if we hit a newline add text
            if parser.current().isNewline {
                tokens.append(.text(whiteSpaceBefore + text + String(parser.current())))
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
                let (name, transforms) = try parseName(&parser, state: state)
                if self.isStandalone(&parser, state: state) {
                    setNewLine = true
                } else if whiteSpaceBefore.count > 0 {
                    tokens.append(.text(String(whiteSpaceBefore)))
                    whiteSpaceBefore = ""
                }
                let sectionTokens = try parse(&parser, state: state.withSectionName(name, transforms: transforms))
                tokens.append(.section(name: name, transforms: transforms, template: MustacheTemplate(sectionTokens)))

            case "^":
                // inverted section
                parser.unsafeAdvance()
                let (name, transforms) = try parseName(&parser, state: state)
                if self.isStandalone(&parser, state: state) {
                    setNewLine = true
                } else if whiteSpaceBefore.count > 0 {
                    tokens.append(.text(String(whiteSpaceBefore)))
                    whiteSpaceBefore = ""
                }
                let sectionTokens = try parse(&parser, state: state.withSectionName(name, transforms: transforms))
                tokens.append(.invertedSection(name: name, transforms: transforms, template: MustacheTemplate(sectionTokens)))

            case "$":
                // inherited section
                parser.unsafeAdvance()
                let (name, transforms) = try parseName(&parser, state: state)
                // ERROR: can't have transform applied to inherited sections
                guard transforms.isEmpty else { throw Error.transformAppliedToInheritanceSection }
                if self.isStandalone(&parser, state: state) {
                    setNewLine = true
                } else if whiteSpaceBefore.count > 0 {
                    tokens.append(.text(String(whiteSpaceBefore)))
                    whiteSpaceBefore = ""
                }
                let sectionTokens = try parse(&parser, state: state.withSectionName(name, transforms: transforms))
                tokens.append(.inheritedSection(name: name, template: MustacheTemplate(sectionTokens)))

            case "/":
                // end of section
                parser.unsafeAdvance()
                let position = parser.position
                let (name, transforms) = try parseName(&parser, state: state)
                guard name == state.sectionName, transforms == state.sectionTransforms else {
                    parser.unsafeSetPosition(position)
                    throw Error.sectionCloseNameIncorrect
                }
                if self.isStandalone(&parser, state: state) {
                    setNewLine = true
                } else if whiteSpaceBefore.count > 0 {
                    tokens.append(.text(String(whiteSpaceBefore)))
                    whiteSpaceBefore = ""
                }
                return tokens

            case "!":
                // comment
                parser.unsafeAdvance()
                _ = try self.parseComment(&parser, state: state)
                setNewLine = self.isStandalone(&parser, state: state)

            case "{":
                // unescaped variable
                if whiteSpaceBefore.count > 0 {
                    tokens.append(.text(String(whiteSpaceBefore)))
                    whiteSpaceBefore = ""
                }
                parser.unsafeAdvance()
                let (name, transforms) = try parseName(&parser, state: state)
                guard try parser.read("}") else { throw Error.unfinishedName }
                tokens.append(.unescapedVariable(name: name, transforms: transforms))

            case "&":
                // unescaped variable
                if whiteSpaceBefore.count > 0 {
                    tokens.append(.text(String(whiteSpaceBefore)))
                    whiteSpaceBefore = ""
                }
                parser.unsafeAdvance()
                let (name, transforms) = try parseName(&parser, state: state)
                tokens.append(.unescapedVariable(name: name, transforms: transforms))

            case ">":
                // partial
                parser.unsafeAdvance()
                let name = try parsePartialName(&parser, state: state)
                if whiteSpaceBefore.count > 0 {
                    tokens.append(.text(String(whiteSpaceBefore)))
                }
                if self.isStandalone(&parser, state: state) {
                    setNewLine = true
                    tokens.append(.partial(name, indentation: String(whiteSpaceBefore), inherits: nil))
                } else {
                    tokens.append(.partial(name, indentation: nil, inherits: nil))
                }
                whiteSpaceBefore = ""

            case "<":
                // partial with inheritance
                parser.unsafeAdvance()
                let name = try parsePartialName(&parser, state: state)
                var indent: String?
                if self.isStandalone(&parser, state: state) {
                    setNewLine = true
                } else if whiteSpaceBefore.count > 0 {
                    indent = String(whiteSpaceBefore)
                    tokens.append(.text(indent!))
                    whiteSpaceBefore = ""
                }
                let sectionTokens = try parse(&parser, state: state.withSectionName(name))
                var inherit: [String: MustacheTemplate] = [:]
                // parse tokens in section to extract inherited sections
                for token in sectionTokens {
                    switch token {
                    case .inheritedSection(let name, let template):
                        inherit[name] = template
                    case .text:
                        break
                    default:
                        throw Error.illegalTokenInsideInheritSection
                    }
                }
                tokens.append(.partial(name, indentation: indent, inherits: inherit))

            case "=":
                // set delimiter
                parser.unsafeAdvance()
                state = try self.parserSetDelimiter(&parser, state: state)
                setNewLine = self.isStandalone(&parser, state: state)

            case "%":
                // read config variable
                parser.unsafeAdvance()
                if let token = try self.readConfigVariable(&parser, state: state) {
                    tokens.append(token)
                }
                setNewLine = self.isStandalone(&parser, state: state)

            default:
                // variable
                if whiteSpaceBefore.count > 0 {
                    tokens.append(.text(String(whiteSpaceBefore)))
                    whiteSpaceBefore = ""
                }
                let (name, transforms) = try parseName(&parser, state: state)
                tokens.append(.variable(name: name, transforms: transforms))
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
    static func readUntilDelimiterOrNewline(_ parser: inout Parser, state: ParserState) throws -> String {
        var untilSet: Set<Character> = ["\n", "\r\n"]
        guard let delimiterFirstChar = state.startDelimiter.first else { return "" }
        var totalText = ""
        untilSet.insert(delimiterFirstChar)

        while !parser.reachedEnd() {
            // read until we hit either a newline or "{"
            let text = try parser.read(until: untilSet, throwOnOverflow: false)
            totalText += text
            // if new line append all text read plus newline
            if parser.current().isNewline {
                break
            } else if parser.current() == delimiterFirstChar {
                if try parser.read(string: state.startDelimiter) {
                    break
                }
                totalText += String(delimiterFirstChar)
                parser.unsafeAdvance()
            }
        }
        return totalText
    }

    /// parse variable name
    static func parseName(_ parser: inout Parser, state: ParserState) throws -> (String, [String]) {
        parser.read(while: \.isWhitespace)
        let text = String(parser.read(while: self.sectionNameChars))
        parser.read(while: \.isWhitespace)
        guard try parser.read(string: state.endDelimiter) else { throw Error.unfinishedName }

        // does the name include brackets. If so this is a transform call
        var nameParser = Parser(String(text))
        let string = nameParser.read(while: self.sectionNameCharsWithoutBrackets)
        if nameParser.reachedEnd() {
            return (text, [])
        } else {
            // parse function parameter, as we have just parsed a function name
            guard nameParser.current() == "(" else { throw Error.unfinishedName }
            nameParser.unsafeAdvance()
            
            func parseTransforms(existing: [Substring]) throws -> (Substring, [Substring]) {
                let name = nameParser.read(while: self.sectionNameCharsWithoutBrackets)
                switch nameParser.current() {
                case ")":
                    // Transforms are ending
                    nameParser.unsafeAdvance()
                    // We need to have a `)` for each transform that we've parsed
                    guard nameParser.read(while: ")") + 1 == existing.count,
                          nameParser.reachedEnd() else {
                        throw Error.unfinishedName
                    }
                    return (name, existing)
                case "(":
                    // Parse the next transform
                    nameParser.unsafeAdvance()

                    var transforms = existing
                    transforms.append(name)
                    return try parseTransforms(existing: transforms)
                default:
                    throw Error.unfinishedName
                }
            }
            let (parameterName, transforms) = try parseTransforms(existing: [string])

            return (String(parameterName), transforms.map(String.init))
        }
    }

    /// parse partial name
    static func parsePartialName(_ parser: inout Parser, state: ParserState) throws -> String {
        parser.read(while: \.isWhitespace)
        let text = String(parser.read(while: self.sectionNameChars))
        parser.read(while: \.isWhitespace)
        guard try parser.read(string: state.endDelimiter) else { throw Error.unfinishedName }
        return text
    }

    static func parseComment(_ parser: inout Parser, state: ParserState) throws -> String {
        let text = try parser.read(untilString: state.endDelimiter, throwOnOverflow: true, skipToEnd: true)
        return String(text)
    }

    static func parserSetDelimiter(_ parser: inout Parser, state: ParserState) throws -> ParserState {
        let startDelimiter: Substring
        let endDelimiter: Substring

        do {
            parser.read(while: \.isWhitespace)
            startDelimiter = try parser.read(until: \.isWhitespace)
            parser.read(while: \.isWhitespace)
            endDelimiter = try parser.read(until: { $0 == "=" || $0.isWhitespace })
            parser.read(while: \.isWhitespace)
        } catch {
            throw Error.invalidSetDelimiter
        }
        guard try parser.read("=") else { throw Error.invalidSetDelimiter }
        guard try parser.read(string: state.endDelimiter) else { throw Error.invalidSetDelimiter }
        guard startDelimiter.count > 0, endDelimiter.count > 0 else { throw Error.invalidSetDelimiter }
        return state.withDelimiters(start: String(startDelimiter), end: String(endDelimiter))
    }

    static func readConfigVariable(_ parser: inout Parser, state: ParserState) throws -> Token? {
        let variable: Substring
        let value: Substring

        do {
            parser.read(while: \.isWhitespace)
            variable = parser.read(while: self.sectionNameCharsWithoutBrackets)
            parser.read(while: \.isWhitespace)
            guard try parser.read(":") else { throw Error.invalidConfigVariableSyntax }
            parser.read(while: \.isWhitespace)
            value = parser.read(while: self.sectionNameCharsWithoutBrackets)
            parser.read(while: \.isWhitespace)
            guard try parser.read(string: state.endDelimiter) else { throw Error.invalidConfigVariableSyntax }
        } catch {
            throw Error.invalidConfigVariableSyntax
        }

        // do both variable and value have content
        guard variable.count > 0, value.count > 0 else { throw Error.invalidConfigVariableSyntax }

        switch variable {
        case "CONTENT_TYPE":
            guard let contentType = MustacheContentTypes.get(String(value)) else { throw Error.unrecognisedConfigVariable }
            return .contentType(contentType)
        default:
            throw Error.unrecognisedConfigVariable
        }
    }

    static func hasLineFinished(_ parser: inout Parser) -> Bool {
        var parser2 = parser
        if parser.reachedEnd() { return true }
        parser2.read(while: Set(" \t"))
        if parser2.current().isNewline {
            parser2.unsafeAdvance()
            try! parser.setPosition(parser2.position)
            return true
        }
        return false
    }

    static func isStandalone(_ parser: inout Parser, state: ParserState) -> Bool {
        return state.newLine && self.hasLineFinished(&parser)
    }

    private static let sectionNameCharsWithoutBrackets = Set<Character>("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.-_?")
    private static let sectionNameChars = Set<Character>("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.-_?()")
    private static let partialNameChars = Set<Character>("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.-_()")
}
