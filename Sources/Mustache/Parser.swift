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

import Foundation

/// Reader object for parsing String buffers
struct Parser {
    enum Error: Swift.Error {
        case overflow
    }

    /// internal storage used to store String
    private class Storage {
        init(_ buffer: String) {
            self.buffer = buffer
        }

        let buffer: String
    }

    private let _storage: Storage

    /// Create a Reader object
    /// - Parameter string: String to parse
    init(_ string: String) {
        self._storage = Storage(string)
        self.position = string.startIndex
    }

    var buffer: String { return self._storage.buffer }
    private(set) var position: String.Index
}

extension Parser {
    /// Return current character
    /// - Throws: .overflow
    /// - Returns: Current character
    mutating func character() throws -> Character {
        guard !self.reachedEnd() else { throw Parser.Error.overflow }
        let c = unsafeCurrent()
        unsafeAdvance()
        return c
    }

    /// Read the current character and return if it is as intended. If character test returns true then move forward 1
    /// - Parameter char: character to compare against
    /// - Throws: .overflow
    /// - Returns: If current character was the one we expected
    mutating func read(_ char: Character) throws -> Bool {
        let c = try character()
        guard c == char else { unsafeRetreat(); return false }
        return true
    }

    /// Read the current character and return if it is as intended. If character test returns true then move forward 1
    /// - Parameter char: character to compare against
    /// - Throws: .overflow
    /// - Returns: If current character was the one we expected
    mutating func read(string: String) throws -> Bool {
        let initialPosition = self.position
        guard string.count > 0 else { return true }
        let subString = try read(count: string.count)
        guard subString == string else {
            self.position = initialPosition
            return false
        }
        return true
    }

    /// Read the current character and check if it is in a set of characters If character test returns true then move forward 1
    /// - Parameter characterSet: Set of characters to compare against
    /// - Throws: .overflow
    /// - Returns: If current character is in character set
    mutating func read(_ characterSet: Set<Character>) throws -> Bool {
        let c = try character()
        guard characterSet.contains(c) else { unsafeRetreat(); return false }
        return true
    }

    /// Read next so many characters from buffer
    /// - Parameter count: Number of characters to read
    /// - Throws: .overflow
    /// - Returns: The string read from the buffer
    mutating func read(count: Int) throws -> Substring {
        guard self.buffer.distance(from: self.position, to: self.buffer.endIndex) >= count else { throw Parser.Error.overflow }
        let end = self.buffer.index(self.position, offsetBy: count)
        let subString = self.buffer[self.position..<end]
        unsafeAdvance(by: count)
        return subString
    }

    /// Read from buffer until we hit a character. Position after this is of the character we were checking for
    /// - Parameter until: Character to read until
    /// - Throws: .overflow if we hit the end of the buffer before reading character
    /// - Returns: String read from buffer
    @discardableResult mutating func read(until: Character, throwOnOverflow: Bool = true) throws -> Substring {
        let startIndex = self.position
        while !self.reachedEnd() {
            if unsafeCurrent() == until {
                return self.buffer[startIndex..<self.position]
            }
            unsafeAdvance()
        }
        if throwOnOverflow {
            unsafeSetPosition(startIndex)
            throw Parser.Error.overflow
        }
        return self.buffer[startIndex..<self.position]
    }

    /// Read from buffer until we hit a string. By default the position after this is of the beginning of the string we were checking for
    /// - Parameter untilString: String to check for
    /// - Parameter throwOnOverflow: Throw errors if we hit the end of the buffer
    /// - Parameter skipToEnd: Should we set the position to after the found string
    /// - Throws: .overflow, .emptyString
    /// - Returns: String read from buffer
    @discardableResult mutating func read(untilString: String, throwOnOverflow: Bool = true, skipToEnd: Bool = false) throws -> Substring {
        guard untilString.count > 0 else { return "" }
        let startIndex = self.position
        var foundIndex = self.position
        var untilIndex = untilString.startIndex
        while !self.reachedEnd() {
            if unsafeCurrent() == untilString[untilIndex] {
                if untilIndex == untilString.startIndex {
                    foundIndex = self.position
                }
                untilIndex = untilString.index(after: untilIndex)
                if untilIndex == untilString.endIndex {
                    unsafeAdvance()
                    if skipToEnd == false {
                        self.position = foundIndex
                    }
                    let result = self.buffer[startIndex..<foundIndex]
                    return result
                }
            } else {
                untilIndex = untilString.startIndex
            }
            unsafeAdvance()
        }
        if throwOnOverflow {
            self.position = startIndex
            throw Error.overflow
        }
        return self.buffer[startIndex..<self.position]
    }

    /// Read from buffer until we hit a character in supplied set. Position after this is of the character we were checking for
    /// - Parameter characterSet: Character set to check against
    /// - Throws: .overflow
    /// - Returns: String read from buffer
    @discardableResult mutating func read(until characterSet: Set<Character>, throwOnOverflow: Bool = true) throws -> Substring {
        let startIndex = self.position
        while !self.reachedEnd() {
            if characterSet.contains(unsafeCurrent()) {
                return self.buffer[startIndex..<self.position]
            }
            unsafeAdvance()
        }
        if throwOnOverflow {
            unsafeSetPosition(startIndex)
            throw Parser.Error.overflow
        }
        return self.buffer[startIndex..<self.position]
    }

    /// Read from buffer until keyPath on character returns true. Position after this is of the character we were checking for
    /// - Parameter keyPath: keyPath to check
    /// - Throws: .overflow
    /// - Returns: String read from buffer
    @discardableResult mutating func read(until keyPath: KeyPath<Character, Bool>, throwOnOverflow: Bool = true) throws -> Substring {
        let startIndex = self.position
        while !self.reachedEnd() {
            if current()[keyPath: keyPath] {
                return self.buffer[startIndex..<self.position]
            }
            unsafeAdvance()
        }
        if throwOnOverflow {
            self.position = startIndex
            throw Error.overflow
        }
        return self.buffer[startIndex..<self.position]
    }

    /// Read from buffer until keyPath on character returns true. Position after this is of the character we were checking for
    /// - Parameter keyPath: keyPath to check
    /// - Throws: .overflow
    /// - Returns: String read from buffer
    @discardableResult mutating func read(until cb: (Character) -> Bool, throwOnOverflow: Bool = true) throws -> Substring {
        let startIndex = self.position
        while !self.reachedEnd() {
            if cb(current()) {
                return self.buffer[startIndex..<self.position]
            }
            unsafeAdvance()
        }
        if throwOnOverflow {
            self.position = startIndex
            throw Error.overflow
        }
        return self.buffer[startIndex..<self.position]
    }

    /// Read from buffer from current position until the end of the buffer
    /// - Returns: String read from buffer
    @discardableResult mutating func readUntilTheEnd() -> Substring {
        let startIndex = self.position
        self.position = self.buffer.endIndex
        return self.buffer[startIndex..<self.position]
    }

    /// Read while character at current position is the one supplied
    /// - Parameter while: Character to check against
    /// - Returns: String read from buffer
    @discardableResult mutating func read(while: Character) -> Int {
        var count = 0
        while !self.reachedEnd(),
              unsafeCurrent() == `while`
        {
            unsafeAdvance()
            count += 1
        }
        return count
    }

    /// Read while keyPath on character at current position returns true is the one supplied
    /// - Parameter while: keyPath to check
    /// - Returns: String read from buffer
    @discardableResult mutating func read(while keyPath: KeyPath<Character, Bool>) -> Substring {
        let startIndex = self.position
        while !self.reachedEnd(),
              unsafeCurrent()[keyPath: keyPath]
        {
            unsafeAdvance()
        }
        return self.buffer[startIndex..<self.position]
    }

    /// Read while closure returns true
    /// - Parameter while: closure
    /// - Returns: String read from buffer
    @discardableResult mutating func read(while cb: (Character) -> Bool) -> Substring {
        let startIndex = self.position
        while !self.reachedEnd(),
              cb(unsafeCurrent())
        {
            unsafeAdvance()
        }
        return self.buffer[startIndex..<self.position]
    }

    /// Read while character at current position is in supplied set
    /// - Parameter while: character set to check
    /// - Returns: String read from buffer
    @discardableResult mutating func read(while characterSet: Set<Character>) -> Substring {
        let startIndex = self.position
        while !self.reachedEnd(),
              characterSet.contains(unsafeCurrent())
        {
            unsafeAdvance()
        }
        return self.buffer[startIndex..<self.position]
    }

    /// Return whether we have reached the end of the buffer
    /// - Returns: Have we reached the end
    func reachedEnd() -> Bool {
        return self.position == self.buffer.endIndex
    }

    /// Return whether we are at the start of the buffer
    /// - Returns: Are we are the start
    func atStart() -> Bool {
        return self.position == self.buffer.startIndex
    }
}

/// context used in parser error
public struct MustacheParserContext {
    public let line: String
    public let lineNumber: Int
    public let columnNumber: Int
}

extension Parser {
    /// Return context of current position (line, lineNumber, columnNumber)
    func getContext() -> MustacheParserContext {
        var parser = self
        var columnNumber = 0
        while !parser.atStart() {
            try? parser.retreat()
            if parser.current() == "\n" {
                break
            }
            columnNumber += 1
        }
        if parser.current() == "\n" {
            try? parser.advance()
        }
        // read line from parser
        let line = try! parser.read(until: Character("\n"), throwOnOverflow: false)
        // count new lines up to this current position
        let buffer = parser.buffer
        let textBefore = buffer[buffer.startIndex..<self.position]
        let lineNumber = textBefore.filter(\.isNewline).count

        return MustacheParserContext(line: String(line), lineNumber: lineNumber + 1, columnNumber: columnNumber + 1)
    }
}

/// versions of internal functions which include tests for overflow
extension Parser {
    /// Return the character at the current position
    /// - Throws: .overflow
    /// - Returns: Character
    func current() -> Character {
        guard !self.reachedEnd() else { return "\0" }
        return unsafeCurrent()
    }

    /// Move forward one character
    /// - Throws: .overflow
    mutating func advance() throws {
        guard !self.reachedEnd() else { throw Parser.Error.overflow }
        return unsafeAdvance()
    }

    /// Move back one character
    /// - Throws: .overflow
    mutating func retreat() throws {
        guard self.position != self.buffer.startIndex else { throw Parser.Error.overflow }
        return unsafeRetreat()
    }

    /// Move forward so many character
    /// - Parameter amount: number of characters to move forward
    /// - Throws: .overflow
    mutating func advance(by amount: Int) throws {
        guard self.buffer.distance(from: self.position, to: self.buffer.endIndex) >= amount else { throw Parser.Error.overflow }
        return unsafeAdvance(by: amount)
    }

    /// Move back so many characters
    /// - Parameter amount: number of characters to move back
    /// - Throws: .overflow
    mutating func retreat(by amount: Int) throws {
        guard self.buffer.distance(from: self.buffer.startIndex, to: self.position) >= amount else { throw Parser.Error.overflow }
        return unsafeRetreat(by: amount)
    }

    mutating func setPosition(_ position: String.Index) throws {
        guard position <= self.buffer.endIndex else { throw Parser.Error.overflow }
        unsafeSetPosition(position)
    }
}

// unsafe versions without checks
extension Parser {
    func unsafeCurrent() -> Character {
        return self.buffer[self.position]
    }

    mutating func unsafeAdvance() {
        self.position = self.buffer.index(after: self.position)
    }

    mutating func unsafeRetreat() {
        self.position = self.buffer.index(before: self.position)
    }

    mutating func unsafeAdvance(by amount: Int) {
        self.position = self.buffer.index(self.position, offsetBy: amount)
    }

    mutating func unsafeRetreat(by amount: Int) {
        self.position = self.buffer.index(self.position, offsetBy: -amount)
    }

    mutating func unsafeSetPosition(_ position: String.Index) {
        self.position = position
    }
}
