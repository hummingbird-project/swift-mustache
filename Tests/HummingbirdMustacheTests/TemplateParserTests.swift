@testable import HummingbirdMustache
import XCTest

final class TemplateParserTests: XCTestCase {
    func testText() throws {
        let template = try HBMustacheTemplate(string: "test template")
        XCTAssertEqual(template.tokens, [.text("test template")])
    }

    func testVariable() throws {
        let template = try HBMustacheTemplate(string: "test {{variable}}")
        XCTAssertEqual(template.tokens, [.text("test "), .variable(name: "variable")])
    }

    func testSection() throws {
        let template = try HBMustacheTemplate(string: "test {{#section}}text{{/section}}")
        XCTAssertEqual(template.tokens, [.text("test "), .section(name: "section", template: .init([.text("text")]))])
    }

    func testInvertedSection() throws {
        let template = try HBMustacheTemplate(string: "test {{^section}}text{{/section}}")
        XCTAssertEqual(template.tokens, [.text("test "), .invertedSection(name: "section", template: .init([.text("text")]))])
    }

    func testComment() throws {
        let template = try HBMustacheTemplate(string: "test {{!section}}")
        XCTAssertEqual(template.tokens, [.text("test ")])
    }

    func testWhitespace() throws {
        let template = try HBMustacheTemplate(string: "{{ section }}")
        XCTAssertEqual(template.tokens, [.variable(name: "section")])
    }

    func testContentType() throws {
        let template = try HBMustacheTemplate(string: "{{% CONTENT_TYPE:TEXT}}")
        let template1 = try HBMustacheTemplate(string: "{{% CONTENT_TYPE:TEXT }}")
        let template2 = try HBMustacheTemplate(string: "{{% CONTENT_TYPE: TEXT}}")
        let template3 = try HBMustacheTemplate(string: "{{%CONTENT_TYPE:TEXT}}")
        XCTAssertEqual(template.tokens, [.contentType(HBTextContentType())])
        XCTAssertEqual(template1.tokens, [.contentType(HBTextContentType())])
        XCTAssertEqual(template2.tokens, [.contentType(HBTextContentType())])
        XCTAssertEqual(template3.tokens, [.contentType(HBTextContentType())])
    }
}

extension HBMustacheTemplate: Equatable {
    public static func == (lhs: HBMustacheTemplate, rhs: HBMustacheTemplate) -> Bool {
        lhs.tokens == rhs.tokens
    }
}

extension HBMustacheTemplate.Token: Equatable {
    public static func == (lhs: HBMustacheTemplate.Token, rhs: HBMustacheTemplate.Token) -> Bool {
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
