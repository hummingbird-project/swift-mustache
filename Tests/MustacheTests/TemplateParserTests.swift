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

import XCTest

@testable import Mustache

final class TemplateParserTests: XCTestCase {
    func testText() throws {
        let template = try MustacheTemplate(string: "test template")
        XCTAssertEqual(template.tokens, [.text("test template")])
    }

    func testVariable() throws {
        let template = try MustacheTemplate(string: "test {{variable}}")
        XCTAssertEqual(template.tokens, [.text("test "), .variable(name: "variable")])
    }

    func testSection() throws {
        let template = try MustacheTemplate(string: "test {{#section}}text{{/section}}")
        XCTAssertEqual(template.tokens, [.text("test "), .section(name: "section", template: .init([.text("text")], text: "text"))])
    }

    func testInvertedSection() throws {
        let template = try MustacheTemplate(string: "test {{^section}}text{{/section}}")
        XCTAssertEqual(template.tokens, [.text("test "), .invertedSection(name: "section", template: .init([.text("text")], text: "text"))])
    }

    func testComment() throws {
        let template = try MustacheTemplate(string: "test {{!section}}")
        XCTAssertEqual(template.tokens, [.text("test ")])
    }

    func testWhitespace() throws {
        let template = try MustacheTemplate(string: "{{ section }}")
        XCTAssertEqual(template.tokens, [.variable(name: "section")])
    }

    func testContentType() throws {
        let template = try MustacheTemplate(string: "{{% CONTENT_TYPE:TEXT}}")
        let template1 = try MustacheTemplate(string: "{{% CONTENT_TYPE:TEXT }}")
        let template2 = try MustacheTemplate(string: "{{% CONTENT_TYPE: TEXT}}")
        let template3 = try MustacheTemplate(string: "{{%CONTENT_TYPE:TEXT}}")
        XCTAssertEqual(template.tokens, [.contentType(TextContentType())])
        XCTAssertEqual(template1.tokens, [.contentType(TextContentType())])
        XCTAssertEqual(template2.tokens, [.contentType(TextContentType())])
        XCTAssertEqual(template3.tokens, [.contentType(TextContentType())])
    }
}

extension MustacheTemplate {
    public static func == (lhs: MustacheTemplate, rhs: MustacheTemplate) -> Bool {
        lhs.tokens == rhs.tokens
    }
}

extension MustacheTemplate: Equatable {}

extension MustacheTemplate.Token {
    public static func == (lhs: MustacheTemplate.Token, rhs: MustacheTemplate.Token) -> Bool {
        switch (lhs, rhs) {
        case (.text(let lhs), .text(let rhs)):
            return lhs == rhs
        case (.variable(let lhs, let lhs2), .variable(let rhs, let rhs2)):
            return lhs == rhs && lhs2 == rhs2
        case (.section(let lhs1, let lhs2, let lhs3), .section(let rhs1, let rhs2, let rhs3)):
            return lhs1 == rhs1 && lhs2 == rhs2 && lhs3 == rhs3
        case (.invertedSection(let lhs1, let lhs2, let lhs3), .invertedSection(let rhs1, let rhs2, let rhs3)):
            return lhs1 == rhs1 && lhs2 == rhs2 && lhs3 == rhs3
        case (.partial(let name1, let indent1, _), .partial(let name2, let indent2, _)):
            return name1 == name2 && indent1 == indent2
        case (.contentType(let contentType), .contentType(let contentType2)):
            return type(of: contentType) == type(of: contentType2)
        default:
            return false
        }
    }
}

extension MustacheTemplate.Token: Equatable {}
