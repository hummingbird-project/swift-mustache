import XCTest
@testable import HummingbirdMustache

final class TemplateParserTests: XCTestCase {
    func testText() throws {
        let template = try HBTemplate("test template")
        XCTAssertEqual(template.tokens, [.text("test template")])
    }

    func testVariable() throws {
        let template = try HBTemplate("test {{variable}}")
        XCTAssertEqual(template.tokens, [.text("test "), .variable("variable")])
    }

    func testSection() throws {
        let template = try HBTemplate("test {{#section}}text{{/section}}")
        XCTAssertEqual(template.tokens, [.text("test "), .section("section", .init([.text("text")]))])
    }

    func testInvertedSection() throws {
        let template = try HBTemplate("test {{^section}}text{{/section}}")
        XCTAssertEqual(template.tokens, [.text("test "), .invertedSection("section", .init([.text("text")]))])
    }

    func testComment() throws {
        let template = try HBTemplate("test {{!section}}")
        XCTAssertEqual(template.tokens, [.text("test ")])
    }
}

extension HBTemplate: Equatable {
    public static func == (lhs: HBTemplate, rhs: HBTemplate) -> Bool {
        lhs.tokens == rhs.tokens
    }
}

extension HBTemplate.Token: Equatable {
    public static func == (lhs: HBTemplate.Token, rhs: HBTemplate.Token) -> Bool {
        switch (lhs, rhs) {
        case (.text(let lhs), .text(let rhs)):
            return lhs == rhs
        case (.variable(let lhs), .variable(let rhs)):
            return lhs == rhs
        case (.section(let lhs1, let lhs2), .section(let rhs1, let rhs2)):
            return lhs1 == rhs1 && lhs2 == rhs2
        case (.invertedSection(let lhs1, let lhs2), .invertedSection(let rhs1, let rhs2)):
            return lhs1 == rhs1 && lhs2 == rhs2
        default:
            return false
        }
    }
}
